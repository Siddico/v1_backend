import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTutorialHelper {
  AppTutorialHelper._();

  // Patient Keys
  static final GlobalKey patientRiskCardKey = GlobalKey();
  static final GlobalKey patientCenterNavKey = GlobalKey();
  static final GlobalKey patientChartsTabKey = GlobalKey();
  static final GlobalKey patientProfileTabKey = GlobalKey();
  static final GlobalKey patientChatbotKey = GlobalKey();
  static final GlobalKey patientNotificationBtnKey = GlobalKey();

  // Profile Keys
  static final GlobalKey profileScanQrKey = GlobalKey();
  static final GlobalKey profileMedicalHistoryKey = GlobalKey();
  static final GlobalKey profileSegmentedControlKey = GlobalKey();

  // Doctor Keys
  static final GlobalKey doctorPatientsSectionKey = GlobalKey();
  static final GlobalKey doctorNotificationBtnKey = GlobalKey();
  static final GlobalKey doctorChatbotBtnKey = GlobalKey();
  static final GlobalKey doctorCenterNavKey = GlobalKey();

  // Doctor Patient Details Keys
  static final GlobalKey doctorPatientInfoSwitchKey = GlobalKey();
  static final GlobalKey doctorPatientDetailsContentKey = GlobalKey();
  static final GlobalKey doctorPatientReportBtnKey = GlobalKey();

  static bool _isAnyTutorialActive = false;

  static const String _keyPatientTutorial = 'has_seen_patient_tutorial_v2';
  static const String _keyPatientProfileTutorial =
      'has_seen_patient_profile_tutorial_v2';
  static const String _keyDoctorTutorial = 'has_seen_doctor_tutorial_v2';
  static const String _keyDoctorPatientDetailsTutorial =
      'has_seen_doctor_patient_details_tutorial_v2';

  static String _getPatientTutorialKey(String? uid) {
    return uid != null ? '${_keyPatientTutorial}_$uid' : _keyPatientTutorial;
  }

  static String _getPatientProfileTutorialKey(String? uid) {
    return uid != null
        ? '${_keyPatientProfileTutorial}_$uid'
        : _keyPatientProfileTutorial;
  }

  static String _getDoctorTutorialKey(String? uid) {
    return uid != null ? '${_keyDoctorTutorial}_$uid' : _keyDoctorTutorial;
  }

  static String _getDoctorPatientDetailsTutorialKey(String? uid) {
    return uid != null
        ? '${_keyDoctorPatientDetailsTutorial}_$uid'
        : _keyDoctorPatientDetailsTutorial;
  }

  /// Check and show patient tutorial on home screen if never seen before
  static Future<void> showPatientTutorialIfNeeded(
    BuildContext context,
    String? uid,
  ) async {
    if (_isAnyTutorialActive) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientTutorialKey(uid);
    final hasSeen = prefs.getBool(key) ?? false;
    if (hasSeen) return;

    if (!context.mounted) return;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!context.mounted || _isAnyTutorialActive) return;

      // Check if targets are ready (on screen)
      if (patientRiskCardKey.currentContext == null ||
          patientCenterNavKey.currentContext == null ||
          patientChartsTabKey.currentContext == null ||
          patientProfileTabKey.currentContext == null ||
          patientChatbotKey.currentContext == null ||
          patientNotificationBtnKey.currentContext == null) {
        // Re-try after a short delay to ensure rendering is complete
        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted && !_isAnyTutorialActive) {
            if (patientRiskCardKey.currentContext != null &&
                patientCenterNavKey.currentContext != null &&
                patientChartsTabKey.currentContext != null &&
                patientProfileTabKey.currentContext != null &&
                patientChatbotKey.currentContext != null &&
                patientNotificationBtnKey.currentContext != null) {
              showPatientTutorial(
                context,
                onComplete: () async {
                  await prefs.setBool(key, true);
                },
              );
            }
          }
        });
        return;
      }

      showPatientTutorial(
        context,
        onComplete: () async {
          await prefs.setBool(key, true);
        },
      );
    });
  }

  /// Check and show patient profile tutorial if never seen before
  static Future<void> showPatientProfileTutorialIfNeeded(
    BuildContext context,
    String? uid,
  ) async {
    if (_isAnyTutorialActive) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _getPatientProfileTutorialKey(uid);
    final hasSeen = prefs.getBool(key) ?? false;
    if (hasSeen) return;

    if (!context.mounted) return;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!context.mounted || _isAnyTutorialActive) return;

      // Check if targets are ready
      if (profileScanQrKey.currentContext == null ||
          profileMedicalHistoryKey.currentContext == null ||
          profileSegmentedControlKey.currentContext == null) {
        // Re-try after a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted && !_isAnyTutorialActive) {
            if (profileScanQrKey.currentContext != null &&
                profileMedicalHistoryKey.currentContext != null &&
                profileSegmentedControlKey.currentContext != null) {
              showPatientProfileTutorial(
                context,
                onComplete: () async {
                  await prefs.setBool(key, true);
                },
              );
            }
          }
        });
        return;
      }

      showPatientProfileTutorial(
        context,
        onComplete: () async {
          await prefs.setBool(key, true);
        },
      );
    });
  }

  /// Check and show doctor tutorial on home screen if never seen before
  static Future<void> showDoctorTutorialIfNeeded(
    BuildContext context,
    String? uid,
  ) async {
    if (_isAnyTutorialActive) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _getDoctorTutorialKey(uid);
    final hasSeen = prefs.getBool(key) ?? false;
    if (hasSeen) return;

    if (!context.mounted) return;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!context.mounted || _isAnyTutorialActive) return;

      // Check if targets are ready (on screen)
      if (doctorPatientsSectionKey.currentContext == null ||
          doctorNotificationBtnKey.currentContext == null ||
          doctorChatbotBtnKey.currentContext == null ||
          doctorCenterNavKey.currentContext == null) {
        // Re-try after a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted && !_isAnyTutorialActive) {
            if (doctorPatientsSectionKey.currentContext != null &&
                doctorNotificationBtnKey.currentContext != null &&
                doctorChatbotBtnKey.currentContext != null &&
                doctorCenterNavKey.currentContext != null) {
              showDoctorTutorial(
                context,
                onComplete: () async {
                  await prefs.setBool(key, true);
                },
              );
            }
          }
        });
        return;
      }

      showDoctorTutorial(
        context,
        onComplete: () async {
          await prefs.setBool(key, true);
        },
      );
    });
  }

  static void showPatientTutorial(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    final isAr = AppTextStyles.isArabic;
    final List<TargetFocus> targets = [
      TargetFocus(
        identify: "patient_risk_card",
        keyTarget: patientRiskCardKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'مؤشر خطر السكتة' : 'AI Stroke Risk',
              desc: isAr
                  ? 'هنا يمكنك رؤية مستوى خطر السكتة الدماغية. إذا لم تقم بالتقييم المبدئي بعد، يمكنك الضغط هنا بعد انتهاء هذه الجولة للبدء! في حال وجود خطر حرج مستقبلاً، سيقوم التطبيق فوراً بالاتصال بالطوارئ.'
                  : 'Here you can see your stroke risk level. If you haven\'t completed your initial AI assessment yet, you can tap here after this tour to start! In case of a critical status, the app will instantly assist you in contacting emergency services.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "patient_chatbot",
        keyTarget: patientChatbotKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'المساعد الطبي الذكي' : 'AI Health Assistant',
              desc: isAr
                  ? 'اضغط على هذا الزر العائم في أي وقت للتحدث مع المساعد الطبي الذكي والحصول على استشارات طبية فورية.'
                  : 'Tap this floating button anytime to chat with our AI medical assistant for instant medical advice and support.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "patient_notification_btn",
        keyTarget: patientNotificationBtnKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'التنبيهات والمواعيد' : 'Alerts & Reminders',
              desc: isAr
                  ? 'اضغط هنا لمشاهدة جميع التنبيهات المهمة، مثل مواعيد أدويتك القادمة، الإشعارات الطبية من العيادة، وتذكيرات مواعيد الزيارة.'
                  : 'Tap here to see all your important alerts, including upcoming medication reminders, clinical notifications, and appointment schedules.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "patient_center_nav",
        keyTarget: patientCenterNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'مسح ورفع الملفات' : 'Scan & Upload Files',
              desc: isAr
                  ? 'استخدم هذا الزر الرئيسي لرفع تقارير تحاليلك أو مسح أكواد QR التشخيصية بسرعة وسهولة.'
                  : 'Use this main action button to upload your test reports or scan diagnostic QR codes quickly.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "patient_charts_tab",
        keyTarget: patientChartsTabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr
                  ? 'الرسوم البيانية والمؤشرات'
                  : 'Vitals & Telemetry Charts',
              desc: isAr
                  ? 'اضغط هنا لمتابعة رسومك البيانية وتغير مؤشراتك الحيوية (مثل ضغط الدم ونبضات القلب والسكري) مع الوقت.'
                  : 'Click here to monitor your health graphs and track vital signs (like BP, heart rate, and glucose) over time.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "patient_profile_tab",
        keyTarget: patientProfileTabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'الملف الشخصي والإعدادات' : 'Profile & Settings',
              desc: isAr
                  ? 'اضغط هنا لفتح ملفك الشخصي حيث يمكنك ربط حسابك بالدكتور، مراجعة سجل التقييمات، تذكيرات الأدوية، وحجز مواعيدك.'
                  : 'Go to your Profile tab to scan your doctor\'s QR code, view historical AI predictions, schedule appointments, and manage medication alerts.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: true,
            ),
          ),
        ],
      ),
    ];

    _startTutorial(context, targets, onComplete);
  }

  static void showPatientProfileTutorial(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    final isAr = AppTextStyles.isArabic;
    final List<TargetFocus> targets = [
      TargetFocus(
        identify: "profile_scan_qr",
        keyTarget: profileScanQrKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'ربط الحساب مع الطبيب' : 'Connect with Doctor',
              desc: isAr
                  ? 'اضغط هنا لمسح كود QR الخاص بطبيبك وإرسال طلب ربط الحساب لمشاركة بياناتك ومؤشراتك الحيوية معه.'
                  : 'Tap here to scan your doctor\'s QR code and send a connection request to share your vitals and health progress.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "profile_medical_history",
        keyTarget: profileMedicalHistoryKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'سجل التقييمات الطبية' : 'Historical Predictions',
              desc: isAr
                  ? 'هنا يمكنك عرض جميع توقعات الذكاء الاصطناعي السابقة وتقارير مخاطر السكتة الدماغية مع كافة المؤشرات الطبية المسجلة وقت التقييم.'
                  : 'Click here to review all your previous AI stroke risk predictions, complete with recorded telemetry and vitals at each scan.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "profile_segmented_control",
        keyTarget: profileSegmentedControlKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr
                  ? 'جدولة الجرعات والمواعيد'
                  : 'Reminders & Appointments',
              desc: isAr
                  ? 'استخدم شريط التبويب هذا للتنقل بين إعدادات التذكير بجرعات الأدوية (Meds) وجدولة مواعيد زيارة الطبيب (Appointments).'
                  : 'Use these tabs to schedule doctor appointments and set up medication reminders to receive alerts on time.',
              color: AppColors.tealP,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: true,
            ),
          ),
        ],
      ),
    ];

    _startTutorial(context, targets, onComplete);
  }

  static void showDoctorTutorial(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    final isAr = AppTextStyles.isArabic;
    final List<TargetFocus> targets = [
      TargetFocus(
        identify: "doctor_patients_section",
        keyTarget: doctorPatientsSectionKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'مرضاي والمتابعة' : 'My Patients & Monitoring',
              desc: isAr
                  ? 'هذا القسم يعرض جميع مرضى العيادة المشرف عليهم. اضغط على أي مريض لمشاهدة مؤشراته الحيوية الحية وتاريخه الطبي بالكامل.'
                  : 'This section displays all patients under your supervision. Tap any patient card to review their real-time telemetry, medical history, and clinical parameters.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "doctor_notification_btn",
        keyTarget: doctorNotificationBtnKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr
                  ? 'التنبيهات وطلبات الإضافة'
                  : 'Alerts & Connection Requests',
              desc: isAr
                  ? 'اضغط هنا لمشاهدة إشعارات العيادة الحرجة والموافقة على طلبات ربط الحسابات الواردة من المرضى الجدد.'
                  : 'Click this button to see critical patient alerts and accept connection requests from new patients.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "doctor_chatbot",
        keyTarget: doctorChatbotBtnKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr
                  ? 'المساعد الطبي للذكاء الاصطناعي'
                  : 'AI Clinical Copilot',
              desc: isAr
                  ? 'اضغط هنا لفتح مساعد العيادة الذكي المساعد لك في تحليل وتلخيص التقارير واستشارة الحالات طبياً.'
                  : 'Tap this chatbot to open your AI clinical assistant, helping you summarize patient notes, analyze telemetry, and search medical literature.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "doctor_center_nav",
        keyTarget: doctorCenterNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'مسح كود المريض' : 'Scan Patient QR',
              desc: isAr
                  ? 'اضغط هنا لمسح كود QR الخاص بالمريض والدخول فوراً لملفه الطبي ومؤشراته الحيوية.'
                  : 'Click here to scan a patient\'s QR code and instantly access their full profile and medical files.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: true,
            ),
          ),
        ],
      ),
    ];

    _startTutorial(context, targets, onComplete);
  }

  /// Check and show doctor patient details tutorial if never seen before
  static Future<void> showDoctorPatientDetailsTutorialIfNeeded(
    BuildContext context,
    String? uid,
  ) async {
    if (_isAnyTutorialActive) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _getDoctorPatientDetailsTutorialKey(uid);
    final hasSeen = prefs.getBool(key) ?? false;
    if (hasSeen) return;

    if (!context.mounted) return;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!context.mounted || _isAnyTutorialActive) return;

      // Check if targets are ready (on screen)
      if (doctorPatientInfoSwitchKey.currentContext == null ||
          doctorPatientDetailsContentKey.currentContext == null ||
          doctorPatientReportBtnKey.currentContext == null) {
        // Re-try after a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted && !_isAnyTutorialActive) {
            if (doctorPatientInfoSwitchKey.currentContext != null &&
                doctorPatientDetailsContentKey.currentContext != null &&
                doctorPatientReportBtnKey.currentContext != null) {
              showDoctorPatientDetailsTutorial(
                context,
                onComplete: () async {
                  await prefs.setBool(key, true);
                },
              );
            }
          }
        });
        return;
      }

      showDoctorPatientDetailsTutorial(
        context,
        onComplete: () async {
          await prefs.setBool(key, true);
        },
      );
    });
  }

  static void showDoctorPatientDetailsTutorial(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    final isAr = AppTextStyles.isArabic;
    final List<TargetFocus> targets = [
      TargetFocus(
        identify: "doctor_patient_info_switch",
        keyTarget: doctorPatientInfoSwitchKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'تبديل عرض البيانات' : 'Toggle View Modes',
              desc: isAr
                  ? 'يمكنك التحول هنا بين البيانات الشخصية والتاريخ الطبي للمريض (Information)، وبين لوحة المؤشرات الحيوية والرسومات البيانية والملفات المرفوعة (Medical Dashboard).'
                  : 'Switch here between the patient\'s personal info & medical history, and their medical dashboard showing real-time vitals, charts, and uploaded signals.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "doctor_patient_details_content",
        keyTarget: doctorPatientDetailsContentKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr
                  ? 'الملف الطبي الشامل'
                  : 'Comprehensive Medical Profile',
              desc: isAr
                  ? 'هنا يتم عرض التقارير الطبية، الأمراض الزمنية، وتطور المؤشرات الحيوية للمريض بدقة متناهية لمساعدتك في اتخاذ القرار المناسب.'
                  : 'This area displays medical logs, chronic conditions, and detailed vital trends to support your clinical decision-making.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: false,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "doctor_patient_report_btn",
        keyTarget: doctorPatientReportBtnKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialCard(
              context,
              title: isAr ? 'تنزيل ومشاركة التقرير' : 'Download & Share Report',
              desc: isAr
                  ? 'اضغط هنا لتوليد تقرير طبي شامل بصيغة PDF يحتوي على جميع قياسات المريض وتاريخه الطبي لمشاركته أو طباعته.'
                  : 'Click here to generate a comprehensive PDF medical report containing all patient telemetry and history for sharing or printing.',
              color: AppColors.redDeep,
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
              isLast: true,
            ),
          ),
        ],
      ),
    ];

    _startTutorial(context, targets, onComplete);
  }

  static void _startTutorial(
    BuildContext context,
    List<TargetFocus> targets,
    VoidCallback onComplete,
  ) {
    _isAnyTutorialActive = true;
    TutorialCoachMark(
      targets: targets,
      beforeFocus: (target) async {
        final key = target.keyTarget;
        if (key != null) {
          final ctx = key.currentContext;
          if (ctx != null) {
            await Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      },
      colorShadow: AppColors.black.withValues(alpha: 0.85),
      textSkip: AppTextStyles.isArabic ? "تخطي" : "SKIP",
      textStyleSkip: TextStyle(
        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      paddingFocus: 2,
      opacityShadow: 0.85,
      onFinish: () {
        _isAnyTutorialActive = false;
        onComplete();
      },
      onSkip: () {
        _isAnyTutorialActive = false;
        onComplete();
        return true;
      },
    ).show(context: context);
  }

  static Widget _buildTutorialCard(
    BuildContext context, {
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onNext,
    required VoidCallback onSkip,
    required bool isLast,
  }) {
    final isAr = AppTextStyles.isArabic;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack25.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: isAr ? 'Cairo' : 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.neutral700,
              fontFamily: isAr ? 'Cairo' : 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onSkip,
                child: Text(
                  isAr ? 'تخطي الجولة' : 'Skip Tour',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral500,
                    fontFamily: isAr ? 'Cairo' : 'Poppins',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isLast
                      ? (isAr ? 'إنهاء' : 'Finish')
                      : (isAr ? 'التالي' : 'Next'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: isAr ? 'Cairo' : 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
