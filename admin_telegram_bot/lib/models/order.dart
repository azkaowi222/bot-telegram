class Order {
  final String id;
  final String telegramId;
  final String username;
  final num total;
  final String status;
  final String paymentMethod;
  final String date;
  final String productName;
  final num quantity;
  final num price;

  const Order({
    required this.id,
    required this.telegramId,
    required this.username,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.date,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory Order.fromjson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user'];
    final Map<String, dynamic> item = json['items'][0];
    return Order(
      id: json['_id'],
      telegramId: user['telegramId'].toString(),
      username: user['username'],
      total: json['totalPrice'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      date: json['createdAt'],
      productName: item['nameSnapshot'],
      quantity: item['quantity'],
      price: item['price'],
    );
  }
}
