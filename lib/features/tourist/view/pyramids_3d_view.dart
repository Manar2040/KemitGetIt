import 'package:flutter/material.dart';
import 'package:kemit_get_it/routes/app_routes.dart';

class Pyramids3dView extends StatelessWidget {
  const Pyramids3dView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pyramids 3D'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.threed_rotation, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 24),
            const Text(
              'Explore the Pyramids in 3D',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.unityEmbed, arguments: {'placeName': 'Pyramids'});
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start 3D'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
