import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MpesaService {
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';

  Future<String> getAccessToken() async {
    final consumerKey = dotenv.env['MPESA_CONSUMER_KEY'];
    final consumerSecret = dotenv.env['MPESA_CONSUMER_SECRET'];

    if (consumerKey == null || consumerSecret == null) {
      throw Exception(
        'M-Pesa credentials missing. Check that .env exists and '
        'contains MPESA_CONSUMER_KEY and MPESA_CONSUMER_SECRET.',
      );
    }

    final credentials = '$consumerKey:$consumerSecret';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    final url = Uri.parse(
      '$_baseUrl/oauth/v1/generate?grant_type=client_credentials',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Basic $encodedCredentials',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get M-Pesa access token: '
        '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['access_token'] as String?;

    if (token == null) {
      throw Exception('Access token missing from M-Pesa response.');
    }

    return token;
  }
}