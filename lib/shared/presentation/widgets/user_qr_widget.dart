import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that encodes the current user's ID and role into a JSON payload
/// and renders it as an actual scannable QR code image.
class UserQrWidget extends ConsumerStatefulWidget {
  /// Visual size of the rendered QR code (width and height in logical pixels).
  final double size;

  /// Background colour of the QR code area.
  final Color backgroundColor;

  /// Foreground colour of the QR code modules and eyes.
  final Color qrColor;

  /// Whether to allow tapping the QR code to open the share dialog.
  final bool allowShare;

  const UserQrWidget({
    super.key,
    this.size = 56,
    this.backgroundColor = Colors.white,
    this.qrColor = AppColors.tealP,
    this.allowShare = true,
  });

  @override
  ConsumerState<UserQrWidget> createState() => _UserQrWidgetState();
}

class _UserQrWidgetState extends ConsumerState<UserQrWidget> {
  String? _qrData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;

    if (user == null) {
      return Icon(
        Icons.qr_code_2_rounded,
        size: widget.size,
        color: Colors.black87,
      );
    }

    _qrData = jsonEncode({'uid': user.id.toString(), 'role': user.role.value});

    if (_qrData == null) {
      // No data — show a placeholder icon.
      return Icon(
        Icons.qr_code_2_rounded,
        size: widget.size,
        color: Colors.black87,
      );
    }

    final qrImage = QrImageView(
      data: _qrData!,
      version: QrVersions.auto,
      size: widget.size,
      backgroundColor: widget.backgroundColor,
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
      errorStateBuilder: (ctx, err) =>
          Icon(Icons.qr_code_2_rounded, size: widget.size, color: Colors.black),
    );

    if (widget.allowShare) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) =>
                QrShareDialog(qrData: _qrData!, qrColor: widget.qrColor),
          );
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: 'Tap to view and share QR code'.tr(context),
            child: qrImage,
          ),
        ),
      );
    }

    return qrImage;
  }
}

class QrShareDialog extends StatefulWidget {
  final String qrData;
  final Color qrColor;

  const QrShareDialog({super.key, required this.qrData, required this.qrColor});

  @override
  State<QrShareDialog> createState() => _QrShareDialogState();
}

class _QrShareDialogState extends State<QrShareDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _sharing = false;
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    try {
      final decoded = jsonDecode(widget.qrData);
      _userId = decoded['uid']?.toString();
      _userRole = decoded['role']?.toString();
    } catch (_) {}
  }

  Future<void> _shareQr() async {
    if (_sharing) return;
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _sharing = true);

    try {
      // Small delay to ensure the widget has laid out and rendered
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find repaint boundary context');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/qr_code.png');
      await tempFile.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          // ignore: use_build_context_synchronously
          text: 'Scan this QR code to connect with me.'.tr(context),
          sharePositionOrigin: box != null
              ? (box.localToGlobal(Offset.zero) & box.size)
              : null,
        ),
      );
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to share QR Code: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My QR Code'.tr(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.qrColor,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _boundaryKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: widget.qrData,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _sharing ? null : _shareQr,
                icon: _sharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                label: Text(
                  _sharing
                      ? 'Preparing Image...'.tr(context)
                      : 'Share QR Code'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.qrColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_userId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _userId!));
                    if (!context.mounted) return;
                    Fluttertoast.showToast(
                      msg: _userRole == 'doctor'
                          ? 'Doctor ID copied to clipboard!'.tr(context)
                          : 'User ID copied to clipboard!'.tr(context),
                    );
                  },
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: widget.qrColor,
                  ),
                  label: Text(
                    'Copy ID'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.qrColor,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.qrColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Tapping share will send a high-quality scan-ready image.'.tr(
                context,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black38,
                fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
