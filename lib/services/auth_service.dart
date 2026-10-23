
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
static const String _usersKey = 'registered_users';
static const String _loggedKey = 'isLogged';
static const String _userKey = 'user';

Future<Map<String, dynamic>> _getUsers() async {
final prefs = await SharedPreferences.getInstance();
final savedUsers = prefs.getString(_usersKey);

if (savedUsers == null || savedUsers.isEmpty) {
return {};
}

try {
return Map<String, dynamic>.from(jsonDecode(savedUsers));
} catch (_) {
return {};
}
}

Future<String?> register(
String name,
String email,
String pass,
) async {
final prefs = await SharedPreferences.getInstance();
final users = await _getUsers();

final normalizedEmail = email.trim().toLowerCase();

if (users.containsKey(normalizedEmail)) {
return 'Este correo ya tiene una cuenta registrada.';
}

users[normalizedEmail] = {
'name': name.trim(),
'password': pass,
};

await prefs.setString(_usersKey, jsonEncode(users));
await prefs.setBool(_loggedKey, true);
await prefs.setString(_userKey, name.trim());

return null;
}

Future<bool> login(String user, String pass) async {
final prefs = await SharedPreferences.getInstance();
final users = await _getUsers();

final input = user.trim().toLowerCase();

for (final entry in users.entries) {
final account = Map<String, dynamic>.from(entry.value);

final emailMatches = entry.key.toLowerCase() == input;
final nameMatches =
(account['name'] as String? ?? '').toLowerCase() == input;
final passwordMatches = account['password'] == pass;

if ((emailMatches || nameMatches) && passwordMatches) {
await prefs.setBool(_loggedKey, true);
await prefs.setString(
_userKey,
account['name'] as String? ?? user.trim(),
);
return true;
}
}

return false;
}

Future<void> logout() async {
final prefs = await SharedPreferences.getInstance();

// Cierra la sesión sin eliminar las cuentas registradas
// ni otros datos guardados por la aplicación.
await prefs.setBool(_loggedKey, false);
await prefs.remove(_userKey);
}

Future<bool> isLogged() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getBool(_loggedKey) ?? false;
}
}
