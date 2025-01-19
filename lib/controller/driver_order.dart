import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/component/order/order_card_driver.dart';

class DriverOrderController extends GetxController {
  var orders = Rx<List<OrderModel>>([]);
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  Timer? _updateTimer;

  @override
  onReady() {
    fetchOrdersFeed();
    _startPeriodicUpdates();
    super.onReady();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchOrdersFeed() async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      var resp = await dio.get("/driver/orders");
      var newOrders = orderModelFromJson(json.encode(resp.data));
      _updateOrders(newOrders);
      Log.success("Получен список из ${orders.value.length} заказов");
    } catch (e) {
      Log.error("Ошибка при получении списка заказов: $e");
    }
  }

  // Метод для обновления списка заказов
  void _updateOrders(List<OrderModel> newOrders) {
    final currentOrders = List.of(orders.value);
    final newOrderIds = newOrders.map((e) => e.id).toSet();
    final currentOrderIds = currentOrders.map((e) => e.id).toSet();

    // Удаление заказов, которых больше нет
    for (int i = currentOrders.length - 1; i >= 0; i--) {
      if (!newOrderIds.contains(currentOrders[i].id)) {
        final removedOrder = currentOrders.removeAt(i);
        orders.value.removeAt(i);
        listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildOrderItem(removedOrder, animation),
        );
      }
    }

    // Добавление новых заказов
    for (int i = 0; i < newOrders.length; i++) {
      if (!currentOrderIds.contains(newOrders[i].id)) {
        currentOrders.insert(i, newOrders[i]);
        orders.value.insert(i, newOrders[i]);
        listKey.currentState?.insertItem(i);
      }
    }

    // Обновление текущего списка заказов
    orders.value.assignAll(currentOrders);
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

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        if (Get.find<AppController>().appMode.value == AppMode.driver) {
          fetchOrdersFeed();
        }
      },
    );
  }
}
