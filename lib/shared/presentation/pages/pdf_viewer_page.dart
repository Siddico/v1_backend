import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/role_controller.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_custom.dart';

/// Downloads a PDF from [url] and renders it in-app.
class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.url, this.title = 'Document'});

  final String url;
  final String title;

  static void show(BuildContext context, String url, {String title = 'Document'}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(url: url, title: title),
      ),
    );
  }

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localPath;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode != 200) {
        setState(() => _error = 'Failed to load PDF (${response.statusCode})');
        return;
      }
      final dir = await getTemporaryDirectory();
      final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) setState(() => _localPath = file.path);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final role = ref.watch(roleProvider);
        final isDoctor = role == UserRole.doctor;
        final primaryColor = isDoctor ? AppColors.redDeep : AppColors.tealP;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: widget.title,
            onBack: () => Navigator.of(context).pop(),
            actions: [
              if (_totalPages > 0)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                    ],
                  ),
                )
              : _localPath == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          const Text('Loading document...'),
                        ],
                      ),
                    )
                  : PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      onRender: (pages) {
                        if (mounted) {
                          setState(() {
                            _totalPages = pages ?? 0;
                          });
                        }
                      },
                      onPageChanged: (page, total) {
                        if (mounted) {
                          setState(() {
                            _currentPage = page ?? 0;
                            _totalPages = total ?? 0;
                          });
                        }
                      },
                      onError: (error) {
                        if (mounted) setState(() => _error = error.toString());
                      },
                    ),
        );
      },
    );
  }
}

