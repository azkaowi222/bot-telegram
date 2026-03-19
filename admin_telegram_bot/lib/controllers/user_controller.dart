import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserController {
  Future<void> storeToken(String token) async {
    final String backendUrl = dotenv.get('BACKEND_URL');
    print('url: $backendUrl');
    final response = await http.get(
      Uri.parse('$backendUrl/api/store-token/$token'),
    );
    print(response.body);
    final data = await jsonDecode(response.body);
    print(data);
  }
}
