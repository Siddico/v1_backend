import 'package:flutter/material.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_custom.dart';
// import 'package:grad_imp_1/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'request_service.dart';
import '../../shared/ui/toast_service.dart';
import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';

class DoctorRequestsView extends ConsumerWidget {
  const DoctorRequestsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;
    if (user == null) return const Center(child: Text('Not authenticated'));

    final stream = RequestService.streamDoctorRequests(
      doctorId: user.id.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'Connection Requests',
        onBack: () => Navigator.pop(context),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.redPrimary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load requests: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularLoadingIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, color: Colors.grey, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          // Sort by latest assuming ISO8601 strings from backend
          requests.sort((a, b) {
            final aTs = a['requested_at']?.toString() ?? '';
            final bTs = b['requested_at']?.toString() ?? '';
            return bTs.compareTo(aTs);
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _DoctorRequestTile(data: requests[index]);
            },
          );
        },
      ),
    );
  }
}

class _DoctorRequestTile extends StatefulWidget {
  final Map<String, dynamic> data;
  const _DoctorRequestTile({required this.data});

  @override
  State<_DoctorRequestTile> createState() => _DoctorRequestTileState();
}

class _DoctorRequestTileState extends State<_DoctorRequestTile> {
  bool _isProcessing = false;

  String _formatTimestamp(dynamic requestedAt) {
    if (requestedAt == null || requestedAt.toString().isEmpty) return '';
    try {
      final date = DateTime.parse(requestedAt.toString()).toLocal();
      return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
    } catch (_) {
      return requestedAt.toString();
    }
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  Future<void> _handleAccept(BuildContext context, String patientName) async {
    setState(() => _isProcessing = true);
    try {
      await RequestService.acceptRequest(
        requestId: widget.data['id'].toString(),
      );
      if (mounted) {
        ToastService.showSuccess('Connected with $patientName');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Failed to accept connection: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDecline(BuildContext context, String patientName) async {
    setState(() => _isProcessing = true);
    try {
      await RequestService.declineRequest(
        requestId: widget.data['id'].toString(),
      );
      if (mounted) {
        ToastService.showInfo('Declined connection with $patientName');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Failed to decline connection: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.data['patient_name'] ?? 'Patient';
    final patientPhoto = widget.data['patient_photo'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF0F1F3), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.redSecondary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: (patientPhoto.isNotEmpty)
                          ? NetworkImage(patientPhoto)
                          : const AssetImage(AppImages.patientImage)
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.data['requested_at']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.redSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.redDeep,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if ((widget.data['message'] ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutralLighter.withValues(alpha: 0.5),
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd: Radius.circular(12),
                    bottomStart: Radius.circular(12),
                    bottomEnd: Radius.circular(12),
                  ),
                ),
                child: Text(
                  widget.data['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _handleDecline(context, patientName),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textGray,
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _handleAccept(context, patientName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
