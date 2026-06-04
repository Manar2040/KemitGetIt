import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GuideCallView extends StatefulWidget {
  final String guideName;
  const GuideCallView({super.key, required this.guideName});

  @override
  State<GuideCallView> createState() => _GuideCallViewState();
}

class _GuideCallViewState extends State<GuideCallView> {
  bool _isMuted = false;
  bool _isSpeaker = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // slate-800
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header Info
            const Text(
              'Ringing...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.guideName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),
            // Large Avatar
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400'),
              ),
            ),
            const Spacer(),
            // Call Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.white24 : Colors.white12,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  iconColor: Colors.white,
                  size: 72,
                  iconSize: 36,
                  onTap: () => Navigator.pop(context),
                ),
                _buildControlButton(
                  icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                  color: _isSpeaker ? Colors.white24 : Colors.white12,
                  onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    double size = 64,
    double iconSize = 28,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
