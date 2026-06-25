import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/controllers/auth_providers.dart';
import '../shared/data/services/fcm_service.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_images.dart';
import '../core/enums/user_role.dart';
import '../shared/presentation/widgets/global_no_internet_guard.dart';
import 'router.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../core/theme/app_text_styles.dart';

final loginTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());

class GradStrokeApp extends ConsumerWidget {
  const GradStrokeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    AppTextStyles.isArabic = activeLocale.languageCode == 'ar';

    // Listen to login/signup changes
    ref.listen(authControllerProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        FcmService.instance.initialize(user.id);
        ref.read(loginTimeProvider.notifier).state = DateTime.now();
      }
    });

    // Listen to initial auto-login status
    ref.listen(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        FcmService.instance.initialize(user.id);
        ref.read(loginTimeProvider.notifier).state = DateTime.now();
      }
    });

    // Call feature removed for coming soon

    return MaterialApp.router(
      title: 'Grad Stroke',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      locale: activeLocale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ref
          .watch(authStateProvider)
          .when(
            data: (user) => user?.role == UserRole.doctor
                ? AppColors.redTheme()
                : AppColors.tealTheme(),
            loading: () => ThemeData.light(),
            // ignore: unnecessary_underscores
            error: (_, __) => ThemeData.light(),
          ),
      builder: (context, child) {
        return GlobalNoInternetGuard(child: child ?? const SizedBox());
      },
    );
  }
}
