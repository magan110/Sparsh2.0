import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dsr_exception_models.dart';

class DsrExceptionService {
  static const String baseUrl = 'http://192.168.36.25/api/DsrTry';

  /// Get exception metadata (exception types, status flags, approver)
  static Future<ExceptionMetadata> getExceptionMetadata({String procType = 'N'}) async {
    try {
      final url = Uri.parse('$baseUrl/getExceptionMetadata')
          .replace(queryParameters: {'procType': procType});
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExceptionMetadata.fromJson(data);
      } else {
        throw Exception('Failed to load exception metadata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exception metadata: $e');
    }
  }

  /// Get exception requests (new blank row or pending approvals)
  static Future<List<ExceptionRequest>> getExceptionRequests({
    String procType = 'N',
    String emplCode = '',
  }) async {
    try {
      final queryParams = {'procType': procType};
      if (emplCode.isNotEmpty) {
        queryParams['emplCode'] = emplCode;
      }
      
      final url = Uri.parse('$baseUrl/getExceptionRequests')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => ExceptionRequest.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load exception requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exception requests: $e');
    }
  }

  /// Get exception history (created/pending entries)
  static Future<List<ExceptionHistory>> getExceptionHistory({String procType = 'N'}) async {
    try {
      final url = Uri.parse('$baseUrl/getExceptionHistory')
          .replace(queryParameters: {'procType': procType});
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => ExceptionHistory.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load exception history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exception history: $e');
    }
  }

  /// Submit exception entries
  static Future<bool> submitExceptions(List<ExceptionSubmission> submissions) async {
    try {
      final url = Uri.parse('$baseUrl/submitExceptions');
      
      final requestBody = submissions.map((s) => s.toJson()).toList();
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to submit exceptions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting exceptions: $e');
    }
  }
} 