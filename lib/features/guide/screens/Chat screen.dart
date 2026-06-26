// ============================================================
// chat_screen.dart
// KemitGetit — Individual Chat Screen
// API-driven via ChatService + SignalR
// State: setState only
// ============================================================

import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/auth_service.dart';
import 'package:kemit_get_it/features/guide/core/chat_service.dart';
import 'package:kemit_get_it/features/guide/models/chat_model.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _onlineGreen = Color(0xFF66BB6A);
const Color _backgroundColor = Color(0xFFF7F7F7);
const Color _surfaceWhite = Colors.white;
const Color _textPrimary = Color(0xFF1A1A1A);
const Color _textSecondary = Color(0xFF757575);
const Color _bubbleGuide = Colors.white;
const Color _bubbleTourist = Color(0xFFE8F5E9);
const Color _inputBg = Color(0xFFF2F2F2);
const Color _lockedBg = Color(0xFFFFF8E1);
const Color _lockedBorder = Color(0xFFFFE082);

// ─────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  final int? currentUserId;

  /// [chatService] بيييجي عن طريق DI — نفس الـ instance اللي الـ list screen شغلاه.
  final ChatService chatService;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.chatService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── State ──
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  late ChatUIState _uiState;
  late HubConnection _hubConnection;

  // FIX #2 — set لتتبع الرسائل اللي اتعلّمت read عشان نمنع التكرار
  final Set<int> _readMessageIds = {};

  @override
  void initState() {
    super.initState();
    _uiState = ChatUIState.fromStatus(widget.conversation.status);
    _fetchMessages();
    _initSignalR();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _leaveAndDisposeHub();
    super.dispose();
  }

  // ── Fetch messages via ChatService ────────────────────────
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // FIX #1 — استخدام ChatService بدل http.get المباشر
      final conv = await widget.chatService.getConversationById(
        widget.conversation.id,
      );

      setState(() {
        _messages = List<MessageModel>.from(conv.messages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        _uiState = ChatUIState.fromStatus(conv.status);
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on ChatServiceException catch (e) {
      // FIX #3 — ChatService._throwIfError بيتعامل مع plain text و JSON تلقائيًا
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ── SignalR Setup ─────────────────────────────────────────
  Future<void> _initSignalR() async {
    _hubConnection =
        HubConnectionBuilder()
            .withUrl(
              'https://api.kemitgetit.com/api/chatHub',
              options: HttpConnectionOptions(
                accessTokenFactory: () async {
                  return await AuthService.getToken() ?? '';
                },
              ),
            )
            .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000])
            .build();

    // ── Inbound message ──
    // FIX #4 — SignalR بيُستخدم فقط لاستقبال رسائل الطرف التاني
    // لأن _sendMessage بيضيف رسالة المستخدم نفسه optimistically
    _hubConnection.on('ReceiveMessage', (args) {
      if (args != null && args.isNotEmpty) {
        final msg = MessageModel.fromJson(args[0] as Map<String, dynamic>);
        // تجاهل الـ echo لو كانت الرسالة للـ current user
        // (حسب الـ backend — لو السيرفر مش بيعمل echo للمرسل ابقى شيل الشرط ده)
        if (msg.senderId == widget.currentUserId) return;
        // منع إضافة نفس الرسالة مرتين
        if (_messages.any((m) => m.id == msg.id)) {
          return;
        }

        setState(() {
          _messages.add(msg);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    // ── Payment completed → unlock chat ──
    _hubConnection.on('ChatUnlocked', (_) {
      setState(() {
        _uiState = ChatUIState.fromStatus(ChatSessionStatus.active);
      });
    });

    // FIX #6 — error handling حوالين start()
    try {
      await _hubConnection.start();
      await _hubConnection.invoke(
        'JoinChatRoom',
        args: ['${widget.conversation.bookingId}'],
      );
    } catch (e) {
      // فشل الاتصال بـ SignalR — مش critical، الشاشة تشتغل بدونه
      debugPrint('SignalR connection failed: $e');
      // ممكن تظهر snackbar هنا لو عايز تعلم المستخدم
    }
  }

  Future<void> _leaveAndDisposeHub() async {
    try {
      await _hubConnection.invoke(
        'LeaveChatRoom',
        args: ['${widget.conversation.bookingId}'],
      );
      await _hubConnection.stop();
    } catch (_) {}
  }

  // ── Send Message ──────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || !_uiState.inputEnabled || _isSending) return;

    setState(() => _isSending = true);
    _msgController.clear();

    try {
      // FIX #1 — استخدام ChatService.sendMessage بدل http.post المباشر
      final sentMsg = await widget.chatService.sendMessage(
        conversationId: widget.conversation.id,
        body: text,
      );

      // FIX #4 — Optimistic update: نضيف الرسالة فورًا بعد نجاح الـ POST
      // بدل الانتظار لـ SignalR echo (اللي مش مضمون للمرسل نفسه)
      setState(() {
        _messages.add(sentMsg);
      });

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } on ChatServiceException catch (e) {
      _showError(e.message);

      _msgController.text = text;
      _msgController.selection = TextSelection.fromPosition(
        TextPosition(offset: _msgController.text.length),
      );
    } catch (_) {
      _showError('Failed to send message. Please try again.');

      _msgController.text = text;
      _msgController.selection = TextSelection.fromPosition(
        TextPosition(offset: _msgController.text.length),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ── Mark as Read ──────────────────────────────────────────
  // FIX #2 — نتحقق من _readMessageIds أولًا لمنع الـ duplicate requests
  Future<void> _markAsRead(int msgId) async {
    if (_readMessageIds.contains(msgId)) return;
    _readMessageIds.add(msgId);

    try {
      // FIX #1 — استخدام ChatService.markMessageAsRead
      // FIX #3 — ChatService بيتعامل مع plain text response تلقائيًا
      await widget.chatService.markMessageAsRead(
        conversationId: widget.conversation.id,
        messageId: msgId,
      );
    } catch (_) {
      // silent fail — مش critical
      // لو فشل نشيله من الـ set عشان يتجرب مرة تانية
      _readMessageIds.remove(msgId);
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildBottomBar()],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surfaceWhite,
      elevation: 0.5,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: _textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _Avatar(name: widget.conversation.otherParticipantName, radius: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.conversation.otherParticipantName,
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (_uiState.status == ChatSessionStatus.active)
                const Text(
                  'Active Chat',
                  style: TextStyle(
                    color: _onlineGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Message List ──────────────────────────────────────────
  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_outlined,
                size: 48,
                color: _textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMessages,
                style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Say hello! 👋',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMine = msg.senderId == widget.currentUserId;

        if (!isMine) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markAsRead(msg.id);
          });
        }

        return _MessageBubble(
          message: msg,
          isMine: isMine,
          guideName: widget.conversation.otherParticipantName,
        );
      },
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    // Read-only (Completed / Cancelled)
    if (_uiState.readOnlyBannerText != null) {
      return Container(
        width: double.infinity,
        color: _surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          _uiState.readOnlyBannerText!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _textSecondary, fontSize: 13),
        ),
      );
    }

    // Locked (PendingPayment)
    if (_uiState.lockedBannerText != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _lockedBg,
          border: Border.all(color: _lockedBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFFF9A825), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _uiState.lockedBannerText!,
                style: const TextStyle(color: Color(0xFF795548), fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    // Active input row
    return Container(
      color: _surfaceWhite,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(fontSize: 14, color: _textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Type a Message',
                  hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _msgController,
            builder: (_, value, __) {
              final hasText = value.text.trim().isNotEmpty;

              return IconButton(
                onPressed: (_isSending || !hasText) ? null : _sendMessage,
                icon:
                    _isSending
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: _primaryGreen,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(
                          Icons.send,
                          color: _primaryGreen,
                          size: 24,
                        ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final String guideName;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.guideName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            _Avatar(name: guideName, radius: 16),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? _bubbleTourist : _bubbleGuide,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isMine
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                  bottomRight:
                      isMine
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.messageText,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final double radius;
  const _Avatar({required this.name, this.radius = 26});

  Color _color(String n) {
    const colors = [
      Color(0xFF81C784),
      Color(0xFF64B5F6),
      Color(0xFFFFB74D),
      Color(0xFFBA68C8),
      Color(0xFF4DB6AC),
      Color(0xFFF06292),
    ];
    // FIX #5 — حماية من RangeError لو الاسم فاضي
    return colors[(n.isNotEmpty ? n.codeUnits.first : 0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color(name),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}
