import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/models/chat_message.dart';
import '../viewmodel/chat_viewmodel.dart';

/// Real-time chat view connected to the backend via REST + SignalR.
///
/// Accepts: conversationId, bookingId, otherParticipantName, status
///
/// UI State Enforcement:
///   PendingPayment → greyed-out input, locked banner
///   Active         → full interactive mode
///   Completed/Cancelled → read-only, closed banner
class GuideChatView extends StatefulWidget {
  final int conversationId;
  final int bookingId;
  final String otherParticipantName;
  final String status;

  const GuideChatView({
    super.key,
    required this.conversationId,
    required this.bookingId,
    required this.otherParticipantName,
    this.status = 'Active',
  });

  @override
  State<GuideChatView> createState() => _GuideChatViewState();
}

class _GuideChatViewState extends State<GuideChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatViewModel _vm = ChatViewModel();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.openConversation(
      widget.conversationId, 
      widget.bookingId,
      widget.status,
      widget.otherParticipantName,
    );

    _messageController.addListener(() {
      final typing = _messageController.text.trim().isNotEmpty;
      if (typing != _isTyping) {
        setState(() => _isTyping = typing);
      }
    });
  }

  void _onVmChanged() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _vm.leaveConversation();
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();

    final success = await _vm.sendMessage(text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.messagesError ?? 'Failed to send message'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  /// Current conversation status (may update from SignalR ChatUnlocked event).
  String get _status => _vm.activeConversation?.status ?? widget.status;

  bool get _isActive => _status == 'Active' || _status == 'Paid';
  bool get _isPendingPayment => _status == 'PendingPayment';
  bool get _isReadOnly => _status == 'Completed' || _status == 'Cancelled';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Status banner
          if (_isPendingPayment) _buildLockedBanner(),
          if (_isReadOnly) _buildClosedBanner(),

          // Messages area
          Expanded(child: _buildMessagesArea()),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              _getInitials(widget.otherParticipantName),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherParticipantName,
                style: AppTextStyles.heading3.copyWith(
                  color: const Color(0xFF2C3E50),
                  fontSize: 18,
                ),
              ),
              Text(
                _isActive ? 'Active' : _status,
                style: TextStyle(
                  color: _isActive
                      ? const Color(0xFF22C55E)
                      : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (_isActive)
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/guide-call',
                arguments: widget.otherParticipantName,
              );
            },
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.borderLight,
          height: 1.0,
        ),
      ),
    );
  }

  // ── Status Banners ──────────────────────────────────────────────────────

  Widget _buildLockedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chat is locked. Complete booking payment to start talking.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This trip has concluded. This chat is now closed and read-only.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Messages Area ───────────────────────────────────────────────────────

  Widget _buildMessagesArea() {
    if (_vm.isLoadingMessages) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_vm.messagesError != null && _vm.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                _vm.messagesError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _vm.openConversation(
                  widget.conversationId,
                  widget.bookingId,
                  widget.status,
                  widget.otherParticipantName,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (_vm.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.grey.shade300, size: 48),
            const SizedBox(height: 12),
            Text(
              _isActive
                  ? 'Say hello to ${widget.otherParticipantName}!'
                  : 'No messages yet',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _vm.messages.length,
      itemBuilder: (context, index) {
        final msg = _vm.messages[index];
        return _buildChatBubble(msg);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                _getInitials(widget.otherParticipantName),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.messageText,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, size: 18, color: Colors.blue),
            ),
          ],
        ],
      ),
    );
  }

  // ── Input Area ──────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    final bool inputEnabled = _isActive;

    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFE5E5E5),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputEnabled
                      ? const Color(0xFFF1F5F9)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.sentiment_satisfied_alt,
                        color: inputEnabled ? Colors.black : Colors.grey,
                        size: 24,
                      ),
                      onPressed: inputEnabled ? () {} : null,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: inputEnabled,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: inputEnabled
                              ? 'Type a Message'
                              : 'Chat is locked',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (inputEnabled)
                      IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: inputEnabled && _isTyping ? _sendMessage : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inputEnabled && _isTyping
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  _isTyping ? Icons.send : Icons.mic_none,
                  color: inputEnabled ? Colors.black : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatMessageTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }
}
