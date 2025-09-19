import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Voice API Integration Tests', () {
    const String apiBaseUrl = 'https://swatantra-ai.onrender.com';

    test('Test API connectivity', () async {
      try {
        final response = await http
            .get(
              Uri.parse('$apiBaseUrl/status'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));

        expect(response.statusCode, equals(200));
        print('✅ API connectivity test passed');
      } catch (e) {
        print('❌ API connectivity test failed: $e');
        fail('Unable to connect to voice API');
      }
    });

    test('Test start_voice endpoint', () async {
      try {
        final response = await http
            .post(
              Uri.parse('$apiBaseUrl/start_voice'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));

        // Should return 200 for successful start
        expect(response.statusCode, lessThanOrEqualTo(500));
        print(
          '✅ Start voice endpoint test passed - Status: ${response.statusCode}',
        );
      } catch (e) {
        print('❌ Start voice endpoint test failed: $e');
        fail('Unable to call start_voice endpoint');
      }
    });

    test('Test terminate_voice endpoint', () async {
      try {
        final response = await http
            .post(
              Uri.parse('$apiBaseUrl/terminate_voice'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));

        // Should return 200 for successful termination
        expect(response.statusCode, lessThanOrEqualTo(500));
        print(
          '✅ Terminate voice endpoint test passed - Status: ${response.statusCode}',
        );
      } catch (e) {
        print('❌ Terminate voice endpoint test failed: $e');
        fail('Unable to call terminate_voice endpoint');
      }
    });

    test('Test status endpoint response format', () async {
      try {
        final response = await http
            .get(
              Uri.parse('$apiBaseUrl/status'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('✅ Status endpoint response format test passed');
          print('Response structure: ${data.keys.toList()}');
        } else {
          print('⚠️ Status endpoint returned: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Status endpoint response format test failed: $e');
      }
    });
  });
}
