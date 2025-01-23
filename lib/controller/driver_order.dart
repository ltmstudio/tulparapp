import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/model/geo/route.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/model/order/sorting_value.dart';
import 'package:tulpar/model/order/type.dart';
import 'package:tulpar/view/component/order/order_card_driver.dart';

class DriverOrderController extends GetxController {
  var orders = Rx<List<OrderModel>>([]);
  var ordersLoading = Rx<bool>(false);

  var selectedOrderOnMap = Rx<OrderModel?>(null);
  var isRouteLoading = Rx<bool>(false);
  var geoRoute = Rx<GeoRouteModel?>(null);

  var sortingValues = OrdersSortingValueModel.initialValues;
  var selectedSortingValue = Rx<OrdersSortingValueModel?>(null);

  List<OrderTypeModel> get orderTypes => Get.find<UserOrderController>().orderTypes.value;
  var selectedOrderType = Rx<OrderTypeModel?>(null);

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

  Future<void> fetchOrdersFeed({bool resetAll = false}) async {
    var inDio = InDio();
    var dio = inDio.instance;
    ordersLoading.value = true;
    update();
    try {
      var resp = await dio.get("/driver/orders", queryParameters: {
        if (selectedSortingValue.value?.value != null) ...{
          "sorting_column": selectedSortingValue.value?.value,
          "sorting_direction": selectedSortingValue.value?.direction,
        },
        if (selectedOrderType.value?.id != null) ...{
          "type_id": selectedOrderType.value?.id,
        }
      });
      var newOrders = orderModelFromJson(json.encode(resp.data));
      _updateOrders(newOrders, resetAll: resetAll);
      Log.success("Получен список из ${orders.value.length} заказов");
    } catch (e) {
      Log.error("Ошибка при получении списка заказов: $e");
    }
    ordersLoading.value = false;
    update();
  }

  // Метод для обновления списка заказов
  void _updateOrders(List<OrderModel> newOrders, {bool resetAll = false}) {
    if (resetAll) {
      // Если нужно обновить все заказы, то анимируем исчезновение из списка каждый заказ и ставим пустой список
      for (int i = orders.value.length - 1; i >= 0; i--) {
        final removedOrder = orders.value.removeAt(i);
        listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildOrderItem(removedOrder, animation),
        );
      }
    }

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
      child: FadeTransition(
          opacity: animation,
          // SlideTransition(
          //     position: animation.drive(
          //       Tween<Offset>(
          //         begin: const Offset(1, 0),
          //         end: Offset.zero,
          //       ),
          //     ),
          child: DriverOrderCard(order: order)),
    );
  }

  Future<void> fetchSelectedOrderRoute() async {
    if (selectedOrderOnMap.value == null) {
      Log.warning("Не выбраны точки для построения маршрута");
      return;
    }
    if (selectedOrderOnMap.value!.geoA?.toLatLng == null || selectedOrderOnMap.value!.geoB?.toLatLng == null) {
      Log.warning("Не выбраны точки для построения маршрута");
      return;
    }

    var inDio = InDio();
    var dio = inDio.instance;
    try {
      isRouteLoading.value = true;
      update();

      var resp = await dio.post('/customer/geo/route', data: {
        "start_latitude": selectedOrderOnMap.value!.geoA!.toLatLng!.latitude,
        "start_longitude": selectedOrderOnMap.value!.geoA!.toLatLng!.longitude,
        "end_latitude": selectedOrderOnMap.value!.geoB!.toLatLng!.latitude,
        "end_longitude": selectedOrderOnMap.value!.geoB!.toLatLng!.longitude,
      });
      if (resp.statusCode == 200 && resp.data['route'] != null) {
        Log.success("Получен маршрут");
        var newRoute = geoRouteModelFromJson(json.encode(resp.data));
        geoRoute.value = newRoute;
        update();
      } else {
        Log.error("Ошибка получения маршрута");
      }
    } on DioException catch (e) {
      Log.error("Ошибка получения маршрута $e");
    } catch (e) {
      Log.error("Ошибка получения маршрута $e");
    }
    isRouteLoading.value = false;
    update();
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

  void setSelectedOrder(OrderModel? order) {
    selectedOrderOnMap.value = order;
    update();
    fetchSelectedOrderRoute();
  }

  void removeSelectedOrder() async {
    await Future.delayed(const Duration(milliseconds: 20));
    selectedOrderOnMap.value = null;
    geoRoute.value = null;
    update();
  }
}
