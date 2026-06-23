/// Represents a single conversation thread from the backend.
///
/// Maps to: GET /api/chat/conversations response items.
class ChatPreview {
  final int id;
  final int bookingId;
  final String status; // "PendingPayment", "Active", "Completed", "Cancelled"
  final String otherParticipantName;
  final int unreadCount;
  final ChatLastMessage? lastMessage;

  ChatPreview({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.otherParticipantName,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      status: json['status'] as String? ?? 'Active',
      otherParticipantName: _formatName(json['otherParticipantName'] as String? ?? ''),
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] != null
          ? ChatLastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
    );
  }

  static String _formatName(String name) {
    if (name.contains('@')) {
      final localPart = name.split('@')[0];
      return localPart.replaceAll(RegExp(r'[._]'), ' ').split(' ').map((w) {
        if (w.isEmpty) return '';
        return w[0].toUpperCase() + w.substring(1).toLowerCase();
      }).join(' ');
    }
    return name;
  }

  /// Whether the chat is fully interactive.
  bool get isActive => status == 'Active';

  /// Whether the chat is locked awaiting payment.
  bool get isPendingPayment => status == 'PendingPayment';

  /// Whether the chat is read-only (completed or cancelled).
  bool get isReadOnly => status == 'Completed' || status == 'Cancelled';

  /// Returns a copy with updated fields.
  ChatPreview copyWith({
    int? id,
    int? bookingId,
    String? status,
    String? otherParticipantName,
    int? unreadCount,
    ChatLastMessage? lastMessage,
  }) {
    return ChatPreview(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      status: status ?? this.status,
      otherParticipantName: otherParticipantName ?? this.otherParticipantName,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

/// The last message snippet inside a conversation preview.
class ChatLastMessage {
  final int id;
  final int senderId;
  final String messageText;
  final DateTime createdAt;

  ChatLastMessage({
    required this.id,
    required this.senderId,
    required this.messageText,
    required this.createdAt,
  });

  factory ChatLastMessage.fromJson(Map<String, dynamic> json) {
    return ChatLastMessage(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      messageText: json['messageText'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
