import sys

filepath = 'e:/backend_grad_project/lib/features/patient/presentation/widgets/profile/profile_meds_tab.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _fetchMedications
old_fetch = """          return {
            'id': e['id']?.toString() ?? '',
            'name': e['name'] ?? 'Unknown',
            'hour': hour,
            'minute': minute,
            'imageUrl': e['image_url'], // Optional
          };"""
new_fetch = """          return {
            'id': e['id']?.toString() ?? '',
            'name': e['name'] ?? 'Unknown',
            'dosage': e['dosage'] ?? '',
            'frequency': e['frequency'] ?? '',
            'hour': hour,
            'minute': minute,
            'imageUrl': e['image_url'], // Optional
          };"""
content = content.replace(old_fetch, new_fetch)

# 2. Update _showAddEditBottomSheet definitions
old_defs = """    final TextEditingController nameController = TextEditingController(
      text: data?['name'] ?? '',
    );
    TimeOfDay selectedTime = isEdit"""
new_defs = """    final TextEditingController nameController = TextEditingController(
      text: data?['name'] ?? '',
    );
    final TextEditingController dosageController = TextEditingController(
      text: data?['dosage'] ?? '',
    );
    final TextEditingController frequencyController = TextEditingController(
      text: data?['frequency'] ?? 'Daily',
    );
    TimeOfDay selectedTime = isEdit"""
content = content.replace(old_defs, new_defs)

# 3. Add fields in UI
old_ui_fields = """                          // Time selector
                          GestureDetector("""
new_ui_fields = """                          // Dosage field
                          const SizedBox(height: 16),
                          TextField(
                            controller: dosageController,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14,
                              color: AppColors.neutral900,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Dosage'.tr(ctx),
                              labelStyle: TextStyle(
                                color: AppColors.tealP,
                                fontFamily: font,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.monitor_weight_outlined,
                                color: AppColors.tealP,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3FAFB),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.tealP, width: 2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.border),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Frequency field
                          TextField(
                            controller: frequencyController,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14,
                              color: AppColors.neutral900,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Frequency'.tr(ctx),
                              labelStyle: TextStyle(
                                color: AppColors.tealP,
                                fontFamily: font,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.repeat_rounded,
                                color: AppColors.tealP,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3FAFB),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.tealP, width: 2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.border),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time selector
                          GestureDetector("""
content = content.replace(old_ui_fields, new_ui_fields)


# 4. Update onSave API calls
old_on_save = """                if (isEdit) {
                  await MedicationRemoteDataSource.updateMedication(
                    id: int.parse(medDoc!['id']),
                    name: name,
                    dosage: '1', // default for now
                    isActive: true,
                  );
                } else {
                  await MedicationRemoteDataSource.addMedication(
                    name: name,
                    dosage: '1',
                    frequency: 'Daily',
                    reminderTime: reminderStr,
                  );
                }"""
new_on_save = """                if (isEdit) {
                  await MedicationRemoteDataSource.updateMedication(
                    id: int.parse(medDoc!['id']),
                    name: name,
                    dosage: dosageController.text.trim().isEmpty ? '1' : dosageController.text.trim(),
                    frequency: frequencyController.text.trim().isEmpty ? 'Daily' : frequencyController.text.trim(),
                    reminderTime: reminderStr,
                    isActive: true,
                  );
                } else {
                  await MedicationRemoteDataSource.addMedication(
                    name: name,
                    dosage: dosageController.text.trim().isEmpty ? '1' : dosageController.text.trim(),
                    frequency: frequencyController.text.trim().isEmpty ? 'Daily' : frequencyController.text.trim(),
                    reminderTime: reminderStr,
                  );
                }"""
content = content.replace(old_on_save, new_on_save)


# 5. Fix build method to render list
old_build_end = """        else if (_meds.isEmpty)
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
                  Icons.medication_liquid_rounded,
                  size: 48,
                  color: AppColors.tealP.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No medications listed'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: font,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your daily medications and schedule notifications so you never miss a dose.'
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
}"""
new_build_end = """        else if (_meds.isEmpty)
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
                  Icons.medication_liquid_rounded,
                  size: 48,
                  color: AppColors.tealP.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No medications listed'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: font,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your daily medications and schedule notifications so you never miss a dose.'
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
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _meds.length,
            itemBuilder: (context, index) {
              final med = _meds[index];
              final timeStr = TimeOfDay(hour: med['hour'], minute: med['minute']).format(context);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neutral300.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.tealBorderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: med['imageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(med['imageUrl'], width: 48, height: 48, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.tealSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.medication_rounded, color: AppColors.tealP),
                        ),
                  title: Text(
                    med['name'],
                    style: TextStyle(
                      fontFamily: font,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.neutral900,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.monitor_weight_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${med['dosage']}', style: TextStyle(fontFamily: font, fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 12),
                          const Icon(Icons.repeat_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${med['frequency']}', style: TextStyle(fontFamily: font, fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.tealP),
                          const SizedBox(width: 4),
                          Text(timeStr, style: TextStyle(fontFamily: font, fontSize: 12, color: AppColors.tealP, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.tealP),
                        onPressed: () => _showAddEditBottomSheet(medDoc: med),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteMedication(med),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}"""
content = content.replace(old_build_end, new_build_end)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("File successfully modified.")
