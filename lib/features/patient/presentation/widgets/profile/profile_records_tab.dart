import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../../shared/presentation/widgets/messages/full_screen_image_viewer.dart';
import '../../../../../shared/presentation/pages/pdf_viewer_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileRecordsTab extends ConsumerStatefulWidget {
  const ProfileRecordsTab({super.key});

  @override
  ConsumerState<ProfileRecordsTab> createState() => _ProfileRecordsTabState();
}

class _ProfileRecordsTabState extends ConsumerState<ProfileRecordsTab> {
  late Stream<QuerySnapshot> _uploadsStream;
  bool _imagesExpanded = false;
  bool _pdfsExpanded = false;
  bool _matsExpanded = false;

  @override
  void initState() {
    super.initState();
    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    _uploadsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('uploads')
        .orderBy('createdAt', descending: true)
        .snapshots();
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
    return StreamBuilder<QuerySnapshot>(
      stream: _uploadsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularLoadingIndicator(
                size: 36,
                color: AppColors.tealP,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.tealBorderLight.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: AppColors.tealP.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No files uploaded yet'.tr(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your uploaded diagnostic reports, prescriptions, and ECG/PPG files will appear here.'.tr(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        // Filter documents by type
        final imageDocs = docs.where((doc) {
          final name =
              (doc.data() as Map<String, dynamic>)['fileName']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return name.endsWith('.png') ||
              name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.webp') ||
              name.endsWith('.gif');
        }).toList();

        final pdfDocs = docs.where((doc) {
          final name =
              (doc.data() as Map<String, dynamic>)['fileName']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return name.endsWith('.pdf');
        }).toList();

        final matDocs = docs.where((doc) {
          final name =
              (doc.data() as Map<String, dynamic>)['fileName']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return name.endsWith('.mat') || name.endsWith('.csv') || name.endsWith('.txt');
        }).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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

            // Category Card 3: Data Files (MAT, CSV, TXT)
            _buildCategoryCard(
              title: 'Data Files'.tr(context),
              count: matDocs.length,
              icon: Icons.grid_on_outlined,
              isExpanded: _matsExpanded,
              onTap: () => setState(() => _matsExpanded = !_matsExpanded),
              children: matDocs,
            ),
            const SizedBox(height: 120),
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
    required List<QueryDocumentSnapshot> children,
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
                      colors: [Color(0xFFEBF6F8), Colors.white],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: !isExpanded
                  ? Border.all(
                      color: AppColors.tealP.withValues(alpha: 0.15),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (!isExpanded) ...[
                  Icon(icon, color: AppColors.tealP, size: 22),
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
                          : AppColors.tealPrimaryDark,
                    ),
                  ),
                ),
                if (!isExpanded) ...[
                  Text(
                    '$count files'.tr(context),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? AppColors.black : AppColors.tealP,
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
                  child: Text(
                    'No files in this category'.tr(context),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                    final data = children[index].data() as Map<String, dynamic>;
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
    final timestamp = data['createdAt'] as Timestamp?;

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
        : AppColors.textSecondary;

    final IconData fileIcon = isPdf
        ? Icons.picture_as_pdf_rounded
        : isImage
        ? Icons.image_rounded
        : isDataSheet
        ? Icons.table_chart_rounded
        : Icons.insert_drive_file_rounded;

    String dateStr = 'N/A';
    if (timestamp != null) {
      final date = timestamp.toDate();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = '${date.day} ${months[date.month - 1].tr(context)} ${date.year}';
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
          border: Border.all(color: AppColors.border, width: 1),
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
                    style: const TextStyle(
                      color: AppColors.neutral900,
                      fontSize: 13,
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Uploaded: $dateStr'.tr(context),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
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
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

