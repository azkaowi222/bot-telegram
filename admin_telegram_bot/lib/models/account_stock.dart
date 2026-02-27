class AccountStock {
  final String? id;
  final Map<String, dynamic> product;
  final String email;
  final String password;
  final String status;
  final String category;
  final String? order;
  final String createdAt;
  final Map<String, dynamic> metadata;
  final String? soldAt;

  const AccountStock({
    this.id,
    required this.product,
    required this.email,
    required this.password,
    required this.status,
    required this.createdAt,
    required this.category,
    required this.metadata,
    this.order,
    this.soldAt,
  });

  factory AccountStock.fromJson(Map<String, dynamic> json) {
    return AccountStock(
      id: json['_id'] ?? 'no _id',
      product: json['product'] ?? {'product': 'no product'},
      email: json['email'],
      password: json['password'],
      status: json['status'],
      category: json['product']?['category'] ?? 'no category',
      order: json['order'] ?? 'no order',
      createdAt: json['createdAt'] ?? 'no created at',
      metadata: json['metadata'] ?? {'2fa': 'no 2fa'},
      soldAt: json['soldAt'] ?? 'no soldAt',
    );
  }
}
