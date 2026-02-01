import 'package:admin_telegram_bot/models/order.dart';
import 'package:admin_telegram_bot/views/order_details.dart';
import 'package:flutter/material.dart';
import '../controllers/orders_history_controller.dart';

class OrderHistoryPage extends StatefulWidget {
  final String status;
  const OrderHistoryPage({super.key, required this.status});

  @override
  State<OrderHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrderHistoryPage> {
  final controller = OrdersHistoryController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addListener(_onUpdate);
    controller.getOrdersHistory();
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onUpdate);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final views =
        controller.ordersHistory.where((view) {
          if (widget.status == 'all') {
            return true;
          }
          return view.status == widget.status;
        }).toList();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Expanded(
          child:
              controller.errorMsg.isNotEmpty
                  ? Text(controller.errorMsg)
                  : ListView.builder(
                    itemCount: views.length,
                    itemBuilder: (context, index) {
                      final order = views[index];
                      final orderTime = order.date.substring(
                        0,
                        order.date.indexOf('T'),
                      );
                      Color colorStatus;
                      switch (order.status) {
                        case 'paid':
                          colorStatus = Colors.green[400]!;
                          break;
                        case 'pending':
                          colorStatus = Colors.orange[300]!;
                          break;
                        default:
                          colorStatus = Colors.red[700]!;
                      }
                      return GestureDetector(
                        onTap: () async {
                          final id = order.id;
                          final Order? orderHistory = await controller
                              .getOrdersHistoryById(id: id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      OrderDetailsScreen(order: orderHistory),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1.5,
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ),
                            // gradient: LinearGradient(
                            //   colors: [Colors.cyan, Colors.deepPurpleAccent],
                            // ),
                          ),
                          child: ListTile(
                            // subtitle: Text(order.soldBy),
                            leading: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.network(
                                  '$backendUrl/${order.image}',
                                  headers: {'ngrok-skip-browser-warning': '1'},
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              order.product,
                              style: TextStyle(fontSize: 13),
                            ),
                            subtitle: Container(
                              padding: EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  Text(orderTime),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                  ),
                                  SizedBox(width: 5),

                                  Text(order.payment),
                                ],
                              ),
                            ),
                            trailing: Chip(
                              label: Text(order.status.toUpperCase()),
                              labelStyle: TextStyle(color: Colors.white),
                              backgroundColor: colorStatus,
                              // elevation: 4,
                              side: BorderSide.none,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
