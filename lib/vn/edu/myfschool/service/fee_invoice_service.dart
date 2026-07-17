import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/fee_invoice_model.dart';
import 'api_config.dart';

class FeeInvoiceService {
  Future<List<FeeInvoiceModel>> getMyFeeInvoices({int? studentId}) async {
    try {
      final headers = await ApiConfig.getHeaders();
      String url = '${ApiConfig.baseUrl}/fees/my-invoices';
      if (studentId != null) {
        url += '?studentId=$studentId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => FeeInvoiceModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Fee Invoice Error: $e');
    }
    return [];
  }
}
