import 'package:flutter/material.dart';
import 'dart:io';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_custom.dart';

/// Full-screen image viewer with pinch-to-zoom.
class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({super.key, required this.url});

  final String url;

  static void show(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => FullScreenImageViewer(url: url),
        // ignore: unnecessary_underscores
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: isArabic ? 'معاينة الصورة' : 'Image Preview',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: !url.startsWith('http://') && !url.startsWith('https://')
              ? Image.file(
                  File(url),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                )
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        color: AppColors.tealP,
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
        ),
      ),
    );
  }
}
