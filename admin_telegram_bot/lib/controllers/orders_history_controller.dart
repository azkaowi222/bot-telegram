import 'dart:convert';
import 'package:admin_telegram_bot/models/order.dart';
import 'package:admin_telegram_bot/models/order_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String backendUrl = dotenv.get('BACKEND_URL');

class OrdersHistoryController extends ChangeNotifier {
  bool loading = false;
  String errorMsg = "";
  List<OrdersHistory> ordersHistory = [];
  Future<void> getOrdersHistory() async {
    loading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('$backendUrl/api/orders');
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': '1'},
      );
      // debugPrint(jsonDecode(response.body).toString());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List datas = data['data'];
        // debugPrint(datas.toString());
        ordersHistory = datas.map((e) => OrdersHistory.fromJson(e)).toList();
      } else {
        throw Exception('failed to load orders');
      }
    } catch (e) {
      errorMsg = "Failed to Load orders";
      debugPrint("error anjing ${e.toString()}");
      notifyListeners();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Order?> getOrdersHistoryById({required String id}) async {
    final OrdersHistory order = ordersHistory.firstWhere((e) {
      return e.id == id;
    });
    try {
      final Uri uri = Uri.parse('$backendUrl/api/order/${order.id}');
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': '1'},
      );
      final data = jsonDecode(response.body);
      return Order.fromjson(data['data']);
    } catch (e) {
      print(e.toString());
    }
  }
}
