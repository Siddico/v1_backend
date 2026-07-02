import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../core/enums/user_role.dart';
import '../controllers/doctor_followup_providers.dart';
import '../../domain/entities/doctor_followup_entity.dart';

class DoctorFollowUpSection extends ConsumerStatefulWidget {
  final String patientId;

  const DoctorFollowUpSection({super.key, required this.patientId});

  @override
  ConsumerState<DoctorFollowUpSection> createState() =>
      _DoctorFollowUpSectionState();
}

class _DoctorFollowUpSectionState extends ConsumerState<DoctorFollowUpSection> {
  bool _isSaving = false;

  void _showAddFollowUpDialog(BuildContext context) {
    final suggestionController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'routine';
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(statefulContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Follow-up'.tr(statefulContext),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.neutral500,
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Suggestion text
                    Text(
                      'Recommendations / Suggestion'.tr(statefulContext),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: suggestionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Patient needs to reduce sodium intake'
                            .tr(statefulContext),
                        hintStyle: const TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.neutral200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.redDeep,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Dropdown
                    Text(
                      'Follow-up Type'.tr(statefulContext),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedType,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'routine',
                              child: Text('Routine'.tr(statefulContext)),
                            ),
                            DropdownMenuItem(
                              value: 'urgent',
                              child: Text('Urgent'.tr(statefulContext)),
                            ),
                            DropdownMenuItem(
                              value: 'follow_up',
                              child: Text('Follow Up'.tr(statefulContext)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Next Visit Date Picker
                    Text(
                      'Next Visit Date'.tr(statefulContext),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: statefulContext,
                          initialDate: DateTime.now().add(
                            const Duration(days: 7),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.redDeep,
                                  onPrimary: Colors.white,
                                  onSurface: AppColors.neutral800,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutral200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Select next visit date (Optional)'.tr(
                                      statefulContext,
                                    )
                                  : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: selectedDate == null
                                    ? AppColors.neutral450
                                    : AppColors.neutral800,
                                fontSize: 13,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.redDeep,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description text (Notes)
                    Text(
                      'Additional Notes'.tr(statefulContext),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Monitor blood pressure weekly'.tr(
                          statefulContext,
                        ),
                        hintStyle: const TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.neutral200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.redDeep,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (suggestionController.text.trim().isEmpty) {
                                  AppToast.show(
                                    statefulContext,
                                    'Please enter suggestions or recommendations.'
                                        .tr(statefulContext),
                                    type: AppToastType.warning,
                                    role: UserRole.doctor,
                                  );
                                  return;
                                }

                                setDialogState(() => _isSaving = true);
                                try {
                                  final formattedDate = selectedDate != null
                                      ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                      : null;

                                  await ref
                                      .read(
                                        doctorFollowUpControllerProvider(
                                          widget.patientId,
                                        ).notifier,
                                      )
                                      .addFollowUp(
                                        suggestionText: suggestionController
                                            .text
                                            .trim(),
                                        description:
                                            descriptionController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : descriptionController.text.trim(),
                                        nextVisit: formattedDate,
                                        followUpType: selectedType,
                                      );

                                  if (statefulContext.mounted) {
                                    AppToast.show(
                                      statefulContext,
                                      'Follow-up recommendation added successfully.'
                                          .tr(statefulContext),
                                      type: AppToastType.success,
                                      role: UserRole.doctor,
                                    );
                                    Navigator.pop(dialogContext);
                                  }
                                } catch (e) {
                                  if (statefulContext.mounted) {
                                    AppToast.show(
                                      statefulContext,
                                      'Failed to add follow-up: $e'.tr(
                                        statefulContext,
                                      ),
                                      type: AppToastType.error,
                                      role: UserRole.doctor,
                                    );
                                  }
                                } finally {
                                  setDialogState(() => _isSaving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redDeep,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularLoadingIndicator(
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                'Save Follow-up'.tr(statefulContext),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildFollowUpItem(BuildContext context, DoctorFollowUpEntity item) {
    final bool isUrgent = item.followUpType == 'urgent';
    final Color typeColor = isUrgent
        ? AppColors.redDeep
        : item.followUpType == 'routine'
        ? const Color(0xFF1E88E5)
        : AppColors.tealP;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.followUpType.toUpperCase(),
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.neutral400,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.suggestionText,
            style: const TextStyle(
              color: AppColors.neutral900,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: const TextStyle(
                color: AppColors.neutral600,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if (item.nextVisit != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.neutral200, height: 1),
            ),
            Row(
              children: [
                const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.redDeep,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Next Visit:'.tr(context),
                  style: const TextStyle(
                    color: AppColors.neutral600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.nextVisit),
                  style: const TextStyle(
                    color: AppColors.neutral800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorFollowUpControllerProvider(widget.patientId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        state.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularLoadingIndicator(
                size: 32,
                color: AppColors.redDeep,
              ),
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.redSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${'Error loading follow-ups:'.tr(context)} $err',
              style: const TextStyle(color: AppColors.redDeep),
            ),
          ),
          data: (followUps) {
            if (followUps.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.playlist_add_check_rounded,
                      size: 48,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No follow-ups recorded'.tr(context),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add doctor instructions or schedule next visits for this patient.'
                          .tr(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: followUps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildFollowUpItem(context, followUps[index]);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showAddFollowUpDialog(context),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(
              'Add Follow-up'.tr(context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
