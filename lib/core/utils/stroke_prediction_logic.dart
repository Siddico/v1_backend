class StrokePredictionLogic {
  StrokePredictionLogic._();

  /// Get the risk category label based on the calculated risk score
  static String getStrokeRiskLabel(double score) {
    if (score >= 0.50) return 'high';
    if (score >= 0.20) return 'medium';
    return 'low';
  }

  /// Generate explanations and advice dynamically based on risk factors
  static Map<String, dynamic> generateExplanationAndAdvice({
    required double age,
    required bool hypertension,
    required bool heartDisease,
    required double avgGlucoseLevel,
    required double bmi,
    required String smokingStatus,
    required bool chestPain,
    required bool irregularHeartbeat,
    required bool shortnessOfBreath,
    required bool fatigueWeakness,
    required bool dizziness,
    required bool swellingEdema,
    required bool neckJawPain,
    required bool excessiveSweating,
    required bool persistentCough,
    required bool nauseaVomiting,
    required bool chestDiscomfort,
    required bool coldHandsFeet,
    required bool snoringSleepApnea,
    required bool anxietyDoom,
    required String languageCode,
  }) {
    final List<String> riskFactors = [];
    final List<String> adviceList = [];

    final isArabic = languageCode == 'ar';

    // Build risk factors & advice lists based on new AI inputs
    if (age >= 60) {
      riskFactors.add(
        isArabic ? 'التقدم في السن (فوق 60 عاماً)' : 'Advanced Age (over 60)',
      );
    }

    if (hypertension) {
      riskFactors.add(
        isArabic ? 'ارتفاع ضغط الدم' : 'Hypertension (High Blood Pressure)',
      );
      adviceList.add(
        isArabic
            ? 'راقب ضغط دمك يومياً واحرص على الالتزام بالأدوية الموصوفة وتناول غذاء قليل الملح.'
            : 'Monitor your blood pressure daily, take prescribed medications, and reduce sodium intake.',
      );
    }

    if (heartDisease) {
      riskFactors.add(
        isArabic ? 'وجود مشاكل أو أمراض بالقلب' : 'Cardiovascular Disease',
      );
      adviceList.add(
        isArabic
            ? 'احرص على المتابعة الدورية والمستمرة مع طبيب قلب مختص.'
            : 'Schedule regular visits with your cardiologist.',
      );
    }

    if (chestPain || neckJawPain || chestDiscomfort) {
      riskFactors.add(
        isArabic ? 'آلام أو انزعاج في الصدر/الرقبة/الفك' : 'Chest, Neck, or Jaw Pain/Discomfort',
      );
      adviceList.add(
        isArabic
            ? 'آلام وانزعاج الصدر قد تكون مؤشراً خطيراً لمشاكل في القلب، يُنصح بإجراء رسم قلب (ECG) واستشارة الطبيب فوراً إذا كانت مستمرة أو مفاجئة.'
            : 'Chest discomfort and jaw pain can indicate heart issues. It is highly recommended to perform an ECG and consult a doctor immediately if sudden or persistent.',
      );
    }

    if (irregularHeartbeat || shortnessOfBreath) {
      riskFactors.add(
        isArabic ? 'عدم انتظام ضربات القلب أو ضيق التنفس' : 'Irregular Heartbeat or Shortness of Breath',
      );
      adviceList.add(
        isArabic
            ? 'عدم انتظام النبض وضيق التنفس يتطلب فحصاً طبياً للتأكد من سلامة صمامات وكهرباء القلب.'
            : 'Irregular pulse and shortness of breath require medical evaluation to ensure heart electrical and valve health.',
      );
    }

    if (fatigueWeakness || dizziness) {
      riskFactors.add(
        isArabic ? 'الإرهاق والضعف العام أو الدوخة' : 'Fatigue, Weakness, or Dizziness',
      );
      adviceList.add(
        isArabic
            ? 'الدوخة والإرهاق المستمر قد يعكس ضعفاً في الدورة الدموية، حافظ على رطوبة جسمك وتأكد من قياس ضغطك.'
            : 'Persistent dizziness and fatigue may reflect poor circulation. Stay hydrated and check your blood pressure.',
      );
    }

    if (swellingEdema) {
      riskFactors.add(
        isArabic ? 'تورم في الأطراف (وذمة)' : 'Swelling/Edema in extremities',
      );
      adviceList.add(
        isArabic
            ? 'التورم قد يدل على احتباس السوائل أو قصور في الدورة الدموية/القلب. يُرجى مراجعة الطبيب وتقليل الملح في الطعام.'
            : 'Swelling can indicate fluid retention or poor circulation/heart failure. Please consult a doctor and reduce salt intake.',
      );
    }

    if (snoringSleepApnea) {
      riskFactors.add(
        isArabic ? 'الشخير أو انقطاع التنفس أثناء النوم' : 'Snoring or Sleep Apnea',
      );
      adviceList.add(
        isArabic
            ? 'انقطاع التنفس أثناء النوم يزيد بشكل كبير من خطر السكتة الدماغية والضغط. يُنصح بإجراء دراسة للنوم (Sleep Study).'
            : 'Sleep apnea significantly increases the risk of stroke and hypertension. Consider consulting a doctor for a sleep study.',
      );
    }

    if (coldHandsFeet) {
      riskFactors.add(
        isArabic ? 'برودة الأطراف الدائمة' : 'Persistent Cold Hands/Feet',
      );
      adviceList.add(
        isArabic
            ? 'برودة الأطراف قد تشير إلى ضعف الدورة الدموية الطرفية. حافظ على نشاطك البدني واستشر طبيباً للتأكد.'
            : 'Cold extremities may indicate poor peripheral circulation. Stay physically active and consult a doctor.',
      );
    }

    if (excessiveSweating || nauseaVomiting || anxietyDoom) {
      riskFactors.add(
        isArabic ? 'تعرق مفرط، غثيان، أو شعور بالخوف' : 'Excessive Sweating, Nausea, or Feeling of Doom',
      );
      adviceList.add(
        isArabic
            ? 'التعرق المفاجئ والشعور بالدوار أو الغثيان قد تكون أعراضاً غير تقليدية لأزمات القلب، خاصة إذا ترافقت مع ألم. لا تتجاهلها.'
            : 'Sudden excessive sweating, nausea, or a feeling of impending doom can be atypical signs of cardiac distress. Do not ignore them.',
      );
    }

    if (persistentCough) {
      riskFactors.add(
        isArabic ? 'سعال مستمر' : 'Persistent Cough',
      );
      adviceList.add(
        isArabic
            ? 'السعال المستمر غير المبرر قد يرتبط أحياناً بتراكم السوائل في الرئتين بسبب مشاكل القلب. يُفضل فحصه طبياً.'
            : 'A persistent, unexplained cough can sometimes be related to fluid buildup in the lungs from heart issues. Have it evaluated.',
      );
    }

    // Retain major lifestyle indicators if they are critical
    if (avgGlucoseLevel > 140) {
      riskFactors.add(
        isArabic ? 'ارتفاع نسبة السكر في الدم' : 'Elevated Blood Glucose',
      );
      adviceList.add(
        isArabic
            ? 'استشر طبيباً لتنظيم مستويات السكر واتبع حمية منخفضة الكربوهيدرات لحماية الأوعية الدموية.'
            : 'Consult a doctor to regulate blood sugar and follow a low-carb diet to protect blood vessels.',
      );
    }

    if (bmi >= 30) {
      riskFactors.add(
        isArabic ? 'السمنة (مؤشر كتلة الجسم 30 أو أكثر)' : 'Obesity (BMI ≥ 30)',
      );
      adviceList.add(
        isArabic
            ? 'السمنة تزيد من إجهاد القلب وفرص الإصابة بالجلطات. حاول تقليل وزنك عبر التغذية السليمة والرياضة.'
            : 'Obesity increases heart strain and stroke risk. Manage weight through a balanced diet and regular physical activity.',
      );
    }

    if (smokingStatus == 'smokes') {
      riskFactors.add(isArabic ? 'التدخين النشط' : 'Active Smoking');
      adviceList.add(
        isArabic
            ? 'الإقلاع عن التدخين يقلل من خطر الإصابة بالسكتة بشكل كبير.'
            : 'Quitting smoking significantly reduces the risk of stroke.',
      );
    }

    // Default messages if no specific risk factors found
    if (riskFactors.isEmpty) {
      riskFactors.add(
        isArabic
            ? 'لا توجد عوامل خطورة رئيسية'
            : 'No major risk factors detected',
      );
    }
    if (adviceList.isEmpty) {
      adviceList.add(
        isArabic
            ? 'حافظ على أسلوب حياة نشط، وتناول غذاءً متوازناً، واحرص على إجراء الفحوصات الطبية السنوية.'
            : 'Maintain an active lifestyle, eat a balanced diet, and get routine annual medical checkups.',
      );
    }

    // Build explanation text
    final String explanation;
    if (isArabic) {
      explanation =
          // ignore: prefer_interpolation_to_compose_strings
          'معدل الخطر لديك يتأثر بالعوامل التالية: ' +
          riskFactors.join('، ') +
          '.';
    } else {
      explanation =
          // ignore: prefer_interpolation_to_compose_strings
          'Your risk rating is influenced by: ' + riskFactors.join(', ') + '.';
    }

    return {'explanation': explanation, 'advice': adviceList};
  }
}
