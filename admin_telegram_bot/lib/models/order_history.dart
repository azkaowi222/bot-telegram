class OrdersHistory {
  final String id;
  final String soldBy;
  final String product;
  final String status;
  final String payment;
  final String date;
  final String image;


  const OrdersHistory({
    required this.id,
    required this.soldBy,
    required this.product,
    required this.status,
    required this.payment,
    required this.date,
    required this.image,
  });

  factory OrdersHistory.fromJson(Map<String, dynamic> json) {
    return OrdersHistory(
      id: json['id'],
      soldBy: json['soldBy'],
      product: json['product'],
      status: json['status'],
      payment: json['payment'],
      date: json['date'],
      image: json['image_path'],
    );
  }
}
