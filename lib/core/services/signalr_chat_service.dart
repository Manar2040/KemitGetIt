import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';

/// Manages the SignalR hub connection for real-time chat.
///
/// Hub endpoint: /api/chatHub
/// Server methods invoked: JoinChatRoom, LeaveChatRoom
/// Client events listened: ReceiveMessage, ChatUnlocked
class SignalRChatService {
  SignalRChatService._();
  static final SignalRChatService instance = SignalRChatService._();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  /// Called when a new message arrives in the current room.
  void Function(Map<String, dynamic> messageDto)? onMessageReceived;

  /// Called when a chat transitions from PendingPayment → Active.
  void Function()? onChatUnlocked;

  // ── Connection ────────────────────────────────────────────────────────────

  /// Establishes the SignalR hub connection with JWT authentication.
  Future<void> connect() async {
    if (_isConnected && _hubConnection != null) return;

    final baseUrl = ApiConstants.baseUrl;
    final hubUrl = '$baseUrl${ApiConstants.chatHub}';

    final transportProtLogger = Logger("SignalR - transport");
    transportProtLogger.onRecord.listen((LogRecord rec) {
      debugPrint('[SignalR] ${rec.message}');
    });

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              return await TokenStorage.instance.accessToken ?? '';
            },
          ),
        )
        .configureLogging(transportProtLogger)
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000])
        .build();

    // Bind event listeners before starting
    _hubConnection!.on('ReceiveMessage', _handleReceiveMessage);
    _hubConnection!.on('ChatUnlocked', _handleChatUnlocked);

    // Connection state callbacks
    _hubConnection!.onclose(({error}) {
      _isConnected = false;
      debugPrint('[SignalR] Connection closed: $error');
    });

    _hubConnection!.onreconnecting(({error}) {
      _isConnected = false;
      debugPrint('[SignalR] Reconnecting: $error');
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _isConnected = true;
      debugPrint('[SignalR] Reconnected: $connectionId');
    });

    try {
      await _hubConnection!.start();
      _isConnected = true;
      debugPrint('[SignalR] Connected successfully');
    } catch (e) {
      _isConnected = false;
      debugPrint('[SignalR] Connection failed: $e');
    }
  }

  /// Closes the hub connection.
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      _isConnected = false;
    }
  }

  // ── Room Management ───────────────────────────────────────────────────────

  /// Joins a chat room to receive real-time messages for a specific booking.
  Future<void> joinRoom(int bookingId) async {
    if (!_isConnected || _hubConnection == null) {
      await connect();
    }
    try {
      await _hubConnection!.invoke('JoinChatRoom', args: ['$bookingId']);
      debugPrint('[SignalR] Joined room: $bookingId');
    } catch (e) {
      debugPrint('[SignalR] Failed to join room $bookingId: $e');
    }
  }

  /// Leaves a chat room. Call when navigating away from the chat screen.
  Future<void> leaveRoom(int bookingId) async {
    if (!_isConnected || _hubConnection == null) return;
    try {
      await _hubConnection!.invoke('LeaveChatRoom', args: ['$bookingId']);
      debugPrint('[SignalR] Left room: $bookingId');
    } catch (e) {
      debugPrint('[SignalR] Failed to leave room $bookingId: $e');
    }
  }

  // ── Event Handlers ────────────────────────────────────────────────────────

  void _handleReceiveMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty && arguments[0] != null) {
      final messageDto = Map<String, dynamic>.from(arguments[0] as Map);
      onMessageReceived?.call(messageDto);
    }
  }

  void _handleChatUnlocked(List<Object?>? arguments) {
    onChatUnlocked?.call();
  }
}
