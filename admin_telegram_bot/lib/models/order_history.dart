import 'package:flutter/foundation.dart';

class OrdersHistory {
  final String soldBy;
  final String product;
  final String status;
  final String payment;
  final String date;
  final String image;


  const OrdersHistory({
    required this.soldBy,
    required this.product,
    required this.status,
    required this.payment,
    required this.date,
    required this.image,
  });

  factory OrdersHistory.fromJson(Map<String, dynamic> json) {
    return OrdersHistory(
      soldBy: json['soldBy'],
      product: json['product'],
      status: json['status'],
      payment: json['payment'],
      date: json['date'],
      image: json['image_path'],
    );
  }
}
