enum MessageType {
  text,
  audio,
}

class ChatMessage {
  final String id;
  final String? text; // Used for text messages
  final MessageType type;
  final DateTime time;
  final bool isMe;
  final String? reaction; // e.g., '❤️', '👍', null if no reaction
  final Duration? audioDuration; // Used for audio messages

  ChatMessage({
    required this.id,
    this.text,
    required this.type,
    required this.time,
    required this.isMe,
    this.reaction,
    this.audioDuration,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageType? type,
    DateTime? time,
    bool? isMe,
    String? reaction,
    Duration? audioDuration,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      reaction: reaction ?? this.reaction,
      audioDuration: audioDuration ?? this.audioDuration,
    );
  }
}
