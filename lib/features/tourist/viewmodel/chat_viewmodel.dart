import 'package:flutter/material.dart';
import '../../../data/models/chat_preview.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/services/chat_service.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/signalr_chat_service.dart';
import '../../../core/services/token_storage.dart';

/// ViewModel for the Chat feature.
///
/// Manages two levels of state:
///   1. **Conversations list** — loaded in the ChatsListView
///   2. **Active chat session** — messages, real-time events, and send actions
class ChatViewModel extends ChangeNotifier {
  final _chatService = ChatService.instance;
  final _signalR = SignalRChatService.instance;

  // ── Conversations list state ──────────────────────────────────────────────
  List<ChatPreview> conversations = [];
  bool isLoadingConversations = false;
  String? conversationsError;

  // ── Active chat state ─────────────────────────────────────────────────────
  ChatPreview? activeConversation;
  List<ChatMessage> messages = [];
  bool isLoadingMessages = false;
  bool isSending = false;
  String? messagesError;

  int _currentUserId = 0;

  // ── Conversations ─────────────────────────────────────────────────────────

  /// Fetches the list of conversations for the authenticated user.
  Future<void> loadConversations() async {
    isLoadingConversations = true;
    conversationsError = null;
    notifyListeners();

    try {
      conversations = await _chatService.getConversations();
    } on ApiException catch (e) {
      conversationsError = e.userMessage;
    } catch (e) {
      conversationsError = 'Failed to load conversations.';
    } finally {
      isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Searches conversations by participant name.
  Future<void> searchConversations(String query) async {
    if (query.trim().isEmpty) {
      await loadConversations();
      return;
    }

    isLoadingConversations = true;
    conversationsError = null;
    notifyListeners();

    try {
      conversations = await _chatService.searchConversations(query);
    } on ApiException catch (e) {
      conversationsError = e.userMessage;
    } catch (e) {
      conversationsError = 'Search failed.';
    } finally {
      isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Returns the global unread message count (for badges).
  Future<int> getUnreadCount() async {
    try {
      return await _chatService.getUnreadCount();
    } catch (_) {
      return 0;
    }
  }

  // ── Active Chat Session ───────────────────────────────────────────────────

  /// Opens a conversation: sets metadata, loads messages, joins SignalR room.
  Future<void> openConversation(int conversationId, int bookingId, String status, String otherParticipantName) async {
    isLoadingMessages = true;
    messagesError = null;
    messages = [];
    
    // Set active conversation from passed arguments
    activeConversation = ChatPreview(
      id: conversationId,
      bookingId: bookingId,
      status: status,
      otherParticipantName: otherParticipantName,
    );
    notifyListeners();

    // Get current user ID for isMe computation
    _currentUserId = await TokenStorage.instance.userId ?? 0;

    try {
      // Fetch historical messages using the new endpoint confirmed by backend
      messages = await _chatService.getMessages(conversationId);
      notifyListeners();

      // Connect SignalR and join the room
      await _signalR.connect();
      _signalR.onMessageReceived = _onRealTimeMessage;
      _signalR.onChatUnlocked = _onChatUnlocked;
      await _signalR.joinRoom(bookingId);
    } on ApiException catch (e) {
      messagesError = e.userMessage;
    } catch (e) {
      messagesError = 'Failed to load messages.';
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Sends a text message to the active conversation.
  Future<bool> sendMessage(String body) async {
    if (activeConversation == null || body.trim().isEmpty) return false;

    // Optimistic update: add message locally immediately
    final optimistic = ChatMessage.optimistic(
      text: body.trim(),
      currentUserId: _currentUserId,
    );
    messages.add(optimistic);
    isSending = true;
    notifyListeners();

    try {
      final serverMsg = await _chatService.sendMessage(
        activeConversation!.id,
        body.trim(),
      );
      // Replace optimistic message with server-confirmed message
      final idx = messages.indexOf(optimistic);
      if (idx != -1) {
        messages[idx] = serverMsg;
      }
      return true;
    } on ApiException catch (e) {
      // Remove optimistic message on failure
      messages.remove(optimistic);
      messagesError = e.userMessage;
      return false;
    } catch (e) {
      messages.remove(optimistic);
      messagesError = 'Failed to send message.';
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  /// Leaves the active conversation's SignalR room. Call on dispose.
  Future<void> leaveConversation() async {
    if (activeConversation != null) {
      await _signalR.leaveRoom(activeConversation!.bookingId);
    }
    _signalR.onMessageReceived = null;
    _signalR.onChatUnlocked = null;
    activeConversation = null;
    messages = [];
  }

  /// Closes (completes) the active conversation.
  Future<bool> closeConversation() async {
    if (activeConversation == null) return false;
    try {
      await _chatService.closeConversation(activeConversation!.id);
      activeConversation = activeConversation!.copyWith(status: 'Completed');
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      messagesError = e.userMessage;
      notifyListeners();
      return false;
    } catch (_) {
      messagesError = 'Failed to close conversation.';
      notifyListeners();
      return false;
    }
  }

  // ── Real-time Event Handlers ──────────────────────────────────────────────

  void _onRealTimeMessage(Map<String, dynamic> messageDto) {
    final msg = ChatMessage.fromJson(messageDto, _currentUserId);
    // Avoid duplicates
    if (!messages.any((m) => m.id == msg.id)) {
      messages.add(msg);
      notifyListeners();
    }
  }

  void _onChatUnlocked() {
    if (activeConversation != null) {
      activeConversation = activeConversation!.copyWith(status: 'Active');
      notifyListeners();
    }
  }
}
