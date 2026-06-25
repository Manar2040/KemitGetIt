import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../core/constants/api_constants.dart';

class AiMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  AiMessage({required this.text, required this.isMe, required this.time});
}

class KemitAiViewModel extends ChangeNotifier {
  List<AiMessage> messages = [];
  bool isLoading = false;
  String? errorMessage; // Added to match the project's standardized architecture style

  // ── Fetch Chat History using Custom ApiClient ──────────────────────────────
  Future<void> fetchChatHistory() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ApiClient handles base URL, headers, and token injection automatically
      final List<dynamic> data = await ApiClient.instance.get(ApiConstants.aiChatHistory, auth: true);
      
      messages = data.map((msg) {
        return AiMessage(
          text: msg['content'] ?? '',
          isMe: msg['role'] == 'user',
          time: DateTime.parse(msg['createdAt'] ?? DateTime.now().toString()),
        );
      }).toList();
    } on ApiException catch (e) {
      errorMessage = e.userMessage; // Capture direct standardized backend errors
    } catch (_) {
      errorMessage = 'Could not load chat history. Please check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Send Message using Custom ApiClient ─────────────────────────────────────
  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    errorMessage = null;

    // Locally inject client bubble for fast reactive UI response
    messages.add(AiMessage(text: text.trim(), isMe: true, time: DateTime.now()));
    notifyListeners();

    isLoading = true;
    notifyListeners();

    try {
      final responseData = await ApiClient.instance.post(
        ApiConstants.aiChatSend,
        auth: true,
        body: {
          'userMessage': text.trim(),
        },
      );

      // Extract response fields returned by .NET KemiChatResponseDto structure
      String reply = responseData['content'] ?? "Sorry, I could not process that request.";
      
      messages.add(AiMessage(text: reply, isMe: false, time: DateTime.now()));
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      _addErrorBubble(customError: e.userMessage);
    } catch (_) {
      _addErrorBubble();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _addErrorBubble({String? customError}) {
    messages.add(AiMessage(
      text: customError ?? "Connection error. Please make sure the AI server is running.",
      isMe: false,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}