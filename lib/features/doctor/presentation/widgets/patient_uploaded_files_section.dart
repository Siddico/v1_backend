import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:dio/dio.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/full_screen_image_viewer.dart';
import 'package:grad_imp_1/shared/presentation/pages/pdf_viewer_page.dart';

class PatientUploadedFilesSection extends StatefulWidget {
  final String patientId;

  const PatientUploadedFilesSection({super.key, required this.patientId});

  @override
  State<PatientUploadedFilesSection> createState() =>
      _PatientUploadedFilesSectionState();
}

class _PatientUploadedFilesSectionState
    extends State<PatientUploadedFilesSection> {
  late Future<List<Map<String, dynamic>>> _uploadsFuture;
  bool _imagesExpanded = false;
  bool _pdfsExpanded = false;
  bool _matsExpanded = false;

  @override
  void initState() {
    super.initState();
    _uploadsFuture = _fetchDocuments();
  }

  Future<List<Map<String, dynamic>>> _fetchDocuments() async {
    try {
      final dio = await DioFactory.getDio();
      
      // Fetch both radiology and lab documents
      final results = await Future.wait([
        dio.get(ApiConstants.doctorRadiology, queryParameters: {'patient_id': widget.patientId}),
        dio.get(ApiConstants.doctorLabDocuments, queryParameters: {'patient_id': widget.patientId}),
      ]);

      final List<Map<String, dynamic>> combined = [];

      for (var response in results) {
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final data = response.data['data'] as List<dynamic>? ?? [];
          for (var item in data) {
            final doc = item as Map<String, dynamic>;
            combined.add({
              'fileName': doc['file_name'] ?? doc['title'] ?? 'Document',
              'downloadUrl': doc['file_url'] ?? doc['url'] ?? '',
              'category': doc['type'] ?? doc['imaging_type'] ?? doc['category'] ?? 'other',
              'createdAt': doc['uploaded_at'] ?? doc['created_at'],
            });
          }
        }
      }

      // Sort by newest first
      combined.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      return combined;
    } catch (e) {
      debugPrint('Error fetching patient documents: $e');
      return [];
    }
  }

  String _cleanCategoryName(BuildContext context, String category) {
    switch (category) {
      case 'ecg_signals':
        return 'ECG Signals'.tr(context);
      case 'ppg_signals':
        return 'PPG Signals'.tr(context);
      case 'prescription':
        return 'Prescriptions & Lab'.tr(context);
      default:
        return category.toUpperCase();
    }
  }

  Future<void> _handleFileTap(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    final lowerName = fileName.toLowerCase();
    final isPdf = lowerName.endsWith('.pdf');
    final isImage =
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.gif');

    if (isImage) {
      FullScreenImageViewer.show(context, url);
    } else if (isPdf) {
      PdfViewerPage.show(context, url, title: fileName);
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _uploadsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularLoadingIndicator(
                size: 36,
                color: AppColors.redDeep,
              ),
            ),
          );
        }

        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
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
                Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: AppColors.neutral450.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 12),
                Text(
                  'No files uploaded yet'.tr(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'When the patient uploads diagnostic files or prescriptions, they will appear here.'
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

        // Filter documents by type
        final imageDocs = docs.where((doc) {
          final name = doc['fileName']?.toString().toLowerCase() ?? '';
          return name.endsWith('.png') ||
              name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.webp') ||
              name.endsWith('.gif');
        }).toList();

        final pdfDocs = docs.where((doc) {
          final name = doc['fileName']?.toString().toLowerCase() ?? '';
          return name.endsWith('.pdf');
        }).toList();

        final matDocs = docs.where((doc) {
          final name = doc['fileName']?.toString().toLowerCase() ?? '';
          return name.endsWith('.mat');
        }).toList();

        return Column(
          children: [
            // Category Card 1: Images
            _buildCategoryCard(
              title: 'Images'.tr(context),
              count: imageDocs.length,
              icon: Icons.image_outlined,
              isExpanded: _imagesExpanded,
              onTap: () => setState(() => _imagesExpanded = !_imagesExpanded),
              children: imageDocs,
            ),
            const SizedBox(height: 12),

            // Category Card 2: PDFs
            _buildCategoryCard(
              title: 'PDF Documents'.tr(context),
              count: pdfDocs.length,
              icon: Icons.picture_as_pdf_outlined,
              isExpanded: _pdfsExpanded,
              onTap: () => setState(() => _pdfsExpanded = !_pdfsExpanded),
              children: pdfDocs,
            ),
            const SizedBox(height: 12),

            // Category Card 3: MAT Files
            _buildCategoryCard(
              title: 'MAT Files'.tr(context),
              count: matDocs.length,
              icon: Icons.grid_on_outlined,
              isExpanded: _matsExpanded,
              onTap: () => setState(() => _matsExpanded = !_matsExpanded),
              children: matDocs,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required int count,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Map<String, dynamic>> children,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: isExpanded
                ? const EdgeInsets.symmetric(vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isExpanded ? Colors.transparent : null,
              gradient: !isExpanded
                  ? const LinearGradient(
                      colors: [Color(0xFFFFF2F2), Colors.white],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: !isExpanded
                  ? Border.all(
                      color: AppColors.redMaroon.withValues(alpha: 0.15),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (!isExpanded) ...[
                  Icon(icon, color: AppColors.redDeep, size: 22),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      fontWeight: isExpanded
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isExpanded
                          ? AppColors.neutralBlack
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (!isExpanded) ...[
                  Text(
                    '$count files',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? AppColors.black : AppColors.redDeep,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 8),
              if (children.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    'No files in this category',
                    style: TextStyle(color: AppColors.neutral450, fontSize: 12),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final data = children[index];
                    return _buildCompactFileRow(context, data);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildCompactFileRow(BuildContext context, Map<String, dynamic> data) {
    final fileName = data['fileName']?.toString() ?? 'Unnamed File';
    final url = data['downloadUrl']?.toString() ?? '';
    final category = data['category']?.toString() ?? 'other';
    final timestampString = data['createdAt']?.toString();

    final lowerName = fileName.toLowerCase();
    final isPdf = lowerName.endsWith('.pdf');
    final isImage =
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.webp');
    final isDataSheet =
        lowerName.endsWith('.csv') ||
        lowerName.endsWith('.txt') ||
        lowerName.endsWith('.mat');

    final Color accentColor = isPdf
        ? const Color(0xFFD32F2F)
        : isImage
        ? AppColors.tealP
        : isDataSheet
        ? const Color(0xFF1565C0)
        : AppColors.neutral500;

    final IconData fileIcon = isPdf
        ? Icons.picture_as_pdf_rounded
        : isImage
        ? Icons.image_rounded
        : isDataSheet
        ? Icons.table_chart_rounded
        : Icons.insert_drive_file_rounded;

    String dateStr = 'N/A';
    if (timestampString != null && timestampString.isNotEmpty) {
      final date = DateTime.tryParse(timestampString);
      if (date != null) {
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
        dateStr = '${date.day} ${months[date.month - 1]} ${date.year}';
      }
    }

    final String typeLabel = _cleanCategoryName(context, category);

    return InkWell(
      onTap: () => _handleFileTap(context, url, fileName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(fileIcon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.neutral900,
                      fontSize: 13,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 9,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.neutral400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${'Uploaded:'.tr(context)} $dateStr',
                          style: TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 10,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

