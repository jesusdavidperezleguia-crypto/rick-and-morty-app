
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

  // Videos que ya están alojados en Cloudinary.
  // Los demás seguirán cargándose desde los assets locales.
  static const Map<String, String> _cloudinaryVideos = {
  'assets/videos/temporada_1/episodio1.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792790216/rick-morty-tcc/temporada_1/episodio1.mp4',
  'assets/videos/temporada_1/episodio2.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791350/rick-morty-tcc/temporada_1/episodio2.mp4',
  'assets/videos/temporada_1/episodio3.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791362/rick-morty-tcc/temporada_1/episodio3.mp4',
  'assets/videos/temporada_1/episodio4.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791372/rick-morty-tcc/temporada_1/episodio4.mp4',
  'assets/videos/temporada_1/episodio5.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791382/rick-morty-tcc/temporada_1/episodio5.mp4',
  'assets/videos/temporada_1/episodio6.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791391/rick-morty-tcc/temporada_1/episodio6.mp4',
  'assets/videos/temporada_1/episodio7.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791401/rick-morty-tcc/temporada_1/episodio7.mp4',
  'assets/videos/temporada_1/episodio8.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791411/rick-morty-tcc/temporada_1/episodio8.mp4',
  'assets/videos/temporada_1/episodio9.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791421/rick-morty-tcc/temporada_1/episodio9.mp4',
  'assets/videos/temporada_1/episodio10.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791431/rick-morty-tcc/temporada_1/episodio10.mp4',
  'assets/videos/temporada_1/episodio11.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791441/rick-morty-tcc/temporada_1/episodio11.mp4',
  'assets/videos/temporada_2/episodio1.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791588/rick-morty-tcc/temporada_2/episodio1.mp4',
  'assets/videos/temporada_2/episodio2.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791599/rick-morty-tcc/temporada_2/episodio2.mp4',
  'assets/videos/temporada_2/episodio3.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791609/rick-morty-tcc/temporada_2/episodio3.mp4',
  'assets/videos/temporada_2/episodio4.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791617/rick-morty-tcc/temporada_2/episodio4.mp4',
  'assets/videos/temporada_2/episodio5.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791627/rick-morty-tcc/temporada_2/episodio5.mp4',
  'assets/videos/temporada_2/episodio6.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791640/rick-morty-tcc/temporada_2/episodio6.mp4',
  'assets/videos/temporada_2/episodio7.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791650/rick-morty-tcc/temporada_2/episodio7.mp4',
  'assets/videos/temporada_2/episodio8.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791664/rick-morty-tcc/temporada_2/episodio8.mp4',
  'assets/videos/temporada_2/episodio9.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791674/rick-morty-tcc/temporada_2/episodio9.mp4',
  'assets/videos/temporada_2/episodio10.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791685/rick-morty-tcc/temporada_2/episodio10.mp4',
  'assets/videos/temporada_3/episodio1.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791694/rick-morty-tcc/temporada_3/episodio1.mp4',
  'assets/videos/temporada_3/episodio2.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791702/rick-morty-tcc/temporada_3/episodio2.mp4',
  'assets/videos/temporada_3/episodio3.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791712/rick-morty-tcc/temporada_3/episodio3.mp4',
  'assets/videos/temporada_3/episodio4.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791720/rick-morty-tcc/temporada_3/episodio4.mp4',
  'assets/videos/temporada_3/episodio5.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791731/rick-morty-tcc/temporada_3/episodio5.mp4',
  'assets/videos/temporada_3/episodio6.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791786/rick-morty-tcc/temporada_3/episodio6.mp4',
  'assets/videos/temporada_3/episodio7.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791846/rick-morty-tcc/temporada_3/episodio7.mp4',
  'assets/videos/temporada_3/episodio8.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792791940/rick-morty-tcc/temporada_3/episodio8.mp4',
  'assets/videos/temporada_3/episodio9.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792792004/rick-morty-tcc/temporada_3/episodio9.mp4',
  'assets/videos/temporada_3/episodio10.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792792305/rick-morty-tcc/temporada_3/episodio10.mp4',
  'assets/videos/temporada_4/episodio1.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792792582/rick-morty-tcc/temporada_4/episodio1.mp4',
  'assets/videos/temporada_4/episodio2.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792792877/rick-morty-tcc/temporada_4/episodio2.mp4',
  'assets/videos/temporada_4/episodio3.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792792977/rick-morty-tcc/temporada_4/episodio3.mp4',
  'assets/videos/temporada_4/episodio4.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793034/rick-morty-tcc/temporada_4/episodio4.mp4',
  'assets/videos/temporada_4/episodio5.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793059/rick-morty-tcc/temporada_4/episodio5.mp4',
  'assets/videos/temporada_4/episodio6.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793233/rick-morty-tcc/temporada_4/episodio6.mp4',
  'assets/videos/temporada_4/episodio7.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793320/rick-morty-tcc/temporada_4/episodio7.mp4',
  'assets/videos/temporada_4/episodio8.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793409/rick-morty-tcc/temporada_4/episodio8.mp4',
  'assets/videos/temporada_4/episodio9.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793486/rick-morty-tcc/temporada_4/episodio9.mp4',
  'assets/videos/temporada_4/episodio10.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793554/rick-morty-tcc/temporada_4/episodio10.mp4',
  'assets/videos/temporada_5/Episodio1.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793629/rick-morty-tcc/temporada_5/Episodio1.mp4',
  'assets/videos/temporada_5/Episodio2.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793695/rick-morty-tcc/temporada_5/Episodio2.mp4',
  'assets/videos/temporada_5/Episodio3.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793836/rick-morty-tcc/temporada_5/Episodio3.mp4',
  'assets/videos/temporada_5/Episodio4.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792793984/rick-morty-tcc/temporada_5/Episodio4.mp4',
  'assets/videos/temporada_5/Episodio5.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792794083/rick-morty-tcc/temporada_5/Episodio5.mp4',
  'assets/videos/temporada_5/Episodio6.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792794158/rick-morty-tcc/temporada_5/Episodio6.mp4',
  'assets/videos/temporada_5/Episodio7.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792794219/rick-morty-tcc/temporada_5/Episodio7.mp4',
  'assets/videos/temporada_5/Episodio8.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792794290/rick-morty-tcc/temporada_5/Episodio8.mp4',
  'assets/videos/temporada_5/Episodio9.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792794346/rick-morty-tcc/temporada_5/Episodio9.mp4',
  'assets/videos/temporada_5/Episodio10.mp4': 'https://res.cloudinary.com/ps4tjy1r/video/upload/v1792794404/rick-morty-tcc/temporada_5/Episodio10.mp4',
};

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final normalizedPath = widget.assetPath.replaceAll('\\', '/');
    final cloudinaryUrl = _cloudinaryVideos[normalizedPath];

    final esUrlDirecta = normalizedPath.startsWith('https://') ||
        normalizedPath.startsWith('http://');

    if (cloudinaryUrl == null && !esUrlDirecta) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      debugPrint('No hay URL de video configurada para: $normalizedPath');
      return;
    }

    final videoUrl = cloudinaryUrl ?? normalizedPath;
    final videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );

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
              'Comprueba tu conexión y que el video esté disponible.',
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
