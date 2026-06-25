import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class UnityEmbedView extends StatefulWidget {
  const UnityEmbedView({super.key});

  @override
  State<UnityEmbedView> createState() => _UnityEmbedViewState();
}

class _UnityEmbedViewState extends State<UnityEmbedView> {
  bool _messageSent = false;
  String _placeName = 'Pyramids';
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_messageSent) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _placeName = args?['placeName']?.toString() ?? 'Pyramids';
      
      _messageSent = true;
      
      final nameLower = _placeName.toLowerCase();
      final isMosque = nameLower.contains('ali') || nameLower.contains('mosque') || nameLower.contains('citadel');

      // Unity takes several seconds to load, so we send the message repeatedly
      // until Unity is ready to catch it.
      int attempts = 0;
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          if (isMosque) {
            sendToUnity("SceneManager", "LoadScene", "ShowMohamedAliMosque");
          } else {
            sendToUnity("SceneManager", "LoadScene", "ShowPyramids");
          }
        }
        attempts++;
        // Stop trying after 14 seconds (7 attempts)
        if (attempts >= 7) {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Force the app back to portrait mode when exiting the 3D view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _onUnityMessage(String message) {
    debugPrint('Message from Unity: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_placeName 3D View'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: EmbedUnity(
        onMessageFromUnity: _onUnityMessage,
      ),
    );
  }
}
