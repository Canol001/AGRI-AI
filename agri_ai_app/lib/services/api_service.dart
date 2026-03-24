import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://199.231.191.165:8000/api/';

  // ────────────────────────────────────────────────
  //  LOGIN – expects JWT pair (access + refresh)
  // ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('LOGIN → Status: ${response.statusCode}');
      print('LOGIN → Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final access = data['access'] as String?;
        final refresh = data['refresh'] as String?;

        if (access != null && refresh != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', access);
          await prefs.setString('refresh_token', refresh);
          await prefs.setString('username', username);

          print('LOGIN → JWT tokens saved successfully');
          return {'success': true};
        }
      }

      String msg = 'Login failed. Please check your credentials.';
      try {
        final err = jsonDecode(response.body);
        msg = err['detail'] ?? err['error'] ?? msg;
      } catch (_) {}

      return {'success': false, 'message': msg};
    } catch (e) {
      print('LOGIN EXCEPTION: $e');
      return {'success': false, 'message': 'Network error. Please check your connection.'};
    }
  }

  // ────────────────────────────────────────────────
  //  REGISTER – accepts single token or JWT pair
  // ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('REGISTER → Status: ${response.statusCode}');
      print('REGISTER → Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Case 1: Backend returns JWT pair (access + refresh)
        String? access = data['access'] as String?;
        String? refresh = data['refresh'] as String?;

        // Case 2: Backend returns single token
        if (access == null) {
          access = data['token'] as String?;
        }

        if (access != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', access);
          if (refresh != null) {
            await prefs.setString('refresh_token', refresh);
          }
          await prefs.setString('username', username);

          print('REGISTER → Token(s) saved successfully');
          return {'success': true};
        }
      }

      String msg = 'Registration failed. Please try again.';
      try {
        final err = jsonDecode(response.body);
        if (err['username'] != null) {
          msg = 'Username is already taken.';
        } else if (err['email'] != null) {
          msg = 'Email is already in use.';
        } else {
          msg = err['detail'] ?? err['error'] ?? msg;
        }
      } catch (_) {}

      return {'success': false, 'message': msg};
    } catch (e) {
      print('REGISTER EXCEPTION: $e');
      return {'success': false, 'message': 'Network error. Please check your connection.'};
    }
  }




  // Add this method inside ApiService class

static Future<http.Response> authenticatedPatch(
  String endpoint, {
  required Map<String, dynamic> body,
}) async {
  final url = Uri.parse('$baseUrl$endpoint');
  final headers = await _getAuthHeaders();

  final response = await http.patch(
    url,
    headers: headers,
    body: jsonEncode(body),
  );

  print('PATCH $endpoint → ${response.statusCode}');
  return response;
}



  // ────────────────────────────────────────────────
  //  AUTH HELPERS
  // ────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('getToken → Retrieved: ${token != null ? "yes" : "no"}');
    return token;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    print('LOGOUT → Cleared all auth data');
  }

  // ────────────────────────────────────────────────
  //  AUTHENTICATED REQUEST HELPERS
  // ────────────────────────────────────────────────

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated - no access token');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static Future<http.Response> authenticatedGet(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('GET → $url');

    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    print('GET $endpoint → ${response.statusCode}');
    return response;
  }

  static Future<http.Response> authenticatedPost(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('POST → $url');

    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    print('POST $endpoint → ${response.statusCode}');
    return response;
  }

  static Future<http.Response> authenticatedDelete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('DELETE → $url');

    final headers = await _getAuthHeaders();

    final response = await http.delete(
      url,
      headers: headers,
    );

    print('DELETE $endpoint → ${response.statusCode}');
    return response;
  }

  static Future<http.Response> authenticatedPut(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('PUT → $url');

    final headers = await _getAuthHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('PUT $endpoint → ${response.statusCode}');
    return response;
  }

  // ────────────────────────────────────────────────
  //  Multipart / file upload (already used in dashboard)
  // ────────────────────────────────────────────────
  static Future<http.StreamedResponse> authenticatedMultipartPost({
    required String endpoint,
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('MULTIPART POST → $url');

    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.addAll(files);

    final streamedResponse = await request.send();
    print('MULTIPART POST $endpoint → ${streamedResponse.statusCode}');
    return streamedResponse;
  }
}