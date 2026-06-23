import '../models/chat_preview.dart';
import '../models/chat_message.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/services/token_storage.dart';

/// REST API service for the Chat feature.
///
/// Endpoints:
///   GET  /api/chat/conversations                         → [getConversations]
///   GET  /api/chat/conversations/{id}                    → [getConversation]
///   GET  /api/chat/conversations/search?q=&limit=        → [searchConversations]
///   POST /api/chat/send                                     → [sendMessage]
///   PUT  /api/chat/{id}/read                                → [markMessageRead]
///   GET  /api/chat/messages/unread                        → [getUnreadCount]
///   POST /api/chat/conversations/{id}/close               → [closeConversation]
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _client = ApiClient.instance;

  // ── Conversations ─────────────────────────────────────────────────────────

  /// Fetches paginated conversations for the authenticated user.
  Future<List<ChatPreview>> getConversations({int page = 1, int limit = 20}) async {
    final response = await _client.get(
      ApiConstants.chatConversations,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    if (response is List) {
      return response
          .map((e) => ChatPreview.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches a single conversation's metadata.
  Future<ChatPreview> getConversation(int id) async {
    final response = await _client.get(ApiConstants.chatConversation(id));
    return ChatPreview.fromJson(response as Map<String, dynamic>);
  }

  /// Searches conversations by participant username.
  Future<List<ChatPreview>> searchConversations(String query, {int limit = 10}) async {
    final response = await _client.get(
      ApiConstants.chatSearch,
      queryParams: {
        'q': query,
        'limit': limit.toString(),
      },
    );
    if (response is List) {
      return response
          .map((e) => ChatPreview.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  /// Fetches historical messages for a conversation.
  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final userId = await TokenStorage.instance.userId ?? 0;
    try {
      final response = await _client.get(
        ApiConstants.chatConversation(conversationId),
        auth: true,
      );
      
      List<dynamic> messagesList = [];
      if (response is List) {
        messagesList = response;
      } else if (response is Map<String, dynamic> && response.containsKey('messages')) {
        messagesList = response['messages'] as List<dynamic>;
      }

      return messagesList
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>, userId))
          .toList();
    } catch (e) {
      if (e.toString().contains('405') || e.toString().contains('Method Not Allowed')) {
        return [];
      }
      rethrow;
    }
  }

  /// Sends a text message to a conversation.
  /// Returns the created MessageDto from the server.
  Future<ChatMessage> sendMessage(int conversationId, String body) async {
    final userId = await TokenStorage.instance.userId ?? 0;
    final response = await _client.post(
      ApiConstants.chatMessages(conversationId),
      body: {'body': body, 'type': 'text'},
      auth: true,
    );
    return ChatMessage.fromJson(response as Map<String, dynamic>, userId);
  }

  /// Marks a specific message as read.
  Future<void> markMessageRead(int conversationId, int messageId) async {
    await _client.post(
      ApiConstants.chatMarkRead(conversationId, messageId),
      auth: true,
    );
  }

  /// Returns total unread message count across all conversations.
  Future<int> getUnreadCount() async {
    final response = await _client.get(ApiConstants.chatUnreadCount);
    if (response is Map<String, dynamic>) {
      return response['unreadCount'] as int? ?? 0;
    }
    return 0;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Closes (completes) a conversation. Tourist-initiated.
  Future<void> closeConversation(int conversationId) async {
    await _client.post(
      ApiConstants.chatClose(conversationId),
      auth: true,
    );
  }
}
