import 'package:dio/dio.dart';
import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/chat_model.dart';

class ChatServiceException implements Exception {
  final ProblemDetails problemDetails;
  final int statusCode;

  const ChatServiceException(
    this.problemDetails,
    this.statusCode,
  );

  String get message => problemDetails.detail;

  @override
  String toString() {
    return 'ChatServiceException[$statusCode]: ${problemDetails.detail}';
  }
}

class ChatService {
  ChatService();

  // ============================================================
  // GET /api/chat/conversations?page=&limit=
  // ============================================================
  Future<ConversationsPageModel> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.get(
        '/api/chat/conversations?page=$page&limit=$limit',
      );

      final List<dynamic> jsonList = response.data;

      return ConversationsPageModel.fromJson(
        jsonList,
        page: page,
        limit: limit,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // GET /api/chat/conversations/{id}
  // ============================================================
  Future<ConversationModel> getConversationById(int id) async {
    try {
      final response = await ApiService.get(
        '/api/chat/conversations/$id',
      );

      return ConversationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // GET /api/chat/conversations/search
  // ============================================================
  Future<List<ConversationModel>> searchConversations({
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        '/api/chat/conversations/search?q=$query&limit=$limit',
      );

      final List<dynamic> jsonList = response.data;

      return jsonList
          .map(
            (e) => ConversationModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // POST /api/chat/conversations/{id}/messages
  // ============================================================
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String body,
    MessageType type = MessageType.text,
  }) async {
    try {
      final request = SendMessageRequest(
        body: body,
        type: type,
      );

      final response = await ApiService.post(
        '/api/chat/conversations/$conversationId/messages',
        request.toJson(),
      );

      return MessageModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // POST /api/chat/conversations/{id}/messages/{msgId}/read
  // ============================================================
  Future<void> markMessageAsRead({
  required int conversationId,
  required int messageId,
}) async {
  try {
    await ApiService.post(
      '/api/chat/conversations/$conversationId/messages/$messageId/read',
      null,
    );
  } on DioException catch (e) {
    throw _handleDioError(e);
  }
}

  // ============================================================
  // GET /api/chat/messages/unread
  // ============================================================
  Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.get(
        '/api/chat/messages/unread',
      );

      return UnreadCountModel.fromJson(
        response.data,
      ).unreadCount;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // POST /api/chat/conversations/{id}/close
  // ============================================================
  Future<void> closeConversation(int conversationId) async {
  try {
    await ApiService.post(
      '/api/chat/conversations/$conversationId/close',
      null,
    );
  } on DioException catch (e) {
    throw _handleDioError(e);
  }
}

  // ============================================================
  // Error Handler
  // ============================================================
  ChatServiceException _handleDioError(
    DioException e,
  ) {
    final statusCode = e.response?.statusCode ?? 500;
    final data = e.response?.data;

    try {
      if (data is Map<String, dynamic>) {
        return ChatServiceException(
          ProblemDetails.fromJson(data),
          statusCode,
        );
      }

      return ChatServiceException(
        ProblemDetails.fromPlainText(
          data?.toString() ?? 'Unknown error',
          status: statusCode,
        ),
        statusCode,
      );
    } catch (_) {
      return ChatServiceException(
        ProblemDetails.fromPlainText(
          e.message ?? 'Unknown error',
          status: statusCode,
        ),
        statusCode,
      );
    }
  }
}