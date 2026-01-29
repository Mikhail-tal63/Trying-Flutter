class AppRouter {
  // مسارات المصادقة
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // مسارات التطبيق الرئيسية
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String createTask = '/tasks/create';
  static const String editTask = '/tasks/edit';
  static const String taskDetail = '/tasks/detail';
  
  // مسارات القوائم
  static const String lists = '/lists';
  static const String createList = '/lists/create';
  static const String listDetail = '/lists/detail';
  
  // مسارات الإنجازات
  static const String achievements = '/achievements';
  
  // مسارات الملف الشخصي
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  
  // مسارات إضافية
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String about = '/about';
  
  // مسارات تجريبية
  static const String debug = '/debug';
}