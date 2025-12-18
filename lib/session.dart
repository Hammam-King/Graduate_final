import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }
  static Future<void> saveFname(String fname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fname', fname);
  }
  static Future<void> saveLname(String lname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lname', lname);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');

  }
  static Future<String?> getFname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fname');
  }
  static Future<String?> getLname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lname');
  }

  static Future<bool?> getUserrole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('admin');
  }

  static Future<void> saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user['user_id']);
    await prefs.setString('email', user['email']);
    await prefs.setString('fname', user['fname']);
    await prefs.setString('lname', user['lname']);
    //await prefs.setBool('admin', user['admin']);
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}