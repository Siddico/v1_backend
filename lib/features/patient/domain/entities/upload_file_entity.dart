enum UploadFileStatus { success, error }

class UploadFileItem {
  const UploadFileItem({
    required this.name,
    required this.status,
    required this.progress,
    required this.message,
  });

  final String name;
  final UploadFileStatus status;
  final double progress;
  final String message;

  bool get isSuccess => status == UploadFileStatus.success;
}
