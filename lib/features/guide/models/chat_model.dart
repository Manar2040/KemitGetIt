////////////////////////////////////////////////////////////////////////////////////
// ============================================================
// chat_models.dart
// KemitGetit Chat Engine — Complete Model Definitions
// Based on API v1.2.0 Documentation
// ============================================================

// ============================================================
// 1. ChatSessionStatus Enum
//    PendingPayment → Active → [Completed | Cancelled]
// ============================================================
enum ChatSessionStatus {
  pendingPayment, // 0 — chat locked, input disabled
  active, // 1 — fully interactive
  completed, // 2 — read-only
  cancelled, // 3 — read-only
}

extension ChatSessionStatusX on ChatSessionStatus {
  static ChatSessionStatus fromString(String value) {
    switch (value) {
      case 'PendingPayment':
        return ChatSessionStatus.pendingPayment;
      case 'Active':
        return ChatSessionStatus.active;
      case 'Completed':
        return ChatSessionStatus.completed;
      case 'Cancelled':
        return ChatSessionStatus.cancelled;
      default:
        return ChatSessionStatus.pendingPayment;
    }
  }

  String toJson() {
    switch (this) {
      case ChatSessionStatus.pendingPayment:
        return 'PendingPayment';
      case ChatSessionStatus.active:
        return 'Active';
      case ChatSessionStatus.completed:
        return 'Completed';
      case ChatSessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// هل الـ chat مقفول (مش active)?
  bool get isLocked => this == ChatSessionStatus.pendingPayment;

  /// هل الـ chat read-only (completed أو cancelled)?
  bool get isReadOnly =>
      this == ChatSessionStatus.completed ||
      this == ChatSessionStatus.cancelled;

  /// هل الـ chat شغال بالكامل?
  bool get isActive => this == ChatSessionStatus.active;
}

// ============================================================
// 2. MessageType Enum
// ============================================================
enum MessageType { text }

extension MessageTypeX on MessageType {
  static MessageType fromString(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      default:
        return MessageType.text;
    }
  }

  String toJson() => 'text';
}

// ============================================================
// 3. LastMessageModel
//    بييجي جوا ConversationModel كـ nested object
// ============================================================
class LastMessageModel {
  final int id;
  final int senderId;
  final String messageText;
  final DateTime createdAt;

  const LastMessageModel({
    required this.id,
    required this.senderId,
    required this.messageText,
    required this.createdAt,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      id: json['id'],
      senderId: json['senderId'],
      messageText: json['messageText'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'messageText': messageText,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ============================================================
// 4. MessageModel
//    بييجي من:
//      GET /api/chat/conversations            (جوا messages[])
//      GET /api/chat/conversations/{id}        (جوا messages[])
//      POST /api/chat/conversations/{id}/messages (response)
//      SignalR: "ReceiveMessage" event payload
// ============================================================
class MessageModel {
  final int id;
  final int senderId;
  final String messageText;
  final MessageType type;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.messageText,
    required this.type,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      messageText: json['messageText'] ?? json['body'] ?? '',
      type: MessageTypeX.fromString(json['type'] ?? 'text'),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'messageText': messageText,
    'type': type.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };
}

// ============================================================
// 5. ConversationModel
//    بييجي من:
//      GET /api/chat/conversations          (List)
//      GET /api/chat/conversations/{id}     (Single)
//      GET /api/chat/conversations/search   (List)
//
//    ✅ تم إضافة حقل messages اللي كان ناقص قبل كده،
//       رغم إن الـ API بترجعه فعليًا في كل الـ responses الثلاثة.
// ============================================================
class ConversationModel {
  final int id;
  final int bookingId;
  final ChatSessionStatus status;
  final String otherParticipantName;
  final int unreadCount;
  final LastMessageModel? lastMessage;
  final List<MessageModel> messages;

  const ConversationModel({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.otherParticipantName,
    required this.unreadCount,
    required this.messages,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      bookingId: json['bookingId'],
      status: ChatSessionStatusX.fromString(json['status'] ?? ''),
      otherParticipantName: json['otherParticipantName'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage:
          json['lastMessage'] != null
              ? LastMessageModel.fromJson(json['lastMessage'])
              : null,
      messages:
          (json['messages'] as List<dynamic>? ?? [])
              .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'status': status.toJson(),
    'otherParticipantName': otherParticipantName,
    'unreadCount': unreadCount,
    'lastMessage': lastMessage?.toJson(),
    'messages': messages.map((e) => e.toJson()).toList(),
  };

  /// نسخة مفيدة لو عايز تحدّث unreadCount أو الـ messages بعد إضافة رسالة جديدة
  /// من غير ما تعمل parsing تاني من الصفر.
  ConversationModel copyWith({
    int? unreadCount,
    List<MessageModel>? messages,
    LastMessageModel? lastMessage,
    ChatSessionStatus? status,
  }) {
    return ConversationModel(
      id: id,
      bookingId: bookingId,
      status: status ?? this.status,
      otherParticipantName: otherParticipantName,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      messages: messages ?? this.messages,
    );
  }
}

// ============================================================
// 6. SendMessageRequest
//    بيتبعت في: POST /api/chat/conversations/{id}/messages
// ============================================================
class SendMessageRequest {
  final String body;
  final MessageType type;

  const SendMessageRequest({required this.body, this.type = MessageType.text});

  Map<String, dynamic> toJson() => {'body': body, 'type': type.toJson()};
}

// ============================================================
// 7. UnreadCountModel
//    بييجي من: GET /api/chat/messages/unread
//    { "unreadCount": 4 }
// ============================================================
class UnreadCountModel {
  final int unreadCount;

  const UnreadCountModel({required this.unreadCount});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(unreadCount: json['unreadCount'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'unreadCount': unreadCount};
}

// ============================================================
// 8. ConversationsPageModel
//    Wrapper للـ paginated list من GET /api/chat/conversations
//    Query params: page (default 1), limit (default 20)
// ============================================================
class ConversationsPageModel {
  final List<ConversationModel> conversations;
  final int page;
  final int limit;

  const ConversationsPageModel({
    required this.conversations,
    required this.page,
    required this.limit,
  });

  /// بييجي الـ response كـ List مباشرة (مش wrapped في object)
  factory ConversationsPageModel.fromJson(
    List<dynamic> json, {
    int page = 1,
    int limit = 20,
  }) {
    return ConversationsPageModel(
      conversations: json.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList(),
      page: page,
      limit: limit,
    );
  }
}

// ============================================================
// 9. ProblemDetails (RFC 7807 Error Model)
//    بييجي من أي endpoint لما بيرجع 400/403/404 ... إلخ
//
//    ⚠️ ملاحظة مهمة: الـ backend عمليًا مش دايمًا بيرجع RFC7807 كامل:
//      - POST /messages/{msgId}/read  → بيرجع plain text عادي مش JSON
//          ("Could not mark message as read.")
//      - POST /conversations/{id}/close → بيرجع JSON لكن بمفتاح "error"
//          بدل "detail"  ({"error": "..."})
//
//    عشان كده fromJson بقى يقرأ "error" كـ fallback لو "detail" مش موجود،
//    والـ caller (الـ repository/service) لازم يتأكد من content-type
//    قبل ما يعمل jsonDecode، ولو كان plain text يبني ProblemDetails
//    بنفسه عن طريق fromPlainText.
// ============================================================
class ProblemDetails implements Exception {
  final String? type;
  final String title;
  final int status;
  final String detail;
  final String? instance;

  const ProblemDetails({
    this.type,
    required this.title,
    required this.status,
    required this.detail,
    this.instance,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    return ProblemDetails(
      type: json['type'],
      title: json['title'] ?? 'An error occurred',
      status: json['status'] ?? 400,
      // ✅ fallback لمفتاح "error" اللي بيستخدمه /close endpoint
      detail: json['detail'] ?? json['error'] ?? 'No detailed description provided.',
      instance: json['instance'],
    );
  }

  /// لاستخدامها لما يكون الـ response body مش JSON خالص
  /// (مثل /messages/{msgId}/read اللي بيرجع plain text)
  factory ProblemDetails.fromPlainText(String body, {int status = 400}) {
    return ProblemDetails(
      title: 'An error occurred',
      status: status,
      detail: body.isNotEmpty ? body : 'No detailed description provided.',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'status': status,
    'detail': detail,
    'instance': instance,
  };

  @override
  String toString() => 'ProblemDetails[$status]: $title — $detail';

  /// Helper: هل الـ error ده بسبب الـ chat مش active؟
  bool get isChatLocked =>
      detail.toLowerCase().contains('payment') ||
      detail.toLowerCase().contains('not active');
}

// ============================================================
// 10. SignalR Event Payloads
//     الـ objects اللي بتييجي من الـ SignalR hub events
// ============================================================

/// "ReceiveMessage" event — نفس شكل MessageModel
/// استخدم:  MessageModel.fromJson(arguments[0] as Map<String, dynamic>)

/// "ChatUnlocked" event — مفيش payload، بس notification إن الـ chat اتفتح
/// استخدم: toggleChatInputAvailability(enabled: true)

// ============================================================
// 11. ChatUIState
//     Helper model للـ Flutter UI layer
//     بيحدد إيه اللي يتعرض حسب الـ status
// ============================================================
class ChatUIState {
  final ChatSessionStatus status;
  final bool inputEnabled;
  final bool showInputRow;
  final String? lockedBannerText;
  final String? readOnlyBannerText;

  const ChatUIState({
    required this.status,
    required this.inputEnabled,
    required this.showInputRow,
    this.lockedBannerText,
    this.readOnlyBannerText,
  });

  factory ChatUIState.fromStatus(ChatSessionStatus status) {
    switch (status) {
      case ChatSessionStatus.pendingPayment:
        return const ChatUIState(
          status: ChatSessionStatus.pendingPayment,
          inputEnabled: false,
          showInputRow: false,
          lockedBannerText:
              'Chat is locked. Complete booking payment to start talking.',
        );
      case ChatSessionStatus.active:
        return const ChatUIState(
          status: ChatSessionStatus.active,
          inputEnabled: true,
          showInputRow: true,
        );
      case ChatSessionStatus.completed:
      case ChatSessionStatus.cancelled:
        return ChatUIState(
          status: status,
          inputEnabled: false,
          showInputRow: false,
          readOnlyBannerText:
              'This trip has concluded. This chat is now closed and read-only.',
        );
    }
  }
}