import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tulpar/controller/address.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/controller/driver_shift.dart';
import 'package:tulpar/controller/pay.dart';
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
        orderController.fetchCarClasses();
        orderController.fetchOrderTypes();
        orderController.fetchCities();
        if (Get.find<AppController>().appMode.value == AppMode.driver && u.driverId != null) {
          Get.find<DriverController>().fetchProfile();
          Get.find<DriverModerationController>().fetchModeration();
          Get.find<AddressController>().fetchAddresses();
        }
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
      Log.warning("Токен с кеша не найден!");
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
      if (response.success == true && response.data?.token != null && response.data?.profile != null) {
        _handleSuccessfulAuth(response.data!.token!, response.data!.profile!, response.message);
        Log.success('Авторизация успешна');
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
  var googleSignInLoading = Rx<bool>(false);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  void clearForm() {
    phone.value = null;
    salt.value = null;
  }

  void _handleSuccessfulAuth(String token, UserModel profile, String? message) {
    this.token.value = token;
    user.value = profile;
    userStage.value = UserLoginStage.done;
    clearForm();
    if (message != null) {
      CoreToast.showToast(message);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      googleSignInLoading.value = true;
      update();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        Log.warning('Google Sign In отменен пользователем');
        googleSignInLoading.value = false;
        update();
        return;
      }
      
      final String? googleId = googleUser.id;
      final String? name = googleUser.displayName ?? 'User';
      final String? email = googleUser.email;

      if (googleId == null) {
        CoreToast.showToast('Ошибка получения данных Google'.tr);
        Log.error('Google ID не получен');
        googleSignInLoading.value = false;
        update();
        return;
      }

      var inDio = InDio();
      var dio = inDio.instance;

      var resp = await dio.post('/register/google', data: {
        "name": name,
        "email": email,
        "google_id": googleId,
        "auth_type": "google"
      });

      var response = smsResponseModelFromJson(json.encode(resp.data));
      
      if (response.success == true && response.data?.token != null && response.data?.profile != null) {
        _handleSuccessfulAuth(
          response.data!.token!, 
          response.data!.profile!, 
          response.message ?? 'Успешная авторизация через Google'.tr
        );
        Log.success('Авторизация через Google успешна');
      } else {
        CoreToast.showToast('Ошибка авторизации через Google'.tr);
        Log.error('Ошибка авторизации через Google - неверный ответ сервера');
      }
    } catch (e) {
      Log.error('Ошибка авторизации через Google: $e');
      CoreToast.showToast('Ошибка авторизации через Google'.tr);
      await _googleSignIn.signOut();
    } finally {
      googleSignInLoading.value = false;
      update();
    }
  }

  void logout() async {
    await prefs?.remove(CoreCacheKeys.token);
    token.value = null;
    user.value = null;
    userStage.value = UserLoginStage.phone;
    await _googleSignIn.signOut();
    update();
    Get.find<AppController>().resetController();
    Get.find<AddressController>().resetController();
    Get.find<DriverController>().resetController();
    Get.find<DriverOrderController>().resetController();
    Get.find<DriverShiftController>().resetController();
    Get.find<DriverModerationController>().resetController();
    Get.find<PayController>().resetController();
    Get.find<UserOrderController>().resetController();
  }
}
