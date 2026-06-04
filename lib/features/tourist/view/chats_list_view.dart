import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/chat_preview.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({super.key});

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mock data representing the conversations in the mockup
  final List<ChatPreview> _mockChats = [
    ChatPreview(
      id: '1',
      name: 'Ahmed Nasser',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100',
      lastMessage: 'See you tomorrow',
      time: '2:02 AM',
      unreadCount: 2,
    ),
    ChatPreview(
      id: '2',
      name: 'Arwa Gamal',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      lastMessage: 'our pickup driver will arrive in 10 minutes',
      time: '1:40 AM',
      unreadCount: 1,
    ),
    ChatPreview(
      id: '3',
      name: 'Karim Mohamed',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      lastMessage: 'Thanks! See you at 10am.',
      time: '12:50 AM',
      isReadByMe: true,
    ),
    ChatPreview(
      id: '4',
      name: 'Amira Hassan',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      lastMessage: 'Can we reschedule to Sunday?',
      time: '11:50 PM',
      isReadByMe: true,
    ),
    ChatPreview(
      id: '5',
      name: 'Ahmed Ayman',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      lastMessage: 'Perfect! I\'ll bring the group at 3PM',
      time: '10/11/2025',
      isReadByMe: true,
    ),
    ChatPreview(
      id: '6',
      name: 'Youssef Mohamed',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      lastMessage: 'Please bring comfortable shoes for the hike',
      time: '9/10/2025',
      unreadCount: 4,
    ),
    ChatPreview(
      id: '7',
      name: 'Nour',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      lastMessage: 'Do we need to pay in advance?',
      time: '7/9/2025',
      isReadByMe: true,
    ),
  ];

  List<ChatPreview> get _filteredChats {
    if (_searchQuery.isEmpty) return _mockChats;
    return _mockChats.where((chat) => chat.name.toLowerCase().contains(_searchQuery)).toList();
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
            // Need to determine if this pops correctly when inside a bottom nav tab,
            // or if it should switch tabs. Assuming a pop or doing nothing if at root.
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

          // Chat List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredChats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      '/guide-chat', 
                      arguments: chat.id,
                    );
                  },
                  child: _buildChatListItem(chat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(ChatPreview chat) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(chat.avatarUrl),
        ),
        const SizedBox(width: 16),
        
        // Name & Message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (chat.isReadByMe) ...[
                    const Icon(Icons.done_all, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      chat.lastMessage,
                      style: TextStyle(
                        color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
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
        
        // Time & Unread Badge
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat.time,
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
                  color: Color(0xFF4ADE80), // green-400
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
              const SizedBox(height: 22), // placeholder to maintain vertical alignment
          ],
        ),
      ],
    );
  }
}
