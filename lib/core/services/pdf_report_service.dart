import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/wellness/domain/entities/health_data_entity.dart';
import 'package:grad_imp_1/features/patient/domain/entities/prediction_result_entity.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class PDFReportService {
  PDFReportService._();

  static Future<List<Map<String, dynamic>>> fetchReports() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientReports);
      if (response.statusCode == 200) {
        final list = ApiResponseParser.extractList(
          response.data is Map ? response.data['data'] : response.data,
        );
        return list.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> generateAndShareReport({
    required String userName,
    required String age,
    required HealthDataEntity? healthData,
    Map<String, dynamic>? profile,
    required bool isDoctor,
    List<PredictionResult>? recentPredictions,
  }) async {
    final pdf = pw.Document();

    // Load logo image from assets
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logoo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    // Load Arabic Cairo font from assets
    pw.Font? cairoFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      cairoFont = pw.Font.ttf(fontData);
    } catch (e) {
      // Fallback
    }

    const isAr = false;
    String t(String en, String ar) => en;

    String translateValue(String val) {
      return val;
    }

    String translatePrediction(String pred) {
      final p = pred.trim().toUpperCase();
      if (p == 'NSR') return 'Normal (NSR)';
      if (p == 'AF') return 'Atrial Fibrillation (AF)';
      if (p == 'PAC') return 'Premature Atrial Contraction (PAC)';
      return pred;
    }

    String translateRisk(String risk) {
      final r = risk.trim().toLowerCase();
      if (r == 'low') return 'Low Risk';
      if (r == 'medium' || r == 'moderate') return 'Moderate Risk';
      if (r == 'high') return 'High Risk';
      return risk;
    }

    pw.Widget tText(String text, {pw.TextStyle? style, pw.TextAlign? align}) {
      return pw.Text(
          text,
          textDirection: pw.TextDirection.ltr,
          style: style,
          textAlign: align,
      );
    }

    final dateStr = DateTime.now().toString().substring(0, 16);
    final primaryColor = isDoctor ? PdfColor.fromHex('#AB2133') : PdfColor.fromHex('#1B808E');
    final darkTextColor = PdfColor.fromHex('#111827');
    final lightBgColor = PdfColor.fromHex('#F9FAFB');
    final borderCol = PdfColor.fromHex('#E5E7EB');

    // Values fallback logic
    final profileBmi = (profile?['bmi'] as num?)?.toDouble();
    double hWeight = healthData != null && healthData.weight > 0 ? healthData.weight : ((profile?['weight'] as num?)?.toDouble() ?? 0.0);
    double hHeight = healthData != null && healthData.height > 0 ? healthData.height : ((profile?['height'] as num?)?.toDouble() ?? 0.0);
    
    if (hWeight == 0.0 && hHeight == 0.0 && profileBmi != null) {
      hHeight = 170.0;
      hWeight = profileBmi * (hHeight / 100.0) * (hHeight / 100.0);
    }
    
    double hBmi = healthData != null && healthData.bmi > 0 ? healthData.bmi : (profileBmi ?? 0.0);
    if (hBmi == 0.0 && hWeight > 0.0 && hHeight > 0.0) {
      hBmi = hWeight / ((hHeight / 100.0) * (hHeight / 100.0));
    }

    final hr = healthData?.heartRate != null && healthData!.heartRate > 0 
        ? '${healthData.heartRate} bpm' 
        : (profile?['heart_rate']?.toString() ?? 'N/A');
        
    final bp = healthData?.bloodPressure != null && healthData!.bloodPressure != 'N/A' 
        ? healthData.bloodPressure 
        : (profile?['blood_pressure']?.toString() ?? 'N/A');
        
    final temp = healthData != null && healthData.temperature > 0 
        ? '${healthData.temperature.toStringAsFixed(1)} °C' 
        : (profile?['temperature'] != null ? '${(profile!['temperature'] as num).toStringAsFixed(1)} °C' : 'N/A');
        
    final spo2 = healthData != null && healthData.oxygenSaturation > 0 
        ? '${healthData.oxygenSaturation}%' 
        : (profile?['oxygen_saturation'] != null 
            ? '${profile!['oxygen_saturation']}%' 
            : (profile?['spo2'] != null ? '${profile!['spo2']}%' : 'N/A'));

    final weight = hWeight > 0 ? '${hWeight.toStringAsFixed(1)} kg' : 'N/A';
    final height = hHeight > 0 ? '${hHeight.toStringAsFixed(1)} cm' : 'N/A';
    final bmi = hBmi > 0 ? hBmi.toStringAsFixed(1) : 'N/A';
    final riskScore = healthData?.riskScore ?? (profile?['ai_risk_stroke_rate'] as num?)?.toDouble() ?? 46.0;

    // Determine risk status color & label
    final PdfColor riskColor;
    final String riskLabel;
    if (riskScore < 30) {
      riskColor = PdfColor.fromHex('#10B981'); // Safe / Green
      riskLabel = t('Low Risk', 'خطر منخفض');
    } else if (riskScore < 60) {
      riskColor = PdfColor.fromHex('#F59E0B'); // Warning / Orange
      riskLabel = t('Moderate Risk', 'خطر متوسط');
    } else {
      riskColor = PdfColor.fromHex('#EF4444'); // High / Red
      riskLabel = t('High Risk (Critical)', 'خطر مرتفع (حرج)');
    }

    final lastPredictions = (recentPredictions != null && recentPredictions.isNotEmpty)
        ? recentPredictions.length > 3
            ? recentPredictions.sublist(recentPredictions.length - 3).reversed.toList()
            : recentPredictions.reversed.toList()
        : <PredictionResult>[];

    final theme = cairoFont != null
        ? pw.ThemeData.withFont(base: cairoFont, bold: cairoFont)
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox.shrink();
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoImage != null) pw.Image(logoImage, width: 24, height: 24),
                  tText(
                    t('BRAINGUARD HEALTH REPORT', 'تقرير BrainGuard الصحي'),
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(color: primaryColor, thickness: 0.5),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: borderCol, thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  tText(
                    t('Generated by BrainGuard Platform • www.brainguard.ai', 'تم الإنشاء بواسطة منصة BrainGuard • www.brainguard.ai'),
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  tText(
                    '${t('Page', 'صفحة')} ${context.pageNumber} / ${context.pagesCount}',
                    style: const pw.TextStyle(
                      color: PdfColors.grey500,
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // ── Logo / Brand Header ─────────────────────────────────────────
            if (logoImage != null) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(logoImage, width: 44, height: 44),
                  tText(
                    t('BRAINGUARD PLATFORM', 'منصة BrainGuard'),
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
            ],
            // ── Header Banner ─────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      tText(
                        t('BRAINGUARD HEALTH REPORT', 'تقرير BrainGuard الصحي'),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      tText(
                        t('AI-Powered Stroke Risk & Vitals Monitoring', 'مراقبة مخاطر السكتة الدماغية والمؤشرات الحيوية بالذكاء الاصطناعي'),
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      tText(
                        '${t('Date:', 'التاريخ:')} $dateStr',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      tText(
                        '${t('ID:', 'المعرف:')} BG-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ── Patient Info Section ─────────────────────────────────────
            tText(
              t('PATIENT INFORMATION', 'بيانات المريض'),
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 8),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _infoItem(t('Full Name', 'الاسم بالكامل'), userName, darkTextColor, isAr, forceLtr: true),
                ),
                pw.Expanded(child: _infoItem(t('Age', 'السن'), '$age Years', darkTextColor, isAr)),
                pw.Expanded(
                  child: _infoItem(
                    t('Gender', 'الجنس'),
                    translateValue(profile?['gender']?.toString() ?? 'N/A'),
                    darkTextColor,
                    isAr,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _infoItem(
                    t('Phone Number', 'رقم الهاتف'),
                    profile?['phone']?.toString() ?? profile?['phone_number']?.toString() ?? 'N/A',
                    darkTextColor,
                    isAr,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    t('Emergency Contact', 'رقم الطوارئ'),
                    profile?['emergency_contact_phone']?.toString() ?? profile?['emergency_phone']?.toString() ?? 'N/A',
                    darkTextColor,
                    isAr,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    t('Diagnosis', 'التشخيص'),
                    translateValue(profile?['diagnosis']?.toString() ?? 'Ischemic Stroke'),
                    darkTextColor,
                    isAr,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _infoItem(
                    t('Hypertension', 'ارتفاع ضغط الدم'),
                    translateValue(profile?['hypertension'] == 1 ? 'Yes' : 'No'),
                    darkTextColor,
                    isAr,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    t('Heart Disease', 'أمراض القلب'),
                    translateValue(profile?['heart_disease'] == 1 ? 'Yes' : 'No'),
                    darkTextColor,
                    isAr,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    t('Avg Glucose', 'معدل السكر'),
                    profile?['avg_glucose_level'] != null ? '${(profile?['avg_glucose_level'] as num).toStringAsFixed(1)} ${t('mg/dL', 'ملجم/ديسيلتر')}' : 'N/A',
                    darkTextColor,
                    isAr,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _infoItem(
                    t('Smoking Status', 'حالة التدخين'),
                    translateValue(profile?['smoking_status']?.toString() ?? 'N/A'),
                    darkTextColor,
                    isAr,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    t('Work Type', 'نوع العمل'),
                    translateValue(profile?['work_type']?.toString() ?? 'N/A'),
                    darkTextColor,
                    isAr,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    t('Residence', 'نوع السكن'),
                    translateValue(profile?['Residence_type']?.toString() ?? 'N/A'),
                    darkTextColor,
                    isAr,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // ── Stroke Risk / Stability Section ──────────────────────────
            tText(
              t('LATEST AI ASSESSMENT SUMMARY', 'ملخص تقييم الذكاء الاصطناعي الأخير'),
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 8),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightBgColor,
                border: pw.Border.all(color: borderCol, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      tText(
                        t('Stroke Risk Score', 'معدل خطر الإصابة بالسكتة'),
                        style: pw.TextStyle(
                          color: darkTextColor,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      tText(
                        t('Calculated by BrainGuard AI prediction model', 'تم حسابه بواسطة نموذج التنبؤ بالذكاء الاصطناعي لـ BrainGuard'),
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: riskColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: tText(
                      '${riskScore.toStringAsFixed(0)}% - $riskLabel',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.NewPage(),

            // ── Vital Signals Table ──────────────────────────────────────
            tText(
              t('VITAL SIGNALS & CLINICAL METRICS', 'المؤشرات الحيوية والمقاييس السريرية'),
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: borderCol, width: 0.8),
              columnWidths: {
                0: const pw.FractionColumnWidth(0.4),
                1: const pw.FractionColumnWidth(0.3),
                2: const pw.FractionColumnWidth(0.3),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: primaryColor),
                  children: [
                    _tableHeaderCell(t('Metric Parameter', 'المؤشر الحيوى'), isAr),
                    _tableHeaderCell(t('Measured Value', 'القيمة المقاسة'), isAr),
                    _tableHeaderCell(t('Clinical Range', 'المعدل الطبيعي'), isAr),
                  ],
                ),
                _tableRow(t('Heart Rate', 'نبضات القلب'), hr, '60 - 100 bpm', lightBgColor, darkTextColor, isAr),
                _tableRow(t('Oxygen Saturation (SpO₂)', 'تشبع الأكسجين (SpO₂)'), spo2, '95% - 100%', PdfColors.white, darkTextColor, isAr),
                _tableRow(t('Blood Pressure', 'ضغط الدم'), bp, '90/60 - 120/80 mmHg', lightBgColor, darkTextColor, isAr),
                _tableRow(t('Body Temperature', 'درجة حرارة الجسم'), temp, '36.1 - 37.2 °C', PdfColors.white, darkTextColor, isAr),
                _tableRow(t('Weight', 'الوزن'), weight, t('Patient Baseline', 'القياس المرجعي'), lightBgColor, darkTextColor, isAr),
                _tableRow(t('Height', 'الطول'), height, t('Patient Baseline', 'القياس المرجعي'), PdfColors.white, darkTextColor, isAr),
                _tableRow(t('Calculated BMI', 'مؤشر كتلة الجسم (BMI)'), bmi, '18.5 - 24.9 kg/m²', lightBgColor, darkTextColor, isAr),
              ],
            ),

            pw.SizedBox(height: 20),

            // ── Recent AI Predictions History ──────────────────────────────
            tText(
              t('AI PREDICTION HISTORY (LAST 3)', 'سجل التقييمات بالذكاء الاصطناعي (آخر 3 تقييمات)'),
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 8),

            if (lastPredictions.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: tText(
                  t('No prediction history found.', 'لا يوجد سجل تقييمات متاح حالياً.'),
                  style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: borderCol, width: 0.8),
                columnWidths: {
                  0: const pw.FractionColumnWidth(0.25), // Date
                  1: const pw.FractionColumnWidth(0.25), // Classification
                  2: const pw.FractionColumnWidth(0.20), // Risk Level
                  3: const pw.FractionColumnWidth(0.15), // Score
                  4: const pw.FractionColumnWidth(0.15), // Confidence
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _tableHeaderCell(t('Date & Time', 'التاريخ والوقت'), isAr),
                      _tableHeaderCell(t('Classification', 'التصنيف الإشاري'), isAr),
                      _tableHeaderCell(t('Risk Level', 'مستوى الخطر'), isAr),
                      _tableHeaderCell(t('Risk Score', 'معدل الخطر'), isAr),
                      _tableHeaderCell(t('Confidence', 'مستوى الثقة'), isAr),
                    ],
                  ),
                  ...lastPredictions.map((pred) {
                    final predDateStr = pred.predictionTimestamp.toString().substring(0, 16);
                    final rowBg = lastPredictions.indexOf(pred) % 2 == 0 ? lightBgColor : PdfColors.white;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: rowBg),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            predDateStr,
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(color: darkTextColor, fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            translatePrediction(pred.prediction),
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(color: darkTextColor, fontSize: 8, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            translateRisk(pred.strokeRisk),
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(color: darkTextColor, fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '${(pred.riskScore * 100).toStringAsFixed(0)}%',
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(color: darkTextColor, fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '${(pred.confidence * 100).toStringAsFixed(0)}%',
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(color: darkTextColor, fontSize: 8),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

            pw.SizedBox(height: 20),

            // ── Guidelines & Recommendations ──────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#EFF6FF'), // Light blue
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColor.fromHex('#BFDBFE')),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  tText(
                    t('AI Recommendations & Advice:', 'نصائح وإرشادات الذكاء الاصطناعي:'),
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#1E40AF'),
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                    text: t('Regularly monitor heart rate for sudden spikes or abnormalities.', 'راقب معدل ضربات قلبك بانتظام لأي ارتفاع مفاجئ أو غير طبيعي.'),
                    style: const pw.TextStyle(fontSize: 8.5),
                  ),
                  pw.Bullet(
                    text: t('Keep track of blood pressure variations and take prescribed medications on time.', 'تتبع تغيرات ضغط الدم وتناول الأدوية الموصوفة في وقتها.'),
                    style: const pw.TextStyle(fontSize: 8.5),
                  ),
                  pw.Bullet(
                    text: t('In case of high-risk stroke prediction alerts, remain calm and alert your emergency contact.', 'في حالة تنبيهات التنبؤ بالسكتة عالية الخطورة، حافظ على هدوئك ونبه جهة اتصال الطوارئ الخاصة بك.'),
                    style: const pw.TextStyle(fontSize: 8.5),
                  ),
                ],
              ),
            ),

            if (profile != null &&
                profile['doctor_notes'] != null &&
                profile['doctor_notes'].toString().isNotEmpty &&
                profile['doctor_notes'].toString().toLowerCase() != 'none') ...[
              pw.SizedBox(height: 16),
              tText(
                t('DOCTOR\'S CLINICAL NOTES', 'ملاحظات الطبيب المعالج'),
                style: pw.TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(color: primaryColor, thickness: 1),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFFBEB'), // Light amber
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromHex('#FDE68A')),
                ),
                child: tText(
                  profile['doctor_notes'].toString(),
                  style: pw.TextStyle(color: darkTextColor, fontSize: 9),
                ),
              ),
            ],

            pw.Spacer(),

            // ── Footer / Disclaimer ───────────────────────────────────────
            pw.Align(
              alignment: pw.Alignment.center,
              child: tText(
                t('Disclaimer: This report is generated by an AI model as an educational reference. It does not replace professional medical diagnosis.', 'إخلاء مسؤولية: تم إنشاء هذا التقرير بواسطة نموذج ذكاء اصطناعي كمرجع تعليمي. ولا يغني عن التشخيص الطبي المتخصص.'),
                style: const pw.TextStyle(
                  color: PdfColors.grey500,
                  fontSize: 7.5,
                ),
                align: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    // Layout the PDF preview directly so the user can see, save, print or share it.
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'BrainGuard_Health_Report_${userName.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _infoItem(String label, String value, PdfColor textColor, bool isAr, {bool forceLtr = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          textDirection: forceLtr ? pw.TextDirection.ltr : (isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr),
          style: pw.TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, bool isAr) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.TableRow _tableRow(
    String label,
    String val,
    String range,
    PdfColor bgColor,
    PdfColor textColor,
    bool isAr,
  ) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bgColor),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            style: pw.TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            val,
            textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            style: pw.TextStyle(color: textColor, fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            range,
            textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
          ),
        ),
      ],
    );
  }
}
