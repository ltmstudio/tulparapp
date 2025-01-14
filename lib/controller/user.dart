import 'dart:convert';

import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/keys.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/model/auth/phone_response.dart';
import 'package:tulpar/model/auth/sms_response.dart';
import 'package:tulpar/model/auth/user.dart';
import 'package:tulpar/model/auth/user_response.dart';

enum UserLoginStage { phone, sms, done }

class UserController extends GetxController {
  var userStage = Rx<UserLoginStage>(UserLoginStage.phone);

  var user = Rx<UserModel?>(null);
  var userLoading = Rx<bool>(false);
  var token = Rx<String?>(null);

  @override
  void onInit() {
    ever(token, (t) {
      if (t != null) {
        prefs?.setString(CoreCacheKeys.token, t);
        Log.success("Вроде работает");
        fetchUser();
      } else {
        user.value = null;
        update();
      }
    });
    ever(user, (u) {
      var orderController = Get.find<UserOrderController>();
      if (u != null) {
        orderController.fetchOrders(refresh: true);
      } else {
        orderController
          ..orders.value = []
          ..update();
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    initCacheToken();
    super.onReady();
  }

  void initCacheToken() async {
    var cacheToken = prefs?.getString(CoreCacheKeys.token);
    if (cacheToken != null) {
      Log.success("Найден токен с кеша");
      token.value = cacheToken;
      update();
      fetchUser();
    } else {
      Log.warning("Токен с кеше не найден!");
    }
  }

  Future<void> fetchUser() async {
    var t = token.value;
    t ??= prefs?.getString(CoreCacheKeys.token);
    if (t == null) {
      CoreToast.showToast("Ошибка получения профиля пользователя".tr);
      Log.error("Ошибка получения профиля пользователя - токен не найден");
      user.value = null;
      userStage.value = UserLoginStage.phone;
      update();
      return;
    }
    var inDio = InDio();
    var dio = inDio.instance;
    userLoading.value = true;
    update();
    try {
      var resp = await dio.get('/user');
      var response = userResponseModelFromJson(json.encode(resp.data));
      if (response.success == true && response.data?.id != null) {
        user.value = response.data;
        userStage.value = UserLoginStage.done;
        update();
      } else {
        CoreToast.showToast("Ошибка получения профиля пользователя".tr);
        Log.error("Ошибка получения профиля пользователя");
      }
    } catch (e) {
      CoreToast.showToast("Ошибка получения профиля пользователя".tr);
      Log.error("Ошибка получения профиля пользователя - $e");
    } finally {
      userLoading.value = false;
      update();
    }
  }

  Future<void> phoneToSms(String? phoneNumber) async {
    phoneNumber ??= phone.value;

    if (phoneNumber == null) {
      CoreToast.showToast('Введите номер телефона'.tr);
      return;
    }
    var inDio = InDio();
    var dio = inDio.instance;
    phoneToSmsLoading.value = true;
    update();
    try {
      var resp = await dio.post('/auth/phone_to_sms', data: {"phone": phoneNumber});
      var response = phoneResponseModelFromJson(json.encode(resp.data));
      if (response.success == true && response.data?.sms != null) {
        phone.value = phoneNumber;
        salt.value = response.data!.salt;
        userStage.value = UserLoginStage.sms;
        if (response.message != null) {
          CoreToast.showToast(response.message!);
        }
        Log.success('SMS отправлено'.tr);
      }
    } catch (e) {
      Log.error('Ошибка отправки SMS $e');
      CoreToast.showToast('Ошибка отправки SMS'.tr);
    } finally {
      phoneToSmsLoading.value = false;
      update();
    }
  }

  Future<void> login(String? codeNumber) async {
    if (codeNumber == null) {
      CoreToast.showToast('Введите код'.tr);
      return;
    }
    var inDio = InDio();
    var dio = inDio.instance;
    smsToTokenLoading.value = true;
    update();
    try {
      var resp = await dio.post('/auth/login', data: {"phone": phone.value, "sms": codeNumber, "salt": salt.value});
      var response = smsResponseModelFromJson(json.encode(resp.data));
      if (response.success == true && response.data?.token != null) {
        token.value = response.data!.token;
        user.value = response.data!.profile;
        userStage.value = UserLoginStage.done;
        clearForm();
        if (response.message != null) {
          CoreToast.showToast(response.message!);
        }
        Log.success('SMS отправлено');
      }
    } catch (e) {
      Log.error('Ошибка подтверждения $e');
      CoreToast.showToast('Ошибка подтверждения'.tr);
    } finally {
      smsToTokenLoading.value = false;
      update();
    }
  }

  // Login Form
  var phone = Rx<String?>(null);
  var salt = Rx<String?>(null);
  var phoneToSmsLoading = Rx<bool>(false);
  var smsToTokenLoading = Rx<bool>(false);

  void clearForm() {
    phone.value = null;
    salt.value = null;
  }
}
