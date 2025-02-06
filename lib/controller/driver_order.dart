import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/stream.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/model/app/city.dart';
import 'package:tulpar/model/geo/route.dart';
import 'package:tulpar/model/order/car_class.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/model/order/sorting_value.dart';
import 'package:tulpar/model/order/type.dart';
import 'package:tulpar/view/component/order/order_card_driver.dart';

class DriverOrderController extends GetxController {
  var orders = Rx<List<OrderModel>>([]);
  var ordersLoading = Rx<bool>(false);

  var expandedOrders = Rx<List<OrderModel>>([]);
  var expandedOrderLoading = Rx<bool>(false);

  var myOrders = Rx<List<OrderModel>>([]);
  var myOrdersLoading = Rx<bool>(false);

  var historyOrders = Rx<List<OrderModel>>([]);
  var historyOrdersLoading = Rx<bool>(false);

  var selectedOrderOnMap = Rx<OrderModel?>(null);
  var isRouteLoading = Rx<bool>(false);
  var geoRoute = Rx<GeoRouteModel?>(null);

  var sortingValues = OrdersSortingValueModel.initialValues;
  var selectedSortingValue = Rx<OrdersSortingValueModel?>(null);

  List<OrderTypeModel> get orderTypes => Get.find<UserOrderController>().orderTypes.value;
  var selectedOrderType = Rx<OrderTypeModel?>(null);

  List<CarClassModel> get orderClasses => Get.find<UserOrderController>()
      .carClasses
      .value
      .where((element) => (element.id ?? 99) <= (Get.find<DriverController>().profile.value?.classId ?? 0))
      .toList();
  var selectedOrderClass = Rx<CarClassModel?>(null);

  var selectedNotDelivery = Rx<bool>(false);
  var selectedNoCargo = Rx<bool>(false);

  List<CityModel> get cities => Get.find<UserOrderController>().cities.value;
  var selectedCityA = Rx<CityModel?>(null);
  var selectedCityB = Rx<CityModel?>(null);

  void setSelectedCities(CityModel? cityA, CityModel? cityB) {
    selectedCityA.value = cityA;
    selectedCityB.value = cityB;
    update();
  }

  void unsetSelectedCities() {
    selectedCityA.value = null;
    selectedCityB.value = null;
    update();
  }

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
        },
        if (selectedCityA.value?.id != null) ...{
          "city_a_id": selectedCityA.value?.id,
        },
        if (selectedCityB.value?.id != null) ...{
          "city_b_id": selectedCityB.value?.id,
        },
        if (selectedOrderClass.value?.id != null) ...{
          "class": selectedOrderClass.value?.id,
        },
        if (selectedNotDelivery.value) ...{
          "no_delivery": true,
        },
        if (selectedNoCargo.value) ...{
          "no_cargo": true,
        },
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

  Future<String?> fetchOrderDetails(int orderId) async {
    var inDio = InDio();
    var dio = inDio.instance;
    expandedOrderLoading.value = true;
    update();
    try {
      var resp = await dio.get("/driver/orders/$orderId");
      var expandedOrder = OrderModel.fromJson(json.decode(json.encode(resp.data)));
      expandedOrders.value.add(expandedOrder);
      expandedOrderLoading.value = false;
      update();
      Log.success("Получены детали заказа");
      return null;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
      }
      Log.error("Ошибка при получении деталей заказа: $e");
    } catch (e) {
      CoreToast.showToast("Ошибка запроса".tr);
      Log.error("Ошибка при получении деталей заказа: $e");
    } finally {
      expandedOrderLoading.value = false;
      update();
    }
    return null;
  }

  Future<String?> takeOrderRequest(int orderId) async {
    var inDio = InDio();
    var dio = inDio.instance;
    expandedOrderLoading.value = true;
    update();
    try {
      var resp = await dio.post("/driver/orders/$orderId");
      if (resp.statusCode == 200 && resp.data != null && resp.data['success'] == true) {
        Log.success("Заказ успешно взят");
        expandedOrderLoading.value = false;
        update();
        Get.find<WidgetStreamController>().switchTab(0);
        fetchMyOrders();
        return null;
      }
      if (resp.data != null && resp.data['message'] != null) {
        expandedOrderLoading.value = false;
        update();
        return resp.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
      }
      Log.error("Ошибка оформления заказа : $e");
    } catch (e) {
      CoreToast.showToast("Ошибка запроса".tr);
      Log.error("Ошибка при получении деталей заказа: $e");
    } finally {
      expandedOrderLoading.value = false;
      update();
    }
    return null;
  }

  Future<String?> closeOrderRequest(int orderId) async {
    var inDio = InDio();
    var dio = inDio.instance;
    expandedOrderLoading.value = true;
    update();
    try {
      var resp = await dio.post("/driver/order/$orderId/close");
      if (resp.statusCode == 200 && resp.data != null && resp.data['success'] == true) {
        Log.success("Заказ успешно закрыт");
        expandedOrderLoading.value = false;
        update();
        fetchMyOrders();
        fetchHistoryOrders();
        return null;
      }
      if (resp.data != null && resp.data['message'] != null) {
        expandedOrderLoading.value = false;
        update();
        return resp.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
      }
      Log.error("Ошибка оформления заказа : $e");
    } catch (e) {
      CoreToast.showToast("Ошибка запроса".tr);
      Log.error("Ошибка при получении деталей заказа: $e");
    } finally {
      expandedOrderLoading.value = false;
      update();
    }
    return null;
  }

  Future<String?> cancelOrderRequest(int orderId) async {
    var inDio = InDio();
    var dio = inDio.instance;
    expandedOrderLoading.value = true;
    update();
    try {
      var resp = await dio.post("/driver/order/$orderId/cancel");
      if (resp.statusCode == 200 && resp.data != null && resp.data['success'] == true) {
        Log.success("Заказ успешно отменен");
        expandedOrderLoading.value = false;
        update();
        fetchMyOrders();
        return null;
      }
      if (resp.data != null && resp.data['message'] != null) {
        expandedOrderLoading.value = false;
        update();
        return resp.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      } else {
        CoreToast.showToast("Ошибка запроса".tr);
      }
      Log.error("Ошибка оформления заказа : $e");
    } catch (e) {
      CoreToast.showToast("Ошибка запроса".tr);
      Log.error("Ошибка при получении деталей заказа: $e");
    } finally {
      expandedOrderLoading.value = false;
      update();
    }
    return null;
  }

  Future<void> fetchMyOrders() async {
    var inDio = InDio();
    var dio = inDio.instance;
    myOrdersLoading.value = true;
    update();
    try {
      var resp = await dio.get("/driver/my_orders");
      var newOrders = orderModelFromJson(json.encode(resp.data));
      myOrders.value = newOrders;
      Log.success("Получен список из ${myOrders.value.length} заказов");
    } catch (e) {
      Log.error("Ошибка при получении списка заказов: $e");
    }
    myOrdersLoading.value = false;
    update();
  }

  Future<void> fetchHistoryOrders() async {
    var inDio = InDio();
    var dio = inDio.instance;
    historyOrdersLoading.value = true;
    update();
    try {
      var resp = await dio.get("/driver/history_orders");
      var newOrders = orderModelFromJson(json.encode(resp.data));
      historyOrders.value = newOrders;
      Log.success("Получен список из ${myOrders.value.length} заказов");
    } catch (e) {
      Log.error("Ошибка при получении списка заказов: $e");
    }
    historyOrdersLoading.value = false;
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

  void resetController() {
    orders.value = [];
    ordersLoading.value = false;

    expandedOrders.value = [];
    expandedOrderLoading.value = false;

    myOrders.value = [];
    myOrdersLoading.value = false;

    historyOrders.value = [];
    historyOrdersLoading.value = false;

    selectedOrderOnMap.value = null;
    isRouteLoading.value = false;
    geoRoute.value = null;

    sortingValues = OrdersSortingValueModel.initialValues;
    selectedSortingValue.value = null;

    selectedOrderType.value = null;
  }
}
