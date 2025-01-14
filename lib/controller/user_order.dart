import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/event.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/model/geo/route.dart';
import 'package:tulpar/model/order/car_class.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/model/order/type.dart';
import 'package:tulpar/model/user/address.dart';

class UserOrderController extends GetxController {
  @override
  void onInit() {
    ever(poinA, (a) {
      if (a?.latLng != null && pointB.value?.latLng != null) {
        fetchRoute();
      } else {
        geoRoute.value = null;
        update();
      }
    });
    ever(pointB, (b) {
      if (b?.latLng != null && poinA.value?.latLng != null) {
        fetchRoute();
      } else {
        geoRoute.value = null;
        update();
      }
    });
    super.onInit();
  }

  ///Стримы на экраны
  final StreamController<StreamWidgetEvent> _widgetsStreamController = StreamController<StreamWidgetEvent>.broadcast();
  Stream<StreamWidgetEvent> get widgetStream => _widgetsStreamController.stream;

  var orderTypes = Rx<List<OrderTypeModel>>([]);
  var carClasses = Rx<List<CarClassModel>>([]);

  // Заказы с пагинацией
  var orders = Rx<List<OrderModel>>([]);
  var ordersLoading = Rx<bool>(false);
  var isOrdersEnd = Rx<bool>(false);
  var orderCreateLoading = Rx<bool>(false);
  // var orderStatusGroup = Rx<OrderStatusGroupModel?>(null);

  // Геокод
  var currentGeocode = Rx<String?>(null);
  var currentGeocodePosition = Rx<LatLng?>(null);
  var isGeocodeLoading = Rx<bool>(false);
  var onGeocodeDone = Rx<Function(AddressModel)?>(null);

  // Режимы карты
  var followLocation = Rx<bool>(true);
  var locSelector = Rx<bool>(false);
  var locSelectorTitle = Rx<String?>(null);
  var isRouteLoading = Rx<bool>(false);

  void showLocSelector({required Function(AddressModel) onDone, String? title}) {
    followLocation.value = false;
    currentGeocode.value = null;
    newOrderExpanded.value = false;
    locSelector.value = true;
    locSelectorTitle.value = title;
    onGeocodeDone.value = onDone;
    update();
  }

  void hideLocSelector() {
    currentGeocode.value = null;
    followLocation.value = true;
    newOrderExpanded.value = true;
    locSelector.value = false;
    locSelectorTitle.value = null;
    onGeocodeDone.value = null;
    update();
  }

  void setPointA(AddressModel? address) {
    poinA.value = address;
    update();
  }

  void setPointB(AddressModel? address) {
    pointB.value = address;
    update();
  }

  void clearPointA() {
    poinA.value = null;
    update();
  }

  void clearPointB() {
    pointB.value = null;
    update();
  }

  Future<void> fetchGeocode(LatLng latlng) async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      isGeocodeLoading.value = true;
      currentGeocode.value = null;
      currentGeocodePosition.value = null;
      update();

      var resp = await dio.post('/customer/geo/geocode', data: {
        "latitude": latlng.latitude,
        "longitude": latlng.longitude,
        "lang": Get.locale?.countryCode?.toLowerCase() ?? 'ru'
      });
      if (resp.statusCode == 200 && resp.data['address'] != null) {
        currentGeocode.value = resp.data['address'];
        currentGeocodePosition.value = latlng;
        update();
        Log.success("Получен геокод");
      } else {
        Log.error("Ошибка получения геокода");
      }
    } on DioException catch (e) {
      Log.error("Ошибка получения геокода $e");
    } catch (e) {
      Log.error("Ошибка получения геокода $e");
    }
    isGeocodeLoading.value = false;
    update();
  }

  Future<void> fetchRoute() async {
    if (poinA.value?.latLng == null || pointB.value?.latLng == null) {
      Log.warning("Не выбраны точки для построения маршрута");
      return;
    }
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      isRouteLoading.value = true;
      update();

      var resp = await dio.post('/customer/geo/route', data: {
        "start_latitude": poinA.value!.latLng!.latitude,
        "start_longitude": poinA.value!.latLng!.longitude,
        "end_latitude": pointB.value!.latLng!.latitude,
        "end_longitude": pointB.value!.latLng!.longitude,
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

  Future<void> fetchCarClasses() async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      var resp = await dio.get('/catalog/car_classes');
      var newClasses = carClassModelFromJson(json.encode(resp.data));
      carClasses.value = newClasses;
      Log.success("Получен список из ${newClasses.length} классов авто");
      update();
    } catch (e) {
      Log.error("Ошибка получения списка классов авто $e");
    }
  }

  // Форма заказа
  var newOrderExpanded = Rx<bool>(true);
  var selectedCarClassId = Rx<int?>(null);
  var poinA = Rx<AddressModel?>(null);
  var pointB = Rx<AddressModel?>(null);
  var geoRoute = Rx<GeoRouteModel?>(null);

  void selectCarClass(int? id) {
    selectedCarClassId.value = id;
    update();
  }

  // создание заказа
  Future<void> createOrder(OrderModel order) async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      orderCreateLoading.value = true;
      update();
      var resp = await dio.post('/orders', data: order.toCreateForm());
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        Log.success("Заказ успешно создан");
        CoreToast.showToast('Заказ успешно создан'.tr);
        fetchOrders(refresh: true);
        newOrderExpanded.value = false;
        clearAllSelectedForm();
        update();
      } else {
        Log.error("Ошибка создания заказа: ${resp.statusMessage}");
      }
    } on DioException catch (e) {
      Log.error("Ошибка создания заказа $e");
    } catch (e) {
      Log.error("Ошибка создания заказа $e");
    }
    orderCreateLoading.value = false;
    update();
  }

  void clearAllSelectedForm() {
    poinA.value = null;
    pointB.value = null;
    selectedCarClassId.value = null;
    _widgetsStreamController.sink.add(StreamWidgetEvent(id: 'flush', type: WidgetEvent.flushStartForm));
    update();
  }

  // получение списка заказов
  Future<void> fetchOrders({bool refresh = false}) async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      if (refresh) isOrdersEnd.value = false;
      ordersLoading.value = true;
      update();
      var resp = await dio.get('/orders', queryParameters: {"offset": refresh ? 0 : orders.value.length});
      var data = orderModelFromJson(json.encode(resp.data));
      if (refresh) {
        orders.value = data;
      } else {
        orders.value = [...orders.value, ...data];
      }
      if (data.length < 15) isOrdersEnd.value = true;
      update();
      Log.success("Получен список из ${data.length} заказов");
    } on DioException catch (e) {
      Log.error("Ошибка получения списка заказов $e");
    } catch (e) {
      Log.error("Ошибка получения списка заказов $e");
    }
    ordersLoading.value = false;
    update();
  }

  // кеш
  late Directory cachePath;

  Future<void> initCachePath() async {
    cachePath = await getTemporaryDirectory();
    Log.success('Путь кеширования инициализирован - ${cachePath.path}');
  }
}
