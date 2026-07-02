import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../../shared/data/datasources/appointment_remote_datasource.dart';

class ProfileAppointmentsTab extends StatefulWidget {
  const ProfileAppointmentsTab({super.key});

  @override
  State<ProfileAppointmentsTab> createState() => _ProfileAppointmentsTabState();
}

class _ProfileAppointmentsTabState extends State<ProfileAppointmentsTab> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await AppointmentRemoteDataSource.getPatientAppointments();
      setState(() {
        _appointments = fetched.map((e) {
          return {
            'id': e['id']?.toString() ?? '',
            'doctorName': e['notes'] ?? 'Unknown Doctor', // Using notes for doctorName in MVP
            'specialty': e['specialty'] ?? '',
            'dateTime': e['appointment_date'] != null 
                ? DateTime.parse(e['appointment_date']) 
                : DateTime.now(),
            'status': e['status'],
          };
        }).toList();
        
        _appointments.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
      });
    } catch (e) {
      debugPrint('Failed to load appointments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddBottomSheet() {
    final TextEditingController doctorController = TextEditingController();
    final TextEditingController specialtyController = TextEditingController();
    DateTime selectedDateTime = DateTime.now().add(const Duration(days: 1));

    final isArabic = AppTextStyles.isArabic;
    final font = isArabic ? 'Cairo' : 'Poppins';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            String formatDateTime(DateTime dt) {
              final dateStr =
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
              final localizations = MaterialLocalizations.of(ctx);
              final timeStr = localizations.formatTimeOfDay(
                TimeOfDay.fromDateTime(dt),
                alwaysUse24HourFormat: false,
              );
              return '$dateStr  •  $timeStr';
            }

            Future<void> pickDateTime() async {
              final DateTime? date = await showDatePicker(
                context: ctx,
                initialDate: selectedDateTime,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.tealP,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (date == null) return;

              if (mounted) {
                final TimeOfDay? time = await showTimePicker(
                  // ignore: use_build_context_synchronously
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.tealP,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (time != null) {
                  setSheetState(() {
                    selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            }

            Future<void> onSave() async {
              final doctorName = doctorController.text.trim();
              if (doctorName.isEmpty) {
                AppToast.show(
                  ctx,
                  'Please enter doctor name'.tr(ctx),
                  type: AppToastType.warning,
                  role: UserRole.patient,
                  translate: false,
                );
                return;
              }

              final minTime = DateTime.now().add(const Duration(hours: 1));
              if (selectedDateTime.isBefore(minTime)) {
                AppToast.show(
                  ctx,
                  'Appointment must be scheduled at least 1 hour in the future'
                      .tr(ctx),
                  type: AppToastType.warning,
                  role: UserRole.patient,
                  translate: false,
                );
                return;
              }

              setSheetState(() => _isSaving = true);

              final String dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);

              try {
                // Assuming doctorId is known, but we only have a name input. We will use a placeholder or ID 1 for MVP since UI only asks for name.
                // Normally you'd select a doctor from a dropdown that gives an ID. Let's pass 1 for now to prevent breaking.
                await AppointmentRemoteDataSource.createAppointment(
                  doctorId: 1, // Placeholder
                  appointmentDate: dateStr,
                  specialty: specialtyController.text.trim().isEmpty ? null : specialtyController.text.trim(),
                  notes: doctorName, // Storing doctor name in notes for MVP compatibility
                );

                await _fetchAppointments(); // Refresh

                try {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;
                  final reminderTime = selectedDateTime.subtract(
                    const Duration(hours: 1),
                  );
                  if (reminderTime.isAfter(DateTime.now())) {
                    await LocalNotificationService.instance
                        .scheduleSingleNotification(
                          id: notificationId,
                          title: isArabic ? 'موعد طبيب' : 'Doctor Appointment',
                          // ignore: use_build_context_synchronously
                          body:
                              // ignore: use_build_context_synchronously
                              '${'Reminder for your appointment with'.tr(ctx)} $doctorName',
                          firestoreTitle: 'Doctor Appointment',
                          firestoreBody:
                              'Reminder for your appointment with $doctorName',
                          scheduledDateTime: reminderTime,
                          payload: '{"type": "appointment"}',
                        );
                  }
                } catch (e) {
                  debugPrint('Could not schedule appointment notification: $e');
                }

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(sheetContext).pop();
                  AppToast.show(
                    context,
                    'Appointment added successfully'.tr(context),
                    type: AppToastType.success,
                    role: UserRole.patient,
                    translate: false,
                  );
                }
              } catch (e) {
                AppToast.show(
                  // ignore: use_build_context_synchronously
                  ctx,
                  // ignore: use_build_context_synchronously
                  'Failed to save appointment'.tr(ctx),
                  type: AppToastType.error,
                  translate: false,
                );
              } finally {
                setSheetState(() => _isSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header gradient banner
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0FB39E), Color(0xFF0A8F7E)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Add Appointment'.tr(ctx),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: font,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form fields
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Doctor name
                          TextField(
                            controller: doctorController,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14,
                              color: AppColors.neutral900,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Doctor Name'.tr(ctx),
                              labelStyle: TextStyle(
                                color: AppColors.tealP,
                                fontFamily: font,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.tealP,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3FAFB),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.tealP,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Specialty
                          TextField(
                            controller: specialtyController,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14,
                              color: AppColors.neutral900,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Specialty (Optional)'.tr(ctx),
                              labelStyle: TextStyle(
                                color: AppColors.tealP,
                                fontFamily: font,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.local_hospital_outlined,
                                color: AppColors.tealP,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3FAFB),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.tealP,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Date & Time selector
                          GestureDetector(
                            onTap: pickDateTime,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3FAFB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.tealP,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Date & Time:'.tr(ctx),
                                      style: TextStyle(
                                        color: AppColors.tealP,
                                        fontFamily: font,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.tealP,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      formatDateTime(selectedDateTime),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => Navigator.of(sheetContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel'.tr(ctx),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontFamily: font,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : onSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.tealP,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Save'.tr(ctx),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: font,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAppointment(Map<String, dynamic> appDoc) async {
    final Map<String, dynamic>? data = appDoc;
    final int? notificationId = data?['notificationId'];
    final String doctorName = data?['doctorName'] ?? '';
    final isArabic = AppTextStyles.isArabic;
    final font = isArabic ? 'Cairo' : 'Poppins';

    final bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete Appointment'.tr(ctx),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: font,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              content: Text(
                '${'Are you sure you want to delete'.tr(ctx)} Dr. $doctorName?',
                style: TextStyle(fontFamily: font, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'Cancel'.tr(ctx),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: font,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Delete'.tr(ctx),
                    style: TextStyle(color: Colors.white, fontFamily: font),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    try {
      final int appointmentId = int.tryParse(appDoc['id'].toString()) ?? 0;
      if (appointmentId != 0) {
        await AppointmentRemoteDataSource.updatePatientAppointment(
          appointmentId,
          'cancelled',
        );
      }

      setState(() {
        _appointments.removeWhere((m) => m['id'] == appDoc['id']);
      });

      if (notificationId != null) {
        await LocalNotificationService.instance.cancelNotification(
          notificationId,
        );
      }

      if (mounted) {
        AppToast.show(
          context,
          'Appointment deleted'.tr(context),
          type: AppToastType.success,
          role: UserRole.patient,
          translate: false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Failed to delete appointment'.tr(context),
          type: AppToastType.error,
          translate: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    final font = isArabic ? 'Cairo' : 'Poppins';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Doctor Appointments'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: font,
                  color: AppColors.tealPrimaryDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddBottomSheet,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text(
                  'Add'.tr(context),
                  style: TextStyle(color: Colors.white, fontFamily: font),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealP,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )
        else if (_appointments.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.tealBorderLight.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 48,
                  color: AppColors.tealP.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No appointments scheduled'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: font,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep track of your visits to the clinic and get notified 1 hour prior to your schedule.'
                      .tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: font,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
