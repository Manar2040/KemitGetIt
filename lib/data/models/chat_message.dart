/// Represents a single chat message from the backend's MessageDto.
///
/// Maps to: POST /api/chat/conversations/{id}/messages response
///          and SignalR "ReceiveMessage" events.
class ChatMessage {
  final int id;
  final int senderId;
  final String messageText;
  final DateTime createdAt;
  final String type; // "text"
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.messageText,
    required this.createdAt,
    this.type = 'text',
    required this.isMe,
  });

  /// Parse from backend JSON. Requires [currentUserId] to determine [isMe].
  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    final senderId = json['senderId'] as int;
    return ChatMessage(
      id: json['id'] as int,
      senderId: senderId,
      messageText: json['messageText'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String? ?? 'text',
      isMe: senderId == currentUserId,
    );
  }

  /// Create a local optimistic message before server confirmation.
  factory ChatMessage.optimistic({
    required String text,
    required int currentUserId,
  }) {
    return ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch, // temp negative id
      senderId: currentUserId,
      messageText: text,
      createdAt: DateTime.now(),
      type: 'text',
      isMe: true,
    );
  }
}
