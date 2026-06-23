import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/chat_preview.dart';
import '../../../data/services/hold_request_service.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({super.key});

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  final TextEditingController _searchController = TextEditingController();
  final ChatViewModel _vm = ChatViewModel();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.loadConversations();

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isEmpty) {
        _vm.loadConversations();
      } else {
        _vm.searchConversations(query.trim());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: const Text(
              'Search',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'search',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_vm.isLoadingConversations) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_vm.conversationsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                _vm.conversationsError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _vm.loadConversations(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (_vm.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.grey.shade300, size: 64),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your chats with guides will appear here',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _vm.loadConversations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _vm.conversations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final chat = _vm.conversations[index];
          return InkWell(
            onTap: () async {
              if (chat.isPendingPayment) {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                
                try {
                  // Fetch all requests to find the one needing payment for this guide
                  final requests = await HoldRequestsService.instance.getMyRequests();
                  final pendingReq = requests.firstWhere(
                    (req) => req.guideName == chat.otherParticipantName && 
                             (req.status.toLowerCase() == 'accepted' || req.status.toLowerCase() == 'paymentpending'),
                  );
                  
                  // Pop loading
                  if (context.mounted) Navigator.pop(context);
                  
                  // Navigate to payment
                  if (context.mounted) {
                    Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {
                        'holdRequestId': pendingReq.id,
                        'guideName': pendingReq.guideName ?? '',
                        'totalPrice': pendingReq.totalPrice,
                        'currency': pendingReq.currency ?? 'EGP',
                      },
                    );
                  }
                } catch (e) {
                  // Pop loading and fallback to my requests
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not find payment details. Redirecting to My Requests.'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pushNamed(context, '/my-requests');
                  }
                }
                return;
              }

              Navigator.pushNamed(
                context,
                '/guide-chat',
                arguments: {
                  'conversationId': chat.id,
                  'bookingId': chat.bookingId,
                  'otherParticipantName': chat.otherParticipantName,
                  'status': chat.status,
                },
              );
            },
            child: _buildChatListItem(chat),
          );
        },
      ),
    );
  }

  Widget _buildChatListItem(ChatPreview chat) {
    final timeText = _formatTime(chat.lastMessage?.createdAt);

    return Row(
      children: [
        // Avatar with status indicator
        Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                _getInitials(chat.otherParticipantName),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (chat.isActive)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Name & Message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.otherParticipantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat.isPendingPayment)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (chat.isReadOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        chat.status,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                chat.lastMessage?.messageText ?? 'No messages yet',
                style: TextStyle(
                  color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Time & Unread Badge
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeText,
              style: TextStyle(
                color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(height: 22),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      // Today: show time
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $amPm';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
