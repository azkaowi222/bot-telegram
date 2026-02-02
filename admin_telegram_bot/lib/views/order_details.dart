import 'package:admin_telegram_bot/models/order.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order? order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    String _status;
    int _colorStatus;
    switch (order!.status) {
      case 'paid':
        _status = 'Completed';
        _colorStatus = 0xFF2E7D32;
        break;
      case 'expired':
        _status = 'Expired';
        _colorStatus = 0xFFF44336;
        break;
      default:
        _status = 'pending';
        _colorStatus = 0xFFFF9800;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          order != null
              ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      GestureDetector(
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 19.5,
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: deviceWidth * 0.6,
                        child: Text(
                          'Order ${order?.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                actionsPadding: EdgeInsets.zero,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: Color(_colorStatus), // Dark green text
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              )
              : null,
      body: SingleChildScrollView(
        child:
            order != null
                ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Section 1: Store & Location Info ---
                      _buildTimelineSection(),

                      const SizedBox(height: 30),

                      // --- Section 2: Order Items ---
                      _buildOrderItem(
                        number: 1,
                        title: order!.productName,
                        qty: order!.quantity.toInt(),
                        price: order!.price.toString(),
                        showPromo: false,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                      ),
                      // --- Section 3: Payment Summary ---
                      _buildSummaryRow(
                        'Payment method',
                        order!.paymentMethod,
                        isValueDark: true,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Subtotal (${order!.quantity} items)',
                        '${order!.total.toString()}K',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Service fee', '0 IDR'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Discount', '0 IDR', isDiscount: true),
                      const SizedBox(height: 20),

                      // Total Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${order!.total}K',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // --- Section 4: Buttons ---
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.headset_mic_outlined,
                                size: 20,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'Contact support',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Order again',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Widget untuk bagian Timeline (Store -> Location)
  Widget _buildTimelineSection() {
    final String date = order!.date.split('T').join(' ');
    return Column(
      children: [
        // Location Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.account_circle_rounded,
                color: Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order!.telegramId} ${order!.username}',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget untuk setiap Item Order
  Widget _buildOrderItem({
    required int number,
    required String title,
    required int qty,
    required String price,
    bool showPromo = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '#$number $title X $qty',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              '${price}K',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Promo/Discount Price Section if applicable
        if (showPromo) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '₦ 4,700',
                style: TextStyle(
                  color: Color(0xFF00C853), // Green price
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₦ 4,700',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Widget untuk baris Summary
  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isValueDark = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color:
                isDiscount
                    ? Colors.grey[600]
                    : (isValueDark ? Colors.black : Colors.grey[600]),
            fontWeight: isValueDark ? FontWeight.w500 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
