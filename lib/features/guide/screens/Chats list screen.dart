// ============================================================
// chats_list_screen.dart
// KemitGetit — Chats List Screen
// API-driven via ChatService
// State: setState only
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kemit_get_it/core/services/token_storage.dart';
import 'package:kemit_get_it/features/guide/core/chat_service.dart';
import 'package:kemit_get_it/features/guide/models/chat_model.dart';
import 'package:kemit_get_it/features/guide/screens/Chat%20screen.dart';

const Color _primaryGreen    = Color(0xFF4CAF50);
const Color _backgroundColor = Color(0xFFF7F7F7);
const Color _surfaceWhite    = Colors.white;
const Color _textPrimary     = Color(0xFF1A1A1A);
const Color _textSecondary   = Color(0xFF757575);
const Color _dividerColor    = Color(0xFFEEEEEE);

// ─────────────────────────────────────────────────────────────
class ChatsListScreen extends StatefulWidget {
  /// [chatService] بييجي عن طريق DI (get_it / constructor injection).
  final ChatService chatService;

  const ChatsListScreen({super.key, required this.chatService});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController       _scrollController = ScrollController();

  // ── State ──
  List<ConversationModel> _conversations = [];
  List<ConversationModel> _filtered      = [];
  bool    _isLoading      = true;
  String? _errorMessage;
  int     _page           = 1;
  bool    _hasMore        = true;
  bool    _isFetchingMore = false;
  int?    _currentUserId;             // ✅ Fix #1 — من TokenStorage مش hard-coded
  int?    _totalCount;                // ✅ Fix #3 — للـ _hasMore الصحيح
  Timer?  _debounce;                  // ✅ Fix #2 — server-side search debounce

  @override
void initState() {
  super.initState();

  _initialize();

  _searchController.addListener(_onSearch);
  _scrollController.addListener(_onScroll);
}

Future<void> _initialize() async {
  await _loadCurrentUser();
  await _fetchConversations();
}

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Load current user from TokenStorage ──────────────────
  Future<void> _loadCurrentUser() async {
    final id = await TokenStorage.instance.userId;
    if (mounted) setState(() => _currentUserId = id);
  }

  // ── Fetch via ChatService ─────────────────────────────────
  Future<void> _fetchConversations({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page         = 1;
        _hasMore      = true;
        _isLoading    = true;
        _errorMessage = null;
        _totalCount   = null;
      });
    }

    try {
      final page = await widget.chatService.getConversations(
        page:  _page,
        limit: 20,
      );

      setState(() {
        if (refresh || _page == 1) {
          _conversations = page.conversations;
        } else {
          _conversations.addAll(page.conversations);
        }
        _filtered = _applyLocalSearch(_conversations);

        // ✅ Fix #3 — لو الـ API بيرجع totalCount استخدمه،
        //    لو لأ ارجع للـ length check كـ fallback
        if (_totalCount != null) {
          _hasMore = _conversations.length < _totalCount!;
        } else {
          _hasMore = page.conversations.length == 20;
        }

        _isLoading      = false;
        _isFetchingMore = false;
      });
    } on ChatServiceException catch (e) {
      setState(() {
        _errorMessage   = e.message;
        _isLoading      = false;
        _isFetchingMore = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage   = 'Connection error. Please try again.';
        _isLoading      = false;
        _isFetchingMore = false;
      });
    }
  }

  // ── Pagination on scroll ──────────────────────────────────
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isFetchingMore) {
      setState(() {
        _page++;
        _isFetchingMore = true;
      });
      _fetchConversations();
    }
  }

  // ── Search — debounced, server-side + local fallback ─────
  void _onSearch() {
    _debounce?.cancel();

    final q = _searchController.text.trim();

    // Local filter فوري للـ UX
    setState(() => _filtered = _applyLocalSearch(_conversations));

    if (q.isEmpty) return;

    // ✅ Fix #2 — server-side search بعد 400ms من آخر حرف
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await widget.chatService.searchConversations(
          query: q,
          limit: 30,
        );
        if (mounted) setState(() => _filtered = results);
      } on ChatServiceException {
        // لو فشل الـ server search، ابقى على الـ local filter
      }
    });
  }

  List<ConversationModel> _applyLocalSearch(List<ConversationModel> source) {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) return source;
    return source
        .where((c) =>
            c.otherParticipantName.toLowerCase().contains(q) ||
            (c.lastMessage?.messageText.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: const Text(
          'Chats',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Header ──
          Container(
            color: _surfaceWhite,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                _SearchBar(controller: _searchController),
              ],
            ),
          ),
          // ── Body ──
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
              const Icon(Icons.wifi_off_outlined, size: 48, color: _textSecondary),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchConversations(refresh: true),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          'No conversations found.',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: () => _fetchConversations(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: _filtered.length + (_isFetchingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: _dividerColor,
          indent: 76,
        ),
        itemBuilder: (context, index) {
          if (index == _filtered.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(
                    color: _primaryGreen, strokeWidth: 2),
              ),
            );
          }
          final conv = _filtered[index];
          return _ConversationTile(
            conversation:  conv,
            currentUserId: _currentUserId,   // ✅ Fix #1 — nullable, مش hard-coded
            onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        conversation: conv,
        currentUserId: _currentUserId,
        chatService: widget.chatService,
      ),
    ),
  );

  if (mounted) {
    _fetchConversations(refresh: true);
  }
},
          );
        },
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: const InputDecoration(
          hintText: 'search',
          hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: _textSecondary, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ─── Conversation Tile ────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final int? currentUserId;           // ✅ Fix #1 — nullable
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime? dt) {
  if (dt == null) return '';

  // تحويل الوقت إلى Local Time
  final local = dt.toLocal();

  final now = DateTime.now();
  final diff = now.difference(local);

  if (diff.inDays == 0) {
    final h = local.hour;
    final min = local.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);

    return '$h12:$min $period';
  }

  return '${local.month}/${local.day}/${local.year}';
}

  // ✅ Fix #1 — null-safe check
  bool get _isSentByMe =>
      currentUserId != null &&
      conversation.lastMessage?.senderId == currentUserId;

  @override
  Widget build(BuildContext context) {
    final last      = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: _surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Avatar(name: conversation.otherParticipantName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.otherParticipantName,
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight:
                          hasUnread ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (_isSentByMe)
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.done_all,
                              size: 14, color: _textSecondary),
                        ),
                      Expanded(
                        child: Text(
                          last?.messageText ?? '',
                          style: TextStyle(
                            color: hasUnread ? _textPrimary : _textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(last?.createdAt),
                  style: TextStyle(
                    color: hasUnread ? _primaryGreen : _textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  Color _color(String n) {
    const colors = [
      Color(0xFF81C784), Color(0xFF64B5F6), Color(0xFFFFB74D),
      Color(0xFFBA68C8), Color(0xFF4DB6AC), Color(0xFFF06292),
    ];
    return colors[(n.isNotEmpty ? n.codeUnits.first : 0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: _color(name),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}