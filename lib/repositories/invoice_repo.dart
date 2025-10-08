import 'package:socials_app/services/http_client.dart';

class InvoiceRepo {
  late HTTPClient _httpClient;
  static final _instance = InvoiceRepo._internal();

  factory InvoiceRepo() {
    return _instance;
  }

  InvoiceRepo._internal() {
    _httpClient = HTTPClient();
  }

/*  Future<InvoiceData?> getAllInvoices() async {
    try {
      final response = await _httpClient.getRequestWithHeader(url: kInvoiceURL);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        if (kDebugMode) {
          log('Invoice data: $data');
        }
        return InvoiceResponse.fromJson(data).data;
      } else {
        CustomSnackbar.showSnackbar('Error fetching invoices');
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        log('Invoice data: $e');
      }
    }
    return null;
  }

  Future<InvoiceData?> getwallet() async {
    final userId = SessionService().user?.id ?? '';
    try {
      final response = await _httpClient.getRequestWithHeader(url: "$kGetWalletURL/$userId");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.data);
        if (kDebugMode) {
          log('Wallet data: $data');
        }
        final con = InvoiceResponse.fromJson(data);
        if (kDebugMode) {
          log('Wallet data: $con');
        }
        return con.data;
      } else {
        // return response;
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        log('Wallet data: $e');
      }
    }
    return null;
  }*/
}
