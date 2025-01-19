import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/component/order/order_card_driver.dart';

class DriverFeedTab extends StatefulWidget {
  const DriverFeedTab({super.key});

  @override
  State<DriverFeedTab> createState() => _DriverFeedTabState();
}

class _DriverFeedTabState extends State<DriverFeedTab> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverOrderController>(builder: (orderController) {
      var orders = orderController.orders.value;
      return Scaffold(
        appBar: AppBar(
          title: Text('Лента заказов'.tr),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await orderController.fetchOrdersFeed();
          },
          child: AnimatedList(
            key: orderController.listKey,
            initialItemCount: orders.length,
            itemBuilder: (context, index, animation) {
              final order = orders[index];
              return _buildOrderItem(order, animation);
            },
          ),
        ),
      );
    });
  }

  Widget _buildOrderItem(OrderModel order, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ),
          ),
          child: DriverOrderCard(order: order)),
    );
  }
}
