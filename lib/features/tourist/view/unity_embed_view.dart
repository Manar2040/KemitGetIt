import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class UnityEmbedView extends StatelessWidget {
  const UnityEmbedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D View'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: EmbedUnity(
        onMessageFromUnity: (String message) {
          debugPrint('Message from Unity: $message');
        },
      ),
    );
  }
}
