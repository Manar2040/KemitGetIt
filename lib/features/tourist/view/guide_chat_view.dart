import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/models/chat_message.dart';

class GuideChatView extends StatefulWidget {
  final String guideId;
  const GuideChatView({super.key, required this.guideId});

  @override
  State<GuideChatView> createState() => _GuideChatViewState();
}

class _GuideChatViewState extends State<GuideChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isRecording = false;

  // Mock messages using the new model
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      type: MessageType.text,
      text: 'Hi! Welcome to your trip planning chat 👋\nHow can I help you today?',
      time: DateTime.now().subtract(const Duration(minutes: 60)),
      isMe: false,
    ),
    ChatMessage(
      id: '2',
      type: MessageType.text,
      text: 'Hello! I\'m interested in the Luxor & Aswan trip. Can you tell me what\'s included?',
      time: DateTime.now().subtract(const Duration(minutes: 55)),
      isMe: true,
    ),
    ChatMessage(
      id: '3',
      type: MessageType.text,
      text: 'Sure! The package includes:\n• Hotel accommodation\n• Nile cruise\n• Transportation\n• Guided tours to temples\n• Breakfast and lunch',
      time: DateTime.now().subtract(const Duration(minutes: 52)),
      isMe: false,
    ),
    ChatMessage(
      id: '4',
      type: MessageType.text,
      text: 'That sounds amazing 🤩\nIs it possible to customize the trip a bit?',
      time: DateTime.now().subtract(const Duration(minutes: 45)),
      isMe: true,
      reaction: '👍',
    ),
    ChatMessage(
      id: '5',
      type: MessageType.text,
      text: 'Absolutely! You can extend the stay or add extra activities like a hot air balloon ride 🎈',
      time: DateTime.now().subtract(const Duration(minutes: 44)),
      isMe: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          type: MessageType.text,
          text: _messageController.text.trim(),
          time: DateTime.now(),
          isMe: true,
        ),
      );
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _toggleRecording() {
    if (_isRecording) {
      // Stop recording and add mock audio message
      setState(() {
        _isRecording = false;
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            type: MessageType.audio,
            time: DateTime.now(),
            isMe: true,
            audioDuration: const Duration(seconds: 4),
          ),
        );
      });
      _scrollToBottom();
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _addReaction(String messageId, String emoji) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Toggle if same reaction, otherwise set new
        final currentReaction = _messages[index].reaction;
        _messages[index] = _messages[index].copyWith(
          reaction: currentReaction == emoji ? null : emoji,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildLocationBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
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
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ahmed Nasser', // Hardcoded as per mockup
                style: AppTextStyles.heading3.copyWith(color: const Color(0xFF2C3E50), fontSize: 18),
              ),
              const Text(
                'online',
                style: TextStyle(
                  color: Color(0xFF22C55E), // green-500
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(
              context, 
              '/guide-call',
              arguments: 'Ahmed Nasser',
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

  Widget _buildLocationBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB0915E), // Gold/Brown color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600', // Mock map image
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  color: Colors.white.withOpacity(0.5), // fade map slightly
                  colorBlendMode: BlendMode.screen,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2), // Dark overlay for text readability
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                child: Row(
                  children: const [
                    Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Track Live Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/live-tracking');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text(
                'Open Map',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final String avatarUrl = message.isMe 
      ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100' // tourist avatar
      : 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100'; // guide avatar

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onLongPress: () => _showReactionOptions(context, message),
        child: Row(
          mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isMe ? const Color(0xFFF1F5F9) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: message.type == MessageType.audio
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow, color: Color(0xFFB0915E)),
                              const SizedBox(width: 8),
                              Container(
                                width: 100,
                                height: 3,
                                color: const Color(0xFFB0915E),
                              ),
                              const SizedBox(width: 8),
                              Text('${message.audioDuration?.inSeconds ?? 0}s', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          )
                        : Text(
                            message.text ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                  ),
                  if (message.reaction != null)
                    Positioned(
                      bottom: -10,
                      right: message.isMe ? 8 : null,
                      left: !message.isMe ? 8 : null,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(message.reaction!, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                ],
              ),
            ),
            if (message.isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReactionOptions(BuildContext context, ChatMessage message) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final emojis = ['❤️', '👍', '😂', '😮', '😢'];

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      items: emojis.map((emoji) {
        return PopupMenuItem<String>(
          value: emoji,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        );
      }).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
    ).then((selectedEmoji) {
      if (selectedEmoji != null) {
        _addReaction(message.id, selectedEmoji);
      }
    });
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFE5E5E5), // matching the outer grey background area from mockup
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // light gray input bg
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.black, size: 24),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: _isRecording
                          ? const Center(
                              child: Text(
                                'Recording Audio...',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            )
                          : TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Type a Message',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                              ),
                            ),
                    ),
                    if (!_isRecording)
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.black54, size: 20),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isTyping ? _sendMessage : _toggleRecording,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.transparent,
                ),
                child: Icon(
                  _isTyping ? Icons.send : (_isRecording ? Icons.stop : Icons.mic_none),
                  color: _isRecording ? Colors.red : Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
