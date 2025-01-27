import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/model/driver/available_shifts_response.dart';
import 'package:tulpar/model/driver/shift.dart';
import 'package:tulpar/model/driver/shift_order.dart';
import 'package:tulpar/model/driver/shift_order_response.dart';
import 'package:tulpar/model/driver/shift_status.dart';

class DriverShiftController extends GetxController {
  var shiftStatus = Rx<ShiftStatusModel?>(null);
  var shiftStatusLoading = Rx<bool>(false);

  var shiftOrders = Rx<List<ShiftOrderModel>>([]);
  var shiftOrdersLoading = Rx<bool>(false);
  var orderShiftLoading = Rx<bool>(false);

  var availableShifts = Rx<AvailableShiftsResponseModel?>(null);
  var availableShiftsLoading = Rx<bool>(false);
  var selectedShift = Rx<ShiftPriceModel?>(null);

  Timer? _shiftStatusTimer;
  Timer? _shiftStatusCountdownTimer;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<AppController>().appMode, (mode) {
      if (mode == AppMode.driver) {
        fetchShiftStatus();
        fetchShiftOrders();
      }
    });
    _startShiftStatusTimer();
    _startShiftStatusCountdownTimer();
  }

  @override
  void onClose() {
    _shiftStatusTimer?.cancel();
    _shiftStatusCountdownTimer?.cancel();
    super.onClose();
  }

  // Запуск таймера для получения статуса смены
  void _startShiftStatusTimer() {
    _shiftStatusTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      var userController = Get.find<UserController>();
      var appController = Get.find<AppController>();
      if (userController.user.value?.driverId != null &&
          appController.appMode.value == AppMode.driver &&
          shiftStatusLoading.value == false) {
        Log.info("[SHIFT_STATUS_TIMER] fetching...");
        await fetchShiftStatus();
      } else {
        Log.info("[SHIFT_STATUS_TIMER] skipped");
      }
    });
  }

  void _startShiftStatusCountdownTimer() {
    _shiftStatusCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (shiftStatus.value?.isActive == true) {
        shiftStatus.value?.decreaseLeftByOneSecond();
        update(['shift_timer']);
      }
    });
  }

  // Получение статуса смены
  Future<void> fetchShiftStatus() async {
    var inDio = InDio();
    var dio = inDio.instance;

    shiftStatusLoading.value = true;
    update();
    try {
      var resp = await dio.get("/driver/shift_status");
      var status = shiftStatusModelFromJson(json.encode(resp.data));
      shiftStatus.value = status;
      Log.success("Получен статус смены - ${shiftStatus.value?.isActive == true ? "активна" : "не активна"}");
    } catch (e) {
      shiftStatus.value = null;
      Log.error("Ошибка получения статуса смены - $e");
    } finally {
      shiftStatusLoading.value = false;
      update();
    }
  }

  // Получение списка доступных смен
  Future<void> fetchAvailableShifts() async {
    var inDio = InDio();
    var dio = inDio.instance;

    availableShifts.value = null;
    selectedShift.value = null;
    availableShiftsLoading.value = true;
    update();
    Get.find<DriverController>().fetchProfile();
    try {
      var resp = await dio.get("/driver/shifts");
      var shifts = availableShiftsResponseModelFromJson(json.encode(resp.data));
      availableShifts.value = shifts;
      Log.success("Получен список из ${availableShifts.value?.shifts?.length} доступных смен");
    } catch (e) {
      Log.error("Ошибка получения списка доступных смен - $e");
    } finally {
      availableShiftsLoading.value = false;
      update();
    }
  }

  // Покупка смены
  Future<void> orderShift() async {
    if (selectedShift.value?.id == null) {
      CoreToast.showToast("Веберите смену");
      Log.warning("Не выбрана смена для покупки");
      return;
    }

    var inDio = InDio();
    var dio = inDio.instance;

    orderShiftLoading.value = true;
    update();
    try {
      var resp = await dio.post("/driver/shifts/${selectedShift.value?.id}");
      if (resp.data != null && resp.data['success'] == true) {
        var shiftOrderResponse = shiftOrderResponseModelFromJson(json.encode(resp.data));
        if (shiftOrderResponse.message != null) {
          CoreToast.showToast(shiftOrderResponse.message!);
        }
        if (shiftOrderResponse.data != null) {
          shiftOrders.value.insert(0, shiftOrderResponse.data!);
        }
        Log.success("Смена успешно куплена");
        fetchAvailableShifts();
        fetchShiftStatus();
        Get.find<DriverController>().fetchProfile();
      } else {
        CoreToast.showToast("Ошибка покупки смены");
        Log.error("Ошибка заказа смены");
      }
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 402:
          if (e.response?.data != null && e.response?.data['message'] != null) {
            CoreToast.showToast(e.response?.data['message']);
          } else {
            CoreToast.showToast("Ошибка заказа смены - недостаточно средств");
          }
        case 403:
          if (e.response?.data != null && e.response?.data['message'] != null) {
            CoreToast.showToast(e.response?.data['message']);
          } else {
            CoreToast.showToast("Ошибка заказа смены - смена не доступна");
          }
          break;
        default:
          CoreToast.showToast("Ошибка заказа смены");
          Log.error("Ошибка заказа смены - $e");
      }
    } catch (e) {
      Log.error("Ошибка покупки смены - $e");
    } finally {
      orderShiftLoading.value = false;
      update();
    }
  }

  // Получение истории заказов смен
  Future<void> fetchShiftOrders() async {
    var inDio = InDio();
    var dio = inDio.instance;

    shiftOrdersLoading.value = true;
    update();
    try {
      var resp = await dio.get("/driver/shifts_orders");
      if (resp.data != null) {
        var orders = shiftOrderModelFromJson(json.encode(resp.data));
        shiftOrders.value = orders;
        Log.success("Получена история заказов смен");
      } else {
        Log.warning("История заказов смен пуста");
      }
    } catch (e) {
      Log.error("Ошибка получения истории заказов смен - $e");
    } finally {
      shiftOrdersLoading.value = false;
      update();
    }
  }
}
