import 'dart:convert';
import 'package:admin_telegram_bot/models/account_stock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AccountStockController extends ChangeNotifier {
  final List<AccountStock> _accountsStocks = [];
  List<AccountStock> get accountStocks => _accountsStocks;
  final backendUrl = dotenv.get('BACKEND_URL');
  bool isLoading = false;
  Future<void> getAllAccountsStocks() async {
    isLoading = true;
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/accounts'),
        headers: {'ngrok-skip-browser-warning': '1'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        print('failed to load accounts: ${data['message']}');
        return;
      }
      final accounts = data['data'] as List;
      // print(accounts);
      for (final account in accounts) {
        _accountsStocks.add(AccountStock.fromJson(account));
      }
      notifyListeners();
    } catch (e) {
      print('Exception error ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccountStock(AccountStock account) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/account/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': account.product['id'],
          'email': account.email,
          'password': account.password,
          'metadata': account.metadata,
        }),
      );

      if (response.statusCode != 201) {
        print('Failed to add stock');
      }
      final json = jsonDecode(response.body);
      final data = json['data'];
      _accountsStocks.add(AccountStock.fromJson(data));
    } catch (e) {
      print('Error exception ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<int?> updateAccountStock(AccountStock account) async {
    try {
      final response = await http.patch(
        Uri.parse('$backendUrl/api/account/edit/${account.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': account.product['id'],
          'email': account.email,
          'password': account.password,
          'metadata': account.metadata,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to add stock');
        return response.statusCode;
      }
      final json = jsonDecode(response.body);
      final data = json['data'];
      _accountsStocks.forEach((element) {
        print(element.email);
      });
      final emailIndex = _accountsStocks.indexWhere((
        AccountStock accountIndex,
      ) {
        return accountIndex.id == account.id;
      });
      print('emailIndex: $emailIndex');
      _accountsStocks.replaceRange(emailIndex, emailIndex + 1, [
        AccountStock.fromJson(data),
      ]);
      return response.statusCode;
    } catch (e) {
      print('Error exception ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }
}
