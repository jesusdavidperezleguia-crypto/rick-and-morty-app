
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LocalVideoPlayer extends StatefulWidget {
  final String assetPath;

  const LocalVideoPlayer({
    super.key,
    required this.assetPath,
  });

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final videoController =
    VideoPlayerController.asset(widget.assetPath);

    _videoController = videoController;

    try {
      await videoController.initialize();

      if (!mounted) {
        await videoController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        aspectRatio: videoController.value.aspectRatio > 0
            ? videoController.value.aspectRatio
            : 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFB7F34D),
          handleColor: const Color(0xFFB7F34D),
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
        systemOverlaysOnEnterFullScreen: const [],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      );

      if (!mounted) {
        chewieController.dispose();
        await videoController.dispose();
        return;
      }

      setState(() {
        _chewieController = chewieController;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar el video: ${widget.assetPath}');
      debugPrint('Detalle: $e');

      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);

    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF151D29),
          borderRadius: borderRadius,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: Color(0xFFB7F34D),
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Video no disponible',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Verifica que el archivo exista y que esté declarado en pubspec.yaml.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF929DAD)),
            ),
          ],
        ),
      );
    }

    if (_isLoading || _chewieController == null) {
      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF151D29),
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFB7F34D),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151D29),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio > 0
              ? _videoController!.value.aspectRatio
              : 16 / 9,
          child: Chewie(
            controller: _chewieController!,
          ),
        ),
      ),
    );
  }
}