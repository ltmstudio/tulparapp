import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/view/component/order/order_card_driver.dart';

class DriverOrdersTab extends StatefulWidget {
  const DriverOrdersTab({super.key});

  @override
  State<DriverOrdersTab> createState() => _DriverOrdersTabState();
}

class _DriverOrdersTabState extends State<DriverOrdersTab> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: GetBuilder<DriverOrderController>(builder: (orderController) {
        var myOrders = orderController.myOrders.value;
        var myOrdersLoading = orderController.myOrdersLoading.value;

        var historyOrders = orderController.historyOrders.value;
        var historyOrdersLoading = orderController.historyOrdersLoading.value;
        return Scaffold(
            appBar: AppBar(
              title: Text('Мои заказы'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Активные'),
                  Tab(text: 'История'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await orderController.fetchMyOrders();
                  },
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: CoreDecoration.primaryPadding),
                    children: [
                      if (myOrders.isEmpty && myOrdersLoading)
                        Column(
                          children: [
                            SizedBox(height: h * 0.3),
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        )
                      else if (myOrders.isEmpty)
                        Column(
                          children: [
                            SizedBox(height: h * 0.3),
                            Text(
                              'У вас нет заказов',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text('Потяните вниз чтобы обновить'),
                          ],
                        )
                      else if (myOrders.isNotEmpty)
                        for (var order in myOrders) DriverOrderCard(order: order, onHistoryPage: true),
                    ],
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async {
                    await orderController.fetchHistoryOrders();
                  },
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: CoreDecoration.primaryPadding),
                    children: [
                      if (historyOrders.isEmpty && historyOrdersLoading)
                        Column(
                          children: [
                            SizedBox(height: h * 0.3),
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        )
                      else if (historyOrders.isEmpty)
                        Column(
                          children: [
                            SizedBox(height: h * 0.3),
                            Text(
                              'У вас нет заказов',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text('Потяните вниз чтобы обновить'),
                          ],
                        )
                      else if (historyOrders.isNotEmpty)
                        for (var order in historyOrders) DriverOrderCard(order: order, blockOpen: true),
                    ],
                  ),
                )
              ],
            ));
      }),
    );
  }
}
