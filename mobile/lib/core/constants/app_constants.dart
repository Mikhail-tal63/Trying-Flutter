class AppConstants {

  static const String appVersion = '1.0.0';
  static const String appName = 'قائمة مهامي';
  

  static const int splashDelay = 2; 
  static const int autoLogoutMinutes = 60;
  static const int maxTasksPerList = 100;
  static const int syncIntervalSeconds = 30; 
  

  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;
  static const int maxUsernameLength = 30;
  static const int maxEmailLength = 50;
  static const int minPasswordLength = 6;
  

  static const List<String> priorities = ['عادي', 'مهم', 'عاجل'];
  
 
  static const List<int> reminderTimes = [15, 30, 60, 120, 1440]; 
  static const List<String> reminderOptions = [
    '15 دقيقة قبل',
    '30 دقيقة قبل',
    'ساعة قبل',
    'ساعتين قبل',
    'يوم قبل'
  ];
  

  static const String appDescription = 'تطبيق لإدارة مهامك اليومية بسهولة';
  static const String welcomeMessage = 'مرحباً بك في قائمة مهامي';
}