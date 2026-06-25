import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_custom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'request_service.dart';
import '../../shared/ui/toast_service.dart';
import '../../core/constants/app_images.dart';

class MyRequestsPage extends ConsumerWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;
    if (user == null) return const Center(child: Text('Not authenticated'));

    final stream = RequestService.streamPatientRequests(
      patientId: user.id.toString(),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Requests',
        onBack: () => Navigator.pop(context),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularLoadingIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No requests'));
          }

          final requests = snapshot.data!;
          requests.sort((a, b) {
            final aTs = a['requested_at']?.toString() ?? '';
            final bTs = b['requested_at']?.toString() ?? '';
            return bTs.compareTo(aTs);
          });

          return ListView(
            children: requests.map((req) {
              return _PatientRequestTile(data: req);
            }).toList(),
          );
        },
      ),
    );
  }
}

class _PatientRequestTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PatientRequestTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final doctorName = data['doctor_name'] ?? 'Doctor';
    final doctorPhoto = data['doctor_photo'] ?? '';
    final status = data['status'] ?? 'pending';
    final requestId = data['id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (doctorPhoto.isNotEmpty)
              ? NetworkImage(doctorPhoto)
              : const AssetImage(AppImages.makramImage) as ImageProvider,
        ),
        title: Text(
          doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(data['message'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'pending')
              TextButton(
                onPressed: () async {
                  try {
                    await RequestService.cancelRequest(requestId: requestId);
                    if (context.mounted)
                      ToastService.showInfo('Request cancelled');
                  } catch (e) {
                    if (context.mounted)
                      ToastService.showError('Failed to cancel: $e');
                  }
                },
                child: Text('Cancel'.tr(context)),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Chip(label: Text(status.toString().toUpperCase())),
            ),
          ],
        ),
      ),
    );
  }
}
