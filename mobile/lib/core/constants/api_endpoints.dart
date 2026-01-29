class ApiEndpoints {

  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/update';
  

  static const String tasks = '/tasks';
  static const String taskById = '/tasks/:id';
  static const String toggleTask = '/tasks/:id/toggle';
  static const String taskStats = '/tasks/stats';
  

  static const String lists = '/lists';
  static const String listById = '/lists/:id';
  static const String inviteToList = '/lists/:id/invite';
  static const String joinList = '/lists/join/:code';
  static const String publicLists = '/lists/public';
  

  static const String achievements = '/achievements';
  static const String checkAchievements = '/achievements/check';
  

  static const String sync = '/sync';
  

  static String taskByIdUrl(String id) => '/tasks/$id';
  static String listByIdUrl(String id) => '/lists/$id';
  static String inviteToListUrl(String id) => '/lists/$id/invite';
  static String joinListUrl(String code) => '/lists/join/$code';
}