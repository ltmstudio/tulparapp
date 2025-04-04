import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/view/component/order/order_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GetBuilder<UserOrderController>(builder: (orderController) {
        var orders = orderController.orders.value;
        var isEnd = orderController.isOrdersEnd.value;
        var ordersLoading = orderController.ordersLoading.value;
        return Scaffold(
          appBar: AppBar(
            title: Text("Мои заказы".tr),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Активные'.tr),
                Tab(text: 'История'.tr),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await orderController.fetchOrders(refresh: true);
                },
                child: ListView(
                  children: [
                    SizedBox(height: 10),
                    for (var order in orders.where((order) => order.status != 'closed'))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: OrderCard(order: order, onHistoryPage: true),
                      ),
                    if (!isEnd)
                      TextButton(
                          onPressed: () {
                            if (ordersLoading) return;
                            orderController.fetchOrders();
                          },
                          child: ordersLoading
                              ? Lottie.asset(
                                  CoreAssets.lottieLoadingPrimary,
                                  width: 20,
                                  height: 20,
                                )
                              : Text('Загрузить еще'.tr)),
                  ],
                ),
              ),
              RefreshIndicator(
                onRefresh: () async {
                  await orderController.fetchOrders(refresh: true);
                },
                child: ListView(
                  children: [
                    SizedBox(height: 10),
                    for (var order in orders.where((order) => order.status == 'closed'))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: OrderCard(order: order, onHistoryPage: true),
                      ),
                    if (!isEnd)
                      TextButton(
                          onPressed: () {
                            if (ordersLoading) return;
                            orderController.fetchOrders();
                          },
                          child: ordersLoading
                              ? Lottie.asset(
                                  CoreAssets.lottieLoadingPrimary,
                                  width: 20,
                                  height: 20,
                                )
                              : Text('Загрузить еще'.tr)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
