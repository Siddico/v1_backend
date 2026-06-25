import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/networking/local_storage.dart';
import '../controllers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  static const _textStyle = TextStyle(
    color: AppColors.redDeep,
    fontSize: 40,
    fontFamily: 'Quivert',
    fontWeight: FontWeight.w700,
    letterSpacing: 6,
  );

  late AnimationController _animationController;
  late Animation<double> _logoXAnimation;
  late Animation<double> _logoYAnimation;
  late AnimationController _popUpController;
  late Animation<double> _popUpAnimation;
  late final _SplashTextMetrics _metrics;

  Future<String> _resolveNextRoute() async {
    try {
      final user = await ref.read(authStateProvider.future);
      if (user == null) {
        final storage = ref.read(localStorageProvider);
        if (storage.isOnboardingCompleted()) {
          return AppConstants.routeRole;
        }
        return AppConstants.routeOnboarding;
      }

      return user.role == UserRole.doctor
          ? AppConstants.routeDoctorHome
          : AppConstants.routeHome;
    } catch (_) {
      final storage = ref.read(localStorageProvider);
      if (storage.isOnboardingCompleted()) {
        return AppConstants.routeRole;
      }
      return AppConstants.routeOnboarding;
    }
  }

  @override
  void initState() {
    super.initState();

    _metrics = _SplashTextMetrics.fromStyle(_textStyle);

    _animationController = AnimationController(
      duration: AppDurations.splashLogo,
      vsync: this,
    );

    _logoXAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
    );
    _logoYAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeInOutCubic),
    );

    _popUpController = AnimationController(
      duration: AppDurations.splashPopup,
      vsync: this,
    );

    _popUpAnimation = CurvedAnimation(
      parent: _popUpController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();

    // Start resolving the next route EARLY (in parallel with animations)
    // so the Firestore auth check doesn't delay navigation.
    final routeFuture = _resolveNextRoute();

    // After delay, start pop-up animation
    Timer(AppDurations.splashPopupDelay, () {
      if (!mounted) return;
      _popUpController.forward();
    });

    bool navigationTriggered = false;

    // Trigger navigation early (at 80% of scaling animation) to prevent freezing on the pixelated logo
    _popUpController.addListener(() async {
      if (_popUpController.value >= 0.8 && !navigationTriggered) {
        navigationTriggered = true;
        final nextRoute = await routeFuture;
        if (mounted) {
          context.go(nextRoute);
        }
      }
    });

    // Fallback status listener
    _popUpController.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !navigationTriggered) {
        navigationTriggered = true;
        final nextRoute = await routeFuture;
        if (mounted) {
          context.go(nextRoute);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prevent first-frame decode/upload cost for the splash logo.
    precacheImage(const AssetImage(AppImages.logoPng), context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _popUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _popUpAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_popUpAnimation.value * 7.0),
                  child: child,
                );
              },
              child: Image.asset(
                AppImages.logoPng,
                fit: BoxFit.contain,
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 33),
            LayoutBuilder(
              builder: (context, constraints) {
                const logoSize = 35.0;
                const textHorizontalInset = 10.0;
                final availableWidth = (constraints.maxWidth - 12).clamp(
                  0.0,
                  double.infinity,
                );
                final canvasWidth =
                    _metrics.textWidth + (textHorizontalInset * 2);

                // Start position: centered under letter 'B'
                final startX =
                    textHorizontalInset +
                    (_metrics.widthB / 2) -
                    (logoSize / 2);
                // End position: centered in the gap between 'R' and space
                final gapCenterX =
                    textHorizontalInset +
                    ((_metrics.widthBR + _metrics.widthBRSpace) / 2) -
                    (logoSize / 2);
                final startY = -logoSize * 0.6;
                final endY = (_metrics.textHeight - logoSize) / 2 + 7.5;

                return Center(
                  child: SizedBox(
                    width: availableWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: canvasWidth,
                        height: _metrics.textHeight + logoSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: textHorizontalInset,
                              right: textHorizontalInset,
                              top: 0,
                              child: Text(
                                'BR IN GUARD',
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.center,
                                style: _textStyle,
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                final animatedX =
                                    startX +
                                    (gapCenterX - startX) *
                                        _logoXAnimation.value;
                                final animatedY =
                                    startY +
                                    (endY - startY) * _logoYAnimation.value;

                                return Positioned(
                                  left: animatedX,
                                  top: animatedY,
                                  child: child!,
                                );
                              },
                              child: SizedBox(
                                width: logoSize,
                                height: logoSize,
                                child: Image.asset(
                                  AppImages.logoPng,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashTextMetrics {
  final double textWidth;
  final double textHeight;
  final double widthB;
  final double widthBR;
  final double widthBRI;
  final double widthBRSpace;

  const _SplashTextMetrics({
    required this.textWidth,
    required this.textHeight,
    required this.widthB,
    required this.widthBR,
    required this.widthBRI,
    required this.widthBRSpace,
  });

  static double _measureWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  factory _SplashTextMetrics.fromStyle(TextStyle style) {
    final fullTextPainter = TextPainter(
      text: TextSpan(text: 'BR IN GUARD', style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    return _SplashTextMetrics(
      textWidth: fullTextPainter.width,
      textHeight: fullTextPainter.height,
      widthB: _measureWidth('B', style),
      widthBR: _measureWidth('BR', style),
      widthBRI: _measureWidth('BR I', style),
      widthBRSpace: _measureWidth('BR ', style),
    );
  }
}




//  // Image with animated logo
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 const imageWidth = 300.0;
//                 const imageHeight = 80.0; // عدله حسب ارتفاع صورتك الفعلي
//                 const logoSize = 35.0;

//                 // Same text style as above
//                 final textStyle = TextStyle(
//                   color: AppColors.redDeep,
//                   fontSize: 44,
//                   fontFamily: AppFonts.croissantOne,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 8,
//                 );

//                 // Measure the full text
//                 final fullTextPainter = TextPainter(
//                   text: TextSpan(text: 'BR IN GUARD', style: textStyle),
//                   textDirection: TextDirection.ltr,
//                 )..layout();

//                 final widthBRSpace = TextPainter(
//                   text: TextSpan(text: 'BR ', style: textStyle),
//                   textDirection: TextDirection.ltr,
//                 )..layout();

//                 final widthBRSpaceI = TextPainter(
//                   text: TextSpan(text: 'BR I', style: textStyle),
//                   textDirection: TextDirection.ltr,
//                 )..layout();

//                 final textWidth = fullTextPainter.width;

//                 // Calculate horizontal positions
//                 // Position of center of gap between 'R' and 'I' from left edge of text
//                 final gapCenter =
//                     (widthBRSpace.width + widthBRSpaceI.width) / 2;

//                 // Calculate how much the image is offset from the text
//                 // Since text is wider, image is centered under it
//                 final imageLeftOffset = (textWidth - imageWidth) / 2;

//                 // Convert absolute positions to relative to image
//                 // Start from the left edge of the image (not from B position)
//                 final startX = 0.0; // من أقصى شمال الصورة
//                 final gapCenterX = gapCenter - imageLeftOffset - (logoSize / 2);

//                 // Vertical positions - reduced vertical distance
//                 final startY = -logoSize * 0.1; // Higher above the image
//                 final endY = (imageHeight - logoSize) / 1.2; // Center of image

//                 return SizedBox(
//                   width: imageWidth,
//                   height: imageHeight + (logoSize * 0.9),
//                   child: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       // Static image
//                       Positioned(
//                         left: 0,
//                         top: logoSize * 0.6,
//                         child: Image.asset(
//                           AppImages.brainGuardlogo,
//                           width: imageWidth,
//                         ),
//                       ),

//                       // Animated logo
//                       AnimatedBuilder(
//                         animation: _animationController,
//                         builder: (context, child) {
//                           final animatedX =
//                               startX +
//                               (gapCenterX - startX) * _logoXAnimation.value;
//                           final animatedY =
//                               startY + (endY - startY) * _logoYAnimation.value;

//                           return Positioned(
//                             left: animatedX,
//                             top: animatedY,
//                             child: child!,
//                           );
//                         },
//                         child: SizedBox(
//                           width: logoSize,
//                           height: logoSize,
//                           child: Image.asset(
//                             AppImages.logoPng,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             Image.asset(AppImages.brainGuardlogo, width: 300),
     