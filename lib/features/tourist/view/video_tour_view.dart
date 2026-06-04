import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';

class VideoTourView extends StatefulWidget {
  final String? videoUrl;
  final String title;

  const VideoTourView({
    Key? key,
    this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoTourView> createState() => _VideoTourViewState();
}

class _VideoTourViewState extends State<VideoTourView> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;
  String _errorMessage = '';

  static const String _assetPath = 'lib/core/assets/videos/pyramids_model.mp4';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    try {
      
      await _controller?.dispose();

      final controller = VideoPlayerController.asset(_assetPath);
      _controller = controller;

      _initializeVideoPlayerFuture = controller.initialize().then((_) async {
        await controller.setLooping(false);
        await controller.setVolume(1.0);
       
        await controller.play();

        if (mounted) setState(() {});
      }).catchError((error) {
        final desc = _controller?.value.errorDescription;
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = desc ?? error.toString();
          });
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize video: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final c = _controller;
    if (c == null) return;
    if (!c.value.isInitialized) return;

    try {
      if (c.value.isPlaying) {
        await c.pause();
      } else {
        await c.play();
      }
      if (mounted) setState(() {});
    } catch (e) {
      final desc = c.value.errorDescription;
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = desc ?? 'Playback failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withOpacity(0.1),
            border: Border.all(
              color: AppColors.surface.withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.surface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.label.copyWith(
            color: AppColors.surface,
          ),
        ),
      ),
      body: _hasError ? _buildErrorWidget() : _buildVideoPlayer(),
    );
  }

  Widget _buildVideoPlayer() {
    final initFuture = _initializeVideoPlayerFuture;

    return FutureBuilder<void>(
      future: initFuture,
      builder: (context, snapshot) {
        final c = _controller;

        if (snapshot.connectionState == ConnectionState.done &&
            c != null &&
            c.value.isInitialized) {
          return Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: _togglePlayPause,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: c.value.aspectRatio,
                    child: VideoPlayer(c),
                  ),
                ),
              ),

              // Play Overlay
              if (!c.value.isPlaying)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow,
                            color: AppColors.surface,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Progress Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      c,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: AppColors.primary.withOpacity(0.5),
                        backgroundColor:
                            AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(c.value.position),
                            style: AppTextStyles.bodyTextSmall.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                          Text(
                            _formatDuration(c.value.duration),
                            style: AppTextStyles.bodyTextSmall.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Video',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.surface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Text(
                _errorMessage.isEmpty
                    ? 'Make sure the video exists at:\n$_assetPath'
                    : _errorMessage,
                style: AppTextStyles.bodyTextSmall.copyWith(
                  color: AppColors.surface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Go Back',
                style: AppTextStyles.button,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeVideo,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
