import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'bad_request_error': 'Bad request, try again later',
      'forbidden_error': 'Forbidden request, try again later',
      'unauthorized_error': 'User is unauthorized, try again later',
      'not_found_error': 'Not found, try again later',
      'internal_server_error': 'Server error, try again later',
      'timeout_error': 'Connection timeout, try again later',
      'default_error': 'Something went wrong, try again later',
      'cache_error': 'Cache error, try again later',
      'no_internet_error': 'Please check your internet connection',
      'Invalid email or password.': 'Invalid email or password.',
      'Forbidden request, try again later': 'Forbidden request, try again later',
      'User not found.': 'User not found.',
      'Validation Error': 'Validation Error',
      'Registration failed.': 'Registration failed.',
      'Login failed.': 'Login failed.',
      'Server error, try again later': 'Server error, try again later',
      'Connection timeout, try again later': 'Connection timeout, try again later',
      'Please check your internet connection': 'Please check your internet connection',
      'Network error. Please try again.': 'Network error. Please try again.',
      'An unexpected error occurred. Please try again.': 'An unexpected error occurred. Please try again.',
      'Failed to send OTP.': 'Failed to send OTP.',
      'Failed to verify OTP.': 'Failed to verify OTP.',
      'Invalid or expired OTP code.': 'Invalid or expired OTP code.',
      'Session expired. Please request a new OTP.': 'Session expired. Please request a new OTP.',
      'Failed to reset password.': 'Failed to reset password.',
      'The email has already been taken.': 'The email has already been taken.',
      'The phone has already been taken.': 'The phone has already been taken.',
    },
    'ar': {
      // General/Global
      'Coming soon!': 'قريباً!',
      'Language selector tapped': 'تم النقر على مغير اللغة',
      'Language switched successfully': 'تم تغيير لغة التطبيق بنجاح',
      'Log in': 'تسجيل الدخول',
      'Log-in': 'تسجيل الدخول',
      'Sign-Up': 'إنشاء حساب',
      'Sign up': 'إنشاء حساب',
      'Sign Up': 'إنشاء حساب',
      'Email': 'البريد الإلكتروني',
      'Password': 'كلمة المرور',
      'Confirm Password': 'تأكيد كلمة المرور',
      'Name': 'الاسم',
      'Phone': 'رقم الهاتف',
      'Save': 'حفظ',
      'Cancel': 'إلغاء',
      'Verify': 'تحقق',
      'Skip': 'تخطي',
      'Next': 'التالي',
      'Back': 'رجوع',
      'Logout': 'تسجيل الخروج',
      'Success': 'نجاح',
      'Error': 'خطأ',
      'Warning': 'تحذير',
      'Info': 'معلومات',
      'Are you sure you want to logout?': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',

      // Role Selection Page
      'you are': 'أنت',
      'identify your role to continue': 'حدد دورك للمتابعة',
      'Doctor': 'طبيب',
      'Access patient data and monitor health insights.':
          'الوصول إلى بيانات المرضى ومتابعة المؤشرات الصحية.',
      'Patient': 'مريض',
      'Track your health status and connect with your doctor.':
          'تتبع حالتك الصحية وتواصل مع طبيبك.',
      'Researcher': 'باحث',
      'Explore and analyze medical papers and data.':
          'استكشف وحلل الأوراق والبيانات الطبية.',

      // Onboarding Page
      'Get Started': 'ابدأ الآن',
      'Your health is your greatest investment take care of it today':
          'صحتك هي أعظم استثمار لك، اعتني بها اليوم',

      // Auth Page Headers & Forms
      'Welcome back!': 'مرحباً بعودتك!',
      'Join us and take the first step toward better health':
          'انضم إلينا واتخذ الخطوة الأولى نحو صحة أفضل',
      'Welcome back, Doctor! Access your patients\' health insights and provide better care.':
          'مرحباً بعودتك، يا دكتور! اطلع على المؤشرات الصحية لمرضاك وقدم رعاية أفضل.',
      'Welcome': 'مرحباً',
      'Are you ready to access your dashboard to manage patients and analyze results?':
          'هل أنت مستعد للوصول إلى لوحة التحكم الخاصة بك لإدارة المرضى وتحليل النتائج؟',
      'Welcome back, Researcher! Access your data and continue your important work.':
          'مرحباً بعودتك، يا باحث! تفقد بياناتك وتابع عملك الهام.',
      'Forgot Password?': 'هل نسيت كلمة المرور؟',
      'If you forget your password': 'إذا نسيت كلمة المرور',
      'Forget Password': 'نسيت كلمة المرور',
      'Don\'t worry! Enter your registered email, and we\'ll send you instructions to reset your password.':
          'لا تقلق! أدخل بريدك الإلكتروني المسجل، وسنرسل لك تعليمات لإعادة تعيين كلمة المرور.',
      'Don\'t worry, Doctor! Enter your registered email, and we\'ll help you reset your password quickly.':
          'لا تقلق، يا دكتور! أدخل بريدك الإلكتروني المسجل، وسنساعدك في إعادة تعيين كلمة المرور سريعاً.',
      'Remember me': 'تذكرني',
      'agree to privacy policy': 'أوافق على سياسة الخصوصية',
      'Privacy Policy': 'سياسة الخصوصية',
      'Enter dynamic OTP sent to your email.':
          'أدخل رمز التحقق (OTP) المرسل إلى بريدك الإلكتروني.',
      'Didn\'t receive code?': 'لم تستلم الرمز؟',
      'Resend code': 'إعادة إرسال الرمز',
      'Choose New Password': 'اختر كلمة مرور جديدة',
      'Set your new password to regain access':
          'اضبط كلمة مرور جديدة لاستعادة الوصول',
      'Confirm New Password': 'تأكيد كلمة المرور الجديدة',
      'Save & Log In': 'حفظ وتسجيل الدخول',
      'Please fill in all fields': 'برجاء ملء جميع الحقول',
      'Passwords do not match': 'كلمات المرور غير متطابقة',
      'Please enter your name': 'برجاء إدخال اسمك',
      'Please enter a valid phone number': 'برجاء إدخال رقم هاتف صحيح',
      'Please enter a valid email address': 'برجاء إدخال بريد إلكتروني صحيح',
      'Password must be at least 6 characters':
          'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'Enter your email address and we will send you an OTP to reset your password.':
          'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق (OTP) لإعادة تعيين كلمة المرور.',
      'Email Address': 'البريد الإلكتروني',
      'e.g. user@example.com': 'مثال: user@example.com',
      'Send OTP': 'إرسال رمز التحقق',
      'OTP has been sent to your email!':
          'تم إرسال رمز التحقق إلى بريدك الإلكتروني!',
      'Please enter the 4-digit code sent to your email to verify your identity.':
          'يرجى إدخال الرمز المكون من 4 أرقام المرسل إلى بريدك الإلكتروني للتحقق من هويتك.',
      'If you want to change your email': 'إذا كنت تريد تغيير بريدك الإلكتروني',
      'Missing verification session.': 'جلسة التحقق مفقودة.',
      'Enter the full 4-digit OTP code.':
          'أدخل رمز التحقق المكون من 4 أرقام كاملاً.',
      'OTP verified successfully.': 'تم التحقق من الرمز بنجاح.',
      'Invalid OTP code': 'رمز تحقق غير صالح',
      'Create a new password for': 'أنشئ كلمة مرور جديدة لـ',
      'Re-enter your new password': 'أعد إدخال كلمة المرور الجديدة',
      'Password reset successfully. Please log in again.':
          'تم إعادة تعيين كلمة المرور بنجاح. يرجى تسجيل الدخول مرة أخرى.',
      'This phone number is already registered.': 'رقم الهاتف هذا مسجل بالفعل.',
      'Re-enter your password to confirm': 'أعد إدخال كلمة المرور للتأكيد',
      'If you forget your password ': 'إذا نسيت كلمة المرور ',
      'Join our research community and contribute to advancing healthcare':
          'انضم إلى مجتمعنا البحثي وساهم في تطوير الرعاية الصحية',
      'Welcome back! Track your health and stay connected with your care team.':
          'مرحباً بعودتك! تتبع صحتك وابق على اتصال مع فريق الرعاية الخاص بك.',
      'Name is required': 'الاسم مطلوب',
      'Phone number is required': 'رقم الهاتف مطلوب',
      'Email is required': 'البريد الإلكتروني مطلوب',
      'Please enter a valid email': 'برجاء إدخال بريد إلكتروني صحيح',
      'Password is required': 'كلمة المرور مطلوبة',
      'Password must be at least 8 characters':
          'يجب أن تكون كلمة المرور 8 رموز على الأقل',
      'Please select a role first': 'برجاء اختيار دورك أولاً',
      'Please select your gender': 'برجاء اختيار جنسك',
      'Please agree to the data agreement':
          'برجاء الموافقة على اتفاقية البيانات',
      'Please enter your full name that in your national ID':
          'يرجى إدخال اسمك الكامل الموجود في الهوية الوطنية',
      'Please enter your phone number': 'يرجى إدخال رقم هاتفك',
      'Please enter your Email': 'يرجى إدخال بريدك الإلكتروني',
      'Please Select a safe password and keep to safe it':
          'يرجى اختيار كلمة مرور آمنة والاحتفاظ بها بأمان',
      'Identify your role to continue': 'حدد دورك للمتابعة',
      'Health Records': 'السجلات الصحية',
      'Appointments': 'المواعيد',
      'Schedule': 'الجدول',
      'Analysis': 'التحليلات',
      'Reports': 'التقارير',
      'I confirm that I agree to the app\'s':
          'أؤكد موافقتي على سياسة التطبيق لـ',
      'Privacy & policy': 'الخصوصية والسياسة',
      'Privacy Policy Agreement': 'اتفاقية سياسة الخصوصية',
      'Please read our Privacy Policy carefully:':
          'يرجى قراءة سياسة الخصوصية الخاصة بنا بعناية:',
      '1. Data Collection': '١. جمع البيانات',
      'We collect health parameters (like heart rate and oxygen levels) from connected smartwatch devices to predict and prevent stroke risks.':
          'نقوم بجمع المؤشرات الحيوية (مثل ضربات القلب ونسبة الأكسجين) من الساعات الذكية المتصلة للتنبؤ بمخاطر السكتة الدماغية والوقاية منها.',
      '2. Data Security': '٢. أمن البيانات',
      'Your medical data is encrypted and securely stored on Firebase, accessible only to you and your authorized healthcare providers.':
          'يتم تشفير بياناتك الطبية وتخزينها بشكل آمن على Firebase، ولا يمكن الوصول إليها إلا من قبلك ومن قبل طبيبك المعتمد.',
      '3. Sharing & Privacy': '٣. المشاركة والخصوصية',
      'We never sell or share your personal data with third parties for commercial purposes.':
          'نحن لا نبيع أو نشارك بياناتك الشخصية مع أي أطراف ثالثة لأغراض تجارية.',
      'Close': 'إغلاق',
      'Full name': 'الاسم بالكامل',
      'Phone number': 'رقم الهاتف',
      'Create account': 'إنشاء حساب',
      'Already have an account?': 'لديك حساب بالفعل؟',
      'Data Agreement': 'اتفاقية البيانات',
      'Notification': 'الإشعارات',
      'Latest notification': 'آخر الإشعارات',
      'Sort By': 'ترتيب حسب',
      'Today': 'اليوم',
      'Yesterday': 'أمس',
      'No notifications yet': 'لا توجد إشعارات بعد',
      'Patient updates and reminders will appear here once they arrive.':
          'ستظهر تحديثات وتنبيهات المرضى هنا بمجرد وصولها.',
      'No doctor notifications yet': 'لا توجد تنبيهات طبيب بعد',
      'You will see patient alerts and updates here once they arrive.':
          'ستظهر تنبيهات المرضى وتحديثاتهم هنا بمجرد وصولها.',
      'Unable to load notifications': 'تعذر تحميل الإشعارات',
      'Retry': 'إعادة المحاولة',
      'Oops! No notifications yet': 'عذراً! لا توجد إشعارات بعد',
      'It seems that you\'re you got a blank state. We\'ll let you know when updates arrive!':
          'يبدو أنه لا توجد أي إشعارات حالياً. سنعلمك عندما تصل تحديثات جديدة!',
      'Something went wrong': 'حدث خطأ ما',
      'Try Again': 'حاول مجدداً',
      'No Internet Connection': 'لا يوجد اتصال بالإنترنت',
      'Please check your internet connection\nor try again later.':
          'يرجى التحقق من اتصالك بالإنترنت\nأو المحاولة مرة أخرى لاحقاً.',
      'Refresh': 'تحديث',

      // Patient Dashboard / Wellness Page
      'Wellness': 'الصحة والرفاهية',
      'Heart Rate': 'ضربات القلب',
      'Oxygen': 'نسبة الأكسجين',
      'Sleep': 'النوم',
      'Activity': 'النشاط اليومي',
      'Normal': 'طبيعي',
      'Unnormal': 'غير طبيعي',
      'Risk of Stroke': 'خطر الإصابة بالسكتة',
      'Connected': 'متصل',
      'connected': 'متصل',
      'Device Disconnected': 'الجهاز غير متصل',
      'Please connect your smartwatch to start tracking.':
          'يرجى توصيل ساعتك الذكية لبدء التتبع الطبي.',
      'Stability Index': 'مؤشر الاستقرار',
      'Health Overview': 'نظرة عامة على الصحة',
      'Your heart rate and oxygen levels are stable.':
          'مستويات ضربات القلب والأكسجين لديك مستقرة.',
      'Low Risk': 'خطر منخفض',
      'High Risk': 'خطر مرتفع',
      'Moderate Risk': 'خطر متوسط',
      'Upload Data Now': 'رفع البيانات الآن',
      'Sync your medical files with your doctor easily.':
          'قم بمزامنة ملفاتك الطبية مع طبيبك بسهولة.',
      'Risk stroke rate ': 'معدل خطر الإصابة بالسكتة ',
      'Risk stroke rate': 'معدل خطر الإصابة بالسكتة',

      // About Us
      'About Us': 'من نحن',
      'About BrainGuard': 'عن BrainGuard',
      'Our Team': 'فريقنا',
      'Mohammed Ahmed Mohammed Siddiq': 'محمد أحمد محمد صديق',
      'Ahmed Bahaa El-dien Mohammed': 'أحمد بهاء الدين محمد',
      'Ahmed Mohammed Mahmoud': 'أحمد محمد محمود',
      'Belal Rabea Khalifa': 'بلال ربيع خليفة',
      'Kareem Ashraf Hosny': 'كريم أشرف حسني',
      'We are a passionate team dedicated to leveraging technology for early stroke prediction and continuous patient monitoring. Our goal is to bridge the gap between patients and doctors by providing a seamless, intelligent, and life-saving healthcare platform.':
          'نحن فريق شغوف مكرس لتسخير التكنولوجيا للتنبؤ المبكر بالسكتة الدماغية والمراقبة المستمرة للمرضى. هدفنا هو سد الفجوة بين المرضى والأطباء من خلال توفير منصة رعاية صحية سلسة وذكية ومنقذة للحياة.',

      // Patient Search & Details
      'Search': 'بحث',
      'Search for doctors...': 'ابحث عن أطباء...',
      'No doctors found': 'لم يتم العثور على أطباء',
      'Try checking your spelling': 'حاول التحقق من الإملاء',
      'Doctor Details': 'تفاصيل الطبيب',
      'About': 'حول',
      'Specialty': 'التخصص',
      'Speciality': 'التخصص',
      'Reviews': 'التقييمات',
      'Experience': 'الخبرة',
      'Years': 'سنوات',
      'Request Doctor': 'طلب متابعة مع الطبيب',
      'Request Sent': 'تم إرسال الطلب',
      'Send Request': 'إرسال الطلب',
      'Pending': 'قيد الانتظار',
      'Accepted': 'مقبول',
      'Rejected': 'مرفوض',

      // Patient Profile & Settings
      'Profile': 'الملف الشخصي',
      'Edit Profile': 'تعديل الملف الشخصي',
      'Notification Settings': 'إعدادات الإشعارات',
      'Health Alerts': 'تنبيهات الصحة',
      'Critical Stroke Alerts': 'تنبيهات السكتة الدماغية الحرجة',
      'Notify when AI detects high-risk prediction':
          'تنبيه عند اكتشاف الذكاء الاصطناعي لمستوى خطورة مرتفع',
      'Stroke Risk Updates': 'تحديثات مخاطر السكتة الدماغية',
      'Receive updates on your stroke risk level':
          'تلقي تحديثات حول مستوى خطر السكتة الدماغية لديك',
      'Report Ready': 'التقرير جاهز',
      'When a new analysis report is available':
          'عندما يكون تقرير التحليل الجديد متاحاً',
      'General': 'عام',
      'Appointment Reminders': 'تذكيرات المواعيد',
      'Reminders for upcoming appointments': 'تذكير بالمواعيد القادمة',
      'New messages from your doctor': 'رسائل جديدة من طبيبك',
      'Sound & Vibration': 'الصوت والاهتزاز',
      'Sound': 'الصوت',
      'Play sound for notifications': 'تشغيل صوت للإشعارات',
      'Vibration': 'الاهتزاز',
      'Vibrate for notifications': 'الاهتزاز مع الإشعارات',
      'Do Not Disturb': 'وضع عدم الإزعاج',
      'Silence all notifications (except critical alerts)':
          'كتم جميع الإشعارات (باستثناء التنبيهات الحرجة)',
      'Critical stroke alerts will always be delivered even in Do Not Disturb mode.':
          'سيتم دائماً تسليم تنبيهات السكتة الدماغية الحرجة حتى في وضع عدم الإزعاج.',
      'PRIORITY': 'أولوية',
      'Security Settings': 'الإعدادات الأمنية',
      'Emergency Contact': 'جهات اتصال الطوارئ',
      'Medical History': 'التاريخ الطبي',
      'Radiology & Imaging': 'الأشعة والتحاليل الطبية',
      'Save Changes': 'حفظ التغييرات',
      'Male': 'ذكر',
      'Female': 'أنثى',
      'Home': 'الرئيسية',
      'Download report': 'تحميل التقرير',
      'Age': 'السن',
      'Gender': 'النوع',
      'Change Password': 'تغيير كلمة المرور',
      'Current Password': 'كلمة المرور الحالية',
      'New Password': 'كلمة المرور الجديدة',
      'Add Contact': 'إضافة جهة اتصال',
      'Relationship': 'صلة القرابة',
      'Emergency Phone': 'هاتف الطوارئ',

      // Upload Files
      'Upload Files': 'رفع الملفات',
      'Select files to upload': 'اختر الملفات لرفعها',
      'Drag and drop your files here': 'اسحب وأسقط ملفاتك هنا',
      'Uploaded Files': 'الملفات المرفوعة',
      'Upload Now': 'رفع الآن',
      'Upload ECG Signals': 'رفع إشارات رسم القلب (ECG)',
      'Upload PPG Signals': 'رفع إشارات النبض (PPG)',
      'Upload Prescription': 'رفع الوصفة الطبية',
      'Upload AI PPG (.mat)': 'رفع ملف AI PPG (.mat)',
      'Choose files from ': 'اختر الملفات من ',
      // 'Phone': 'الهاتف',
      'Supported formats: JPG, JPEG, PNG, PDF, CSV, TXT, MAT':
          'الصيغ المدعومة: JPG, JPEG, PNG, PDF, CSV, TXT, MAT',
      'You can upload one or more medical reports here. Make sure your files are in one of the supported formats.':
          'يمكنك رفع تقرير طبي واحد أو أكثر هنا. تأكد من أن ملفاتك بأحد الصيغ المدعومة.',
      'Uploading...': 'جاري الرفع...',
      'accepted': 'مقبول',
      'rejected': 'مرفوض',
      'Selected files: ': 'الملفات المحددة: ',

      // Patient Detail Page
      'Information': 'المعلومات',
      'Medical Dashboard': 'اللوحة الطبية',
      'Error loading patient: ': 'حدث خطأ في تحميل بيانات المريض: ',
      'No files uploaded yet': 'لم يتم رفع أي ملفات بعد',
      'When the patient uploads diagnostic files or prescriptions, they will appear here.':
          'عندما يقوم المريض برفع ملفات تشخيصية أو وصفات طبية، ستظهر هنا.',
      'Images': 'الصور',
      'PDF Documents': 'مستندات PDF',
      'MAT Files': 'ملفات MAT',
      'ECG Signals': 'إشارات رسم القلب (ECG)',
      'PPG Signals': 'إشارات النبض (PPG)',
      'Stroke risk': 'خطر السكتة الدماغية',
      'Uploaded Documents & Reports': 'المستندات والتقارير المرفوعة',
      'Prescriptions & Lab': 'روشتات وتحاليل',

      // Information Section
      'Diagnosis': 'التشخيص',
      'Heart Rate (HR)': 'معدل ضربات القلب',
      'HR': 'معدل ضربات القلب',
      'HRV': 'تقلب معدل ضربات القلب',
      'Blood Pressure (BP)': 'ضغط الدم',
      'Blood Glucose': 'مستوى السكر في الدم',
      'Cholesterol': 'الكوليسترول',
      'Last ECG / PPG Upload': 'آخر رفع لبيانات ECG/PPG',
      'Doctor notes': 'ملاحظات الطبيب',
      'Download': 'تحميل',
      'Update': 'تحديث',
      'Personal data': 'البيانات الشخصية',
      'ID': 'رقم التعريف',
      'Phone Emergency': 'هاتف الطوارئ',

      // Doctor Dashboard
      // 'Home': 'الرئيسية',
      'Charts': 'الرسومات',

      // Doctor Profile & Edit Profile
      'Years Experience': 'سنوات الخبرة',
      'Experience Years': 'سنوات الخبرة',
      'Patients': 'المرضى',
      'License Number': 'رقم الترخيص',
      'License number': 'رقم الترخيص',
      'Years of experience': 'سنوات الخبرة',
      'Patients served': 'عدد المرضى',
      'Bio': 'النبذة الشخصية',
      'Log-out': 'تسجيل الخروج',
      'My QR Code': 'رمز QR الخاص بي',
      'Tap to view and share QR code': 'اضغط لعرض ومشاركة رمز QR',
      'Scan this QR code to connect with me.': 'امسح رمز QR هذا للتواصل معي.',
      'Preparing Image...': 'جاري تجهيز الصورة...',
      'Share QR Code': 'مشاركة رمز QR',
      'Doctor ID copied to clipboard!': 'تم نسخ معرف الطبيب إلى الحافظة!',
      'User ID copied to clipboard!': 'تم نسخ معرف المستخدم إلى الحافظة!',
      'Copy ID': 'نسخ المعرف',
      'Tapping share will send a high-quality scan-ready image.':
          'سيؤدي الضغط على مشاركة إلى إرسال صورة عالية الجودة جاهزة للمسح الضوئي.',
      'Logged out successfully.': 'تم تسجيل الخروج بنجاح.',
      'No bio description provided yet.': 'لم يتم كتابة نبذة شخصية بعد.',
      'Saving your profile…': 'جاري حفظ ملفك الشخصي…',

      // QR Scan pages
      'No valid QR code found in the selected image.':
          'لم يتم العثور على رمز QR صالح في الصورة المحددة.',
      'Invalid Patient QR Code': 'رمز QR الخاص بالمريض غير صالح',
      'Patient Detected': 'تم اكتشاف مريض',
      'Patient ID:': 'رقم المريض:',
      'Connection established successfully!': 'تم الاتصال بنجاح!',
      'Failed to connect:': 'فشل الاتصال:',
      'Already Connected': 'متصل بالفعل',
      'Connect Patient': 'اتصال بالمريض',
      'Scan Again': 'مسح مرة أخرى',
      'Please place the patient\'s QR code directly under the camera lens so that it appears clearly within the scanning frame':
          'يرجى وضع رمز QR الخاص بالمريض أسفل عدسة الكاميرا مباشرة حتى يظهر بوضوح داخل إطار المسح',
      'Make sure the lighting is sufficient': 'تأكد من وجود إضاءة كافية',
      'The camera lens is clean.': 'عدسة الكاميرا نظيفة.',
      'Tap the Scan button to begin reading the QR code.':
          'اضغط على زر المسح لبدء القراءة.',
      'Error checking QR:': 'حدث خطأ أثناء فحص رمز QR:',
      'Error checking QR: ': 'حدث خطأ أثناء فحص رمز QR: ',
      'Invalid Doctor QR Code': 'رمز QR الخاص بالطبيب غير صالح',
      'Doctor Detected': 'تم اكتشاف طبيب',
      'Message Doctor': 'مراسلة الطبيب',
      'Request Connection': 'طلب اتصال',
      'Please place the doctor\'s QR code directly under the camera lens so that it appears clearly within the scanning frame':
          'يرجى وضع رمز QR الخاص بالطبيب أسفل عدسة الكاميرا مباشرة حتى يظهر بوضوح داخل إطار المسح',
      'Scan Image': 'مسح من صورة',
      'Scan': 'مسح',
      'Failed to open conversation: ': 'فشل في فتح المحادثة: ',

      // Upload & Exceptions
      'Please add at least one file before submitting.':
          'يرجى إضافة ملف واحد على الأقل قبل الإرسال.',
      'Files uploaded successfully.': 'تم رفع الملفات بنجاح.',
      'Upload failed: ': 'فشل الرفع: ',
      'Failed to upload image': 'فشل رفع الصورة',
      'Failed to upload file': 'فشل رفع الملف',
      'Camera access denied or unavailable':
          'الوصول للكاميرا مرفوض أو غير متاح',
      'Gallery access denied or unavailable': 'الوصول للصور مرفوض أو غير متاح',
      'Files access denied or unavailable': 'الوصول للملفات مرفوض أو غير متاح',
      'Emojis coming soon!': 'الوجوه التعبيرية قريباً!',

      // Messages Layout
      'Messenger': 'المراسلة',
      'Coming soon!! Future Work': 'قريباً!! سيتم توفيرها قريباً',
      'No messages yet. Send a message to start!':
          'لا توجد رسائل بعد. أرسل رسالة للبدء!',
      'Error: ': 'خطأ: ',
      'Audio': 'صوت',
      'New': 'جديد',
      'Are you sure that you want to log out':
          'هل أنت متأكد أنك تريد تسجيل الخروج',
      'Yes': 'نعم',
      'No': 'لا',
      'years': 'سنة',
      'yrs': 'سنة',
      'mg/dL': 'ملجم/ديسيلتر',
      'kg/m²': 'كجم/م²',
      'Account created successfully.': 'تم إنشاء الحساب بنجاح.',
      'Logged in successfully.': 'تم تسجيل الدخول بنجاح.',
      'Invalid email or password.':
          'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'No user is currently signed in via Phone Auth.':
          'لا يوجد مستخدم مسجل الدخول حالياً عبر الهاتف.',
      'No authenticated user found.': 'لم يتم العثور على مستخدم مسجل.',

      'Message': 'الرسائل',
      'Overview': 'نظرة عامة',
      // 'Patients': 'المرضى',
      'Patients list': 'قائمة المرضى',
      'Filter': 'تصفية',
      'No patients linked yet.\nUse the QR scanner to connect patients.':
          'لا يوجد مرضى مرتبطين بعد.\nاستخدم ماسح رمز QR لربط المرضى.',
      'Diagnoses': 'التشخيصات',
      'Last review': 'آخر مراجعة',
      'Requests': 'الطلبات',
      'Messages': 'الرسائل',
      'Chat': 'المحادثة',
      'Chat History': 'سجل المحادثة',
      'New Chat': 'محادثة جديدة',
      'No recent chats': 'لا توجد محادثات سابقة',
      'Chat deleted successfully': 'تم حذف المحادثة بنجاح',
      'Type a message...': 'اكتب رسالة...',
      'Scan QR': 'مسح رمز QR',
      'Active Patients': 'المرضى النشطون',
      'New Requests': 'طلبات جديدة',
      'Recent Patients': 'المرضى الأخيرون',
      'Age:': 'العمر:',
      'Gender:': 'النوع:',
      'Status': 'الحالة',
      'Accept': 'قبول',
      'Reject': 'رفض',
      'Write a message...': 'اكتب رسالة...',
      'Doctor Profile': 'ملف الطبيب',
      'QR Code': 'رمز QR الخاص بك',
      'Scan to add me': 'امسح الرمز لإضافتي كطبيب متابع',
      'Scan Patient QR': 'مسح رمز المريض QR',
      'Search Patients...': 'البحث عن المرضى...',
      'Patient Alert': 'تنبيه مريض',
      'Connection Request': 'طلب اتصال',
      'System': 'النظام',
      'You can search with patient name, ID or diagnosis':
          'يمكنك البحث باسم المريض أو رقمه أو تشخيصه',
      'Error loading patients:': 'خطأ في تحميل المرضى:',
      'Error:': 'خطأ:',
      'Error loading dashboard:': 'خطأ في تحميل لوحة التحكم:',
      'Error updating profile:': 'خطأ في تحديث الملف الشخصي:',
      'Specialization': 'التخصص',
      'Uploading photo…': 'جاري رفع الصورة…',
      'Profile photo updated': 'تم تحديث صورة الملف الشخصي',
      'Upload failed:': 'فشل الرفع:',
      'Specialist': 'أخصائي',
      'Check patient': 'فحص المريض',
      'Review patients\' recent reports and monitor their health updates':
          'مراجعة التقارير الأخيرة للمرضى ومراقبة تحديثات صحتهم',
      'Video Calls': 'مكالمات فيديو',
      'Schedule or join online consultations with your patients.':
          'جدولة أو الانضمام إلى استشارات عبر الإنترنت مع مرضاك.',
      'New\nPatient': 'مريض\nجديد',
      'Scan Doctor QR': 'مسح رمز QR للطبيب',
      'Emergency contact': 'جهة اتصال الطوارئ',
      'Scan QR Code': 'مسح رمز QR',
      'Security settings': 'إعدادات الأمان',
      'Mode theme': 'وضع المظهر',
      'Notification settings': 'إعدادات الإشعارات',
      'is coming soon.': 'قادم قريباً.',
      'Oops! No this data is founded': 'عفواً! لم يتم العثور على بيانات',
      'Medical data': 'البيانات الطبية',
      'Coming soon': 'قريباً',
      'Try typing the doctor\'s exact name, their specialty, or pick from the available suggestions below.':
          'حاول كتابة اسم الطبيب بالضبط، تخصصه، أو اختر من الاقتراحات المتاحة أدناه.',
      'Lab name': 'اسم التحليل',
      'Category': 'الفئة',
      'Save Password': 'حفظ كلمة المرور',
      'Successfully logged out': 'تم تسجيل الخروج بنجاح',
      'Password changed successfully': 'تم تغيير كلمة المرور بنجاح',
      'Failed to change password: ': 'فشل في تغيير كلمة المرور: ',
      'No doctor ID found in QR code.':
          'لم يتم العثور على معرف الطبيب في رمز QR.',
      'Doctor linked successfully!': 'تم ربط الطبيب بنجاح!',
      'Doctor info sent successfully': 'تم إرسال معلومات الطبيب بنجاح',
      'Failed to send doctor info': 'فشل إرسال معلومات الطبيب',
      'Emergency call initiated!': 'تم بدء مكالمة الطوارئ!',
      'Failed to initiate emergency call': 'فشل بدء مكالمة الطوارئ',
      'Review submitted successfully!': 'تم إرسال التقييم بنجاح!',
      'No linked patients yet.\nUse the QR scanner to add patients.':
          'لا يوجد مرضى مرتبطين بعد.\nاستخدم ماسح رمز QR لإضافة مرضى.',
      'No requests found': 'لا توجد طلبات',
      'No messages yet': 'لا توجد رسائل بعد',
      'Submit': 'إرسال',
      'You are at high risk for stroke. Please consult a doctor immediately.':
          'أنت في خطر شديد للإصابة بالسكتة الدماغية. يرجى استشارة الطبيب فوراً.',
      'You are in the safe zone for stroke risk.':
          'أنت في المنطقة الآمنة من خطر الإصابة بالسكتة الدماغية.',
      'Your stroke risk is elevated. Please monitor your health.':
          'خطر الإصابة بالسكتة الدماغية لديك مرتفع. يرجى مراقبة صحتك.',
      'More': 'المزيد',
      'Stable': 'مستقر',
      'Critical': 'حرج',
      'Risk': 'خطر',
      // 'Risk stroke rate': 'معدل خطر الإصابة بالسكتة',
      'High Risk Alert': 'تنبيه بخطر مرتفع',
      'Critical Risk Alert': 'تنبيه بخطر حرج',
      'Urgent Alert': 'تنبيه عاجل',
      'AI Prediction Update': 'تحديث لتنبؤ الذكاء الاصطناعي',
      'Stroke Risk Update': 'تحديث لخطر السكتة الدماغية',
      'Critical Stroke Risk Predicted': 'تم التنبؤ بخطر سكتة حرج',
      'Patient is at high risk of stroke':
          'المريض معرض لخطر كبير للإصابة بالسكتة',
      'Patient is at moderate risk of stroke':
          'المريض معرض لخطر متوسط للإصابة بالسكتة',
      'Patient is at low risk of stroke':
          'المريض معرض لخطر منخفض للإصابة بالسكتة',
      'Stroke risk assessment complete': 'اكتمل تقييم خطر السكتة الدماغية',
      'Danger': 'خطر',
      'Heart Rate Trend': 'مخطط نبضات القلب',
      'Oxygen Saturation (SpO₂)': 'نسبة تشبع الأكسجين (SpO₂)',
      'SpO₂ Level': 'نسبة الأكسجين SpO₂',
      'Current Score:': 'النتيجة الحالية:',
      'Current Status': 'الحالة الحالية',
      'Print PDF': 'طباعة التقرير PDF',
      'More than ': 'أكثر من ',
      'is the normal zone for stability.': 'هي المنطقة الطبيعية للاستقرار.',
      'of your Oxygen level is normal.': 'من مستوى الأكسجين لديك طبيعي.',
      'Now ': 'الآن ',
      'you can upload medical data manually to predict your case':
          'يمكنك الآن رفع البيانات الطبية يدويًا للتنبؤ بحالتك',
      'Upload data': 'رفع البيانات',
      'Failed to load doctors. Please try again.':
          'فشل تحميل الأطباء. يرجى المحاولة مرة أخرى.',
      'Neurologist': 'طبيب أعصاب',
      'Cardiologist': 'طبيب قلب',
      'General Neurology': 'طب الأعصاب العام',
      'About Doctor': 'عن الطبيب',
      'Contacts': 'جهات الاتصال',
      'Read more ..': 'قراءة المزيد ..',
      'With a caring and patient-centered approach, this doctor is committed to supporting the growth and health of every child. ':
          'من خلال نهج رعاية يركز على المريض، يلتزم هذا الطبيب بدعم صحة وعافية كل فرد.',
      'Error starting conversation: ': 'خطأ في بدء المحادثة: ',
      'Failed to load profile data.': 'فشل في تحميل بيانات الملف الشخصي.',
      'Profile saved successfully! 🎉': 'تم حفظ الملف الشخصي بنجاح! 🎉',
      'Error saving profile: ': 'خطأ أثناء حفظ الملف الشخصي: ',
      'Personal Information': 'المعلومات الشخصية',
      'Full Name': 'الاسم بالكامل',
      'Full name is required': 'الاسم بالكامل مطلوب',
      'Phone Number': 'رقم الهاتف',
      'Date of Birth': 'تاريخ الميلاد',
      'Emergency number': 'رقم الطوارئ',
      'this number will appear in your profile with your closed doctor':
          'سيظهر هذا الرقم في ملفك الشخصي للطبيب المتابع لك',
      'Please enter emergency number': 'برجاء إدخال رقم الطوارئ',
      'Change': 'تغيير',
      'Emergency contact saved successfully.':
          'تم حفظ جهة اتصال الطوارئ بنجاح.',
      'Error saving emergency contact: ': 'خطأ أثناء حفظ جهة اتصال الطوارئ: ',

      // Doctor Home & General
      'Your daily overview': 'نظرتك اليومية',
      'Loading your dashboard…': 'جارٍ تحميل لوحة التحكم...',
      'No conversations yet.\nStart chatting with your patients!':
          'لا توجد محادثات بعد.\nابدأ الدردشة مع مرضاك!',

      // Security Settings
      'Authentication': 'المصادقة',
      'Biometric Login': 'تسجيل الدخول البيومتري',
      'Use fingerprint or face ID to sign in':
          'استخدم بصمة الإصبع أو معرف الوجه لتسجيل الدخول',
      'Two-Factor Authentication': 'التحقق بخطوتين',
      'Extra layer of security for your account': 'طبقة أمان إضافية لحسابك',
      'Privacy': 'الخصوصية',
      'Data Privacy': 'خصوصية البيانات',
      'Manage how your data is used': 'تحكم في كيفية استخدام بياناتك',
      'Delete Account': 'حذف الحساب',
      'Permanently remove your account and data':
          'إزالة حسابك وبياناتك بشكل نهائي',
      'Update your account password': 'تحديث كلمة مرور حسابك',
      // Doctor Profile
      'Doctor profile updated successfully.':
          'تم تحديث الملف الشخصي للطبيب بنجاح.',

      // Stroke Onboarding Assessment
      'Stroke Risk Assessment': 'تقييم خطر الإصابة بالسكتة',
      'Welcome!': 'مرحباً بك!',
      'Personal & Demographic Info': 'المعلومات الشخصية والديموغرافية',
      'Medical Vitals': 'المؤشرات الطبية والحيوية',
      'Other': 'أخرى',
      'Stroke Risk': 'خطر الإصابة بالسكتة',
      'Enter your medical details to get started':
          'أدخل بياناتك الطبية للبدء ومتابعة صحتك',
      'Hypertension (High BP)': 'ارتفاع ضغط الدم',
      'Heart Disease': 'أمراض القلب',
      'Ever Married': 'سبق له الزواج',
      'Work Type': 'نوع العمل',
      'Residence Type': 'نوع السكن',
      'Average Glucose Level (mg/dL)': 'معدل السكر في الدم (ملجم/ديسيلتر)',
      'Average Glucose Level': 'معدل السكر في الدم',
      'BMI (Body Mass Index)': 'مؤشر كتلة الجسم (BMI)',
      'Don\'t know your BMI? Enter height and weight to calculate:':
          'لا تعرف مؤشر كتلة الجسم؟ أدخل الطول والوزن لحسابه:',
      'Height (cm)': 'الطول (سم)',
      'Weight (kg)': 'الوزن (كجم)',
      'Smoking Status': 'حالة التدخين',
      'Calculate Risk': 'احسب معدل الخطر',
      'children': 'أطفال / قاصر',
      'Govt_job': 'وظيفة حكومية',
      'Never_worked': 'لم يعمل مسبقاً',
      'Private': 'قطاع خاص',
      'Self-employed': 'عمل حر',
      'Rural': 'ريفي',
      'Urban': 'حضري',
      'formerly smoked': 'مدخن سابق',
      'never smoked': 'غير مدخن',
      'smokes': 'مدخن حالي',
      'Year': 'سنة',
      'Unknown': 'غير معروف',
      'Assessment Result': 'نتيجة التقييم الطبي',
      'Stroke Risk percentage': 'نسبة خطر السكتة الدماغية',
      'Explanation': 'التفسير الطبي للنتيجة',
      'Doctor\'s Advice': 'نصائح وإرشادات الطبيب',
      'Save & Continue': 'حفظ ومتابعة للرئيسية',
      'Please enter a valid age': 'برجاء إدخال عمر صحيح',
      'Please enter average glucose level': 'برجاء إدخال معدل السكر في الدم',
      'Please enter BMI': 'برجاء إدخال مؤشر كتلة الجسم',
      'Please enter height': 'برجاء إدخال الطول',
      'Please enter a valid height': 'برجاء إدخال طول صحيح',
      'Please enter weight': 'برجاء إدخال الوزن',
      'Please enter a valid weight': 'برجاء إدخال وزن صحيح',
      'How can I help you today?': 'كيف يمكنني مساعدتك اليوم؟',
      'Ask anything, I am here to assist.': 'اسأل عن أي شيء، أنا هنا للمساعدة.',

      // Medical History Page
      // 'Medical History': 'السجل الطبي',
      'Your medical profile used for stroke risk assessment':
          'ملفك الطبي المستخدم لتقييم مخاطر السكتة الدماغية',
      'Conditions': 'الحالات الطبية',
      // 'Hypertension (High BP)': 'ضغط الدم المرتفع',
      // 'Heart Disease': 'أمراض القلب',
      'Vitals': 'المؤشرات الحيوية',
      'Avg. Glucose Level': 'متوسط مستوى الجلوكوز',
      // 'BMI (Body Mass Index)': 'مؤشر كتلة الجسم',
      'Height': 'الطول',
      'Weight': 'الوزن',
      'BMI is auto-calculated from height & weight':
          'يُحسب مؤشر كتلة الجسم تلقائياً من الطول والوزن',
      'Lifestyle': 'نمط الحياة',
      // 'Smoking Status': 'حالة التدخين',
      // 'Work Type': 'نوع العمل',
      // 'Residence Type': 'نوع الإقامة',
      'Medical history saved successfully.': 'تم حفظ السجل الطبي بنجاح.',
      'Error saving medical history: ': 'خطأ في حفظ السجل الطبي: ',
      'Calculating stroke risk...':
          'جاري حساب خطر الإصابة بالذكاء الاصطناعي...',
      'Prediction History': 'سجل التقييمات الطبية',
      'History': 'التقييمات',
      'Vitals & Parameters': 'المؤشرات والمعايير الطبية',
      'cm': 'سم',
      'Hypertension': 'ارتفاع ضغط الدم',
      // 'Heart Disease': 'أمراض القلب',
      'No prediction history found': 'لا يوجد سجل تقييمات سابق',
      'Error loading history': 'حدث خطأ أثناء تحميل السجل',
      'When an AI prediction is made, it will appear here.':
          'عند إجراء تقييم جديد بالذكاء الاصطناعي، سيظهر هنا.',
      'Risk Score': 'معدل الخطر',
      'Assessment saved successfully': 'تم حفظ التقييم بنجاح',
      'e.g. 45': 'مثال: 45',
      'e.g. 105.4': 'مثال: 105.4',
      'e.g. 26.5': 'مثال: 26.5',

      // Patient Profile Tabs & Health Trackers
      'Settings': 'الإعدادات',
      'Records': 'السجلات',
      'Meds': 'الأدوية',
      // 'Appointments': 'المواعيد',
      // 'Uploaded Files': 'الملفات المرفوعة',
      'Doctor Appointments': 'مواعيد الأطباء',
      'Add Medication': 'إضافة علاج',
      'Edit Medication': 'تعديل العلاج',
      'Add Appointment': 'إضافة موعد',
      'Medication Name': 'اسم العلاج',
      'Dose Time:': 'وقت الجرعة:',
      'Medication Photo (Optional)': 'صورة العلاج (اختياري)',
      'Camera': 'الكاميرا',
      'Gallery': 'المعرض',
      'Time to take your medication:': 'حان وقت تناول علاجك:',
      'Medication Reminder': 'تذكير بموعد العلاج',
      'Doctor Name': 'اسم الطبيب',
      'Specialty (Optional)': 'التخصص (اختياري)',
      'Date & Time:': 'التاريخ والوقت:',
      'Delete Medication': 'حذف العلاج',
      'Delete Appointment': 'حذف الموعد',
      'Are you sure you want to delete': 'هل أنت متأكد من حذف',
      'My Medications': 'أدويتي',
      'Daily': 'يومياً',
      'Add': 'إضافة',
      // 'Save': 'حفظ',
      // 'Cancel': 'إلغاء',
      'Delete': 'حذف',
      'Selected date must be in the future':
          'يجب أن يكون التاريخ المحدد في المستقبل',
      'Appointment must be scheduled at least 1 hour in the future':
          'يجب أن يكون موعد الطبيب بعد ساعة على الأقل من الآن',
      'Appointment with Dr.': 'موعد مع دكتور',
      'in 1 hour!': 'خلال ساعة!',
      'Doctor Appointment': 'موعد طبيب',
      'Medication Time': 'موعد دواء',
      'Reminder for your appointment with': 'تذكير بموعدك مع',
      'No medications listed': 'لا توجد أدوية مضافة',
      'Add your daily medications and schedule notifications so you never miss a dose.':
          'أضف أدويتك اليومية وجدول التنبيهات لتتجنب نسيان أي جرعة.',
      'No appointments scheduled': 'لا توجد مواعيد مجدولة',
      'Keep track of your visits to the clinic and get notified 1 hour prior to your schedule.':
          'تابع زياراتك للعيادة واحصل على تذكير قبل الموعد بساعة واحدة.',
      // 'No files uploaded yet': 'لم يتم رفع أي ملفات بعد',
      'Your uploaded diagnostic reports, prescriptions, and ECG/PPG files will appear here.':
          'ستظهر هنا تقاريرك التشخيصية والوصفات وملفات إشارات رسم القلب/النبض التي قمت برفعها.',
      'No files in this category': 'لا توجد ملفات في هذا القسم',
      'Uploaded:': 'تاريخ الرفع:',
      // Toast messages for meds & appointments
      'Medication added successfully': 'تم إضافة العلاج بنجاح',
      'Medication updated successfully': 'تم تعديل العلاج بنجاح',
      'Medication deleted': 'تم حذف العلاج بنجاح',
      'Failed to save medication': 'فشل في حفظ العلاج',
      'Failed to delete medication': 'فشل في حذف العلاج',
      'Please enter medication name': 'يرجى إدخال اسم العلاج',
      'Appointment added successfully': 'تم إضافة الموعد بنجاح',
      'Appointment deleted': 'تم حذف الموعد بنجاح',
      'Failed to save appointment': 'فشل في حفظ الموعد',
      'Failed to delete appointment': 'فشل في حذف الموعد',
      'Please enter doctor name': 'يرجى إدخال اسم الطبيب',
      'Jan': 'يناير',
      'Feb': 'فبراير',
      'Mar': 'مارس',
      'Apr': 'أبريل',
      'May': 'مايو',
      'Jun': 'يونيو',
      'Jul': 'يوليو',
      'Aug': 'أغسطس',
      'Sep': 'سبتمبر',
      'Oct': 'أكتوبر',
      'Nov': 'نوفمبر',
      'Dec': 'ديسمبر',

      // AI Chatbot
      'AI Medical Assistant': 'المساعد الطبي بالذكاء الاصطناعي',
      'Ask a question...': 'اسأل سؤالاً...',
      'AI is typing...': 'المساعد الطبي يكتب الآن...',
      'Image attached successfully': 'تم إرفاق الصورة بنجاح',
      'File attached successfully': 'تم إرفاق الملف بنجاح',
      'Sent an attachment:': 'أرسل مرفقاً:',
      'Attachment': 'مرفق',
      'Attached file': 'ملف مرفق',
      'Mon': 'الاثنين',
      'Tues': 'الثلاثاء',
      'wed': 'الأربعاء',
      'Thurs': 'الخميس',
      'Heart rate': 'معدل ضربات القلب',
      // 'How can I help you today?': 'كيف يمكنني مساعدتك اليوم؟',
      // 'Ask anything, I am here to assist.': 'اسأل أي شيء، أنا هنا للمساعدة.',

      // AI Model Symptoms
      'Clinical Symptoms (For AI Prediction)': 'الأعراض السريرية (لتنبؤ الذكاء الاصطناعي)',
      'Chest Pain': 'ألم في الصدر',
      'Irregular Heartbeat': 'عدم انتظام ضربات القلب',
      'Shortness of Breath': 'ضيق التنفس',
      'Fatigue & Weakness': 'تعب وضعف',
      'Dizziness': 'دوخة/دوار',
      'Swelling Edema': 'تورم (وذمة)',
      'Neck/Jaw Pain': 'ألم في الرقبة أو الفك',
      'Excessive Sweating': 'تعرق مفرط',
      'Persistent Cough': 'سعال مستمر',
      'Nausea & Vomiting': 'غثيان وقيء',
      'Chest Discomfort': 'انزعاج في الصدر',
      'Cold Hands & Feet': 'برودة اليدين والقدمين',
      'Snoring / Sleep Apnea': 'شخير / انقطاع النفس النومي',
      'Feeling of Anxiety/Doom': 'شعور بالقلق المفرط',
      
      // Exceptions
      'API URL is not configured in .env file': 'رابط الـ API غير مهيأ في ملف .env',
      'Error connecting to AI Model': 'خطأ في الاتصال بنموذج الذكاء الاصطناعي',
      'Failed to get prediction from AI Model': 'فشل في الحصول على التنبؤ من الذكاء الاصطناعي',
      'bad_request_error': 'طلب غير صالح، حاول مرة أخرى',
      'forbidden_error': 'طلب مرفوض، حاول مرة أخرى',
      'unauthorized_error': 'المستخدم غير مصرح له، يرجى تسجيل الدخول مجدداً',
      'not_found_error': 'غير موجود، حاول مرة أخرى',
      'internal_server_error': 'خطأ في الخادم، حاول مرة أخرى لاحقاً',
      'timeout_error': 'انتهى وقت الاتصال، حاول مرة أخرى',
      'default_error': 'حدث خطأ ما، حاول مرة أخرى',
      'cache_error': 'خطأ في الذاكرة المخبأة، حاول مرة أخرى',
      'no_internet_error': 'يرجى التحقق من اتصالك بالإنترنت',
      'Forbidden request, try again later': 'غير مسموح بهذا الطلب، حاول مرة أخرى لاحقاً',
      'User not found.': 'المستخدم غير موجود.',
      'Validation Error': 'خطأ في التحقق من صحة البيانات.',
      'Registration failed.': 'فشل إنشاء الحساب. يرجى المحاولة مرة أخرى.',
      'Login failed.': 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.',
      'Server error, try again later': 'خطأ في الخادم، حاول مرة أخرى لاحقاً',
      'Connection timeout, try again later': 'انتهت مهلة الاتصال، حاول مرة أخرى لاحقاً',
      'Please check your internet connection': 'يرجى التحقق من اتصالك بالإنترنت',
      'Network error. Please try again.': 'خطأ في الاتصال بالشبكة. يرجى المحاولة مرة أخرى.',
      'An unexpected error occurred. Please try again.': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      'Failed to send OTP.': 'فشل إرسال رمز التحقق.',
      'Failed to verify OTP.': 'فشل التحقق من الرمز.',
      'Invalid or expired OTP code.': 'رمز التحقق غير صالح أو منتهي الصلاحية.',
      'Session expired. Please request a new OTP.': 'انتهت صلاحية الجلسة. يرجى طلب رمز تحقق جديد.',
      'Failed to reset password.': 'فشل إعادة تعيين كلمة المرور.',
      'The email has already been taken.': 'البريد الإلكتروني مسجل مسبقاً.',
      'The phone has already been taken.': 'رقم الهاتف مسجل مسبقاً.',
    },
  };

  String translate(String key) {
    final localized = _localizedValues[locale.languageCode]?[key];
    if (localized != null) return localized;

    if (locale.languageCode == 'ar') {
      final lower = key.toLowerCase();
      if (lower.contains('email has already been taken')) {
        return 'البريد الإلكتروني مسجل مسبقاً.';
      } else if (lower.contains('phone has already been taken')) {
        return 'رقم الهاتف مسجل مسبقاً.';
      } else if (lower.contains('invalid email or password') || lower.contains('invalid credentials') || lower.contains('unauthenticated')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      } else if (lower.contains('password')) {
        if (lower.contains('match')) return 'تأكيد كلمة المرور غير متطابق.';
        if (lower.contains('least') || lower.contains('characters')) return 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';
      } else if (lower.contains('network') || lower.contains('connection')) {
        return 'خطأ في الاتصال بالشبكة. يرجى المحاولة مرة أخرى.';
      } else if (lower.contains('timeout')) {
        return 'انتهت مهلة الاتصال، حاول مرة أخرى لاحقاً';
      } else if (lower.contains('server error')) {
        return 'خطأ في الخادم، حاول مرة أخرى لاحقاً';
      }
    }

    return key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)?.translate(this) ?? this;
  }
}

