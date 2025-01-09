import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/model/app/locale.dart';
import 'package:tulpar/model/app/status.dart';

SharedPreferences? prefs;

enum AppConnectionStatus { loading, done, error }

class AppController extends GetxController {
  var appStatus = Rx<AppConnectionStatus>(AppConnectionStatus.loading);

  @override
  void onInit() {
    initLocale();
    super.onInit();
  }

  @override
  void onReady() {
    initAppstatus();
    super.onReady();
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    appStatus.value = AppConnectionStatus.done;
  }

  // App

  Future<void> initAppstatus({bool onlySettings = false}) async {
    if (appStatus.value != AppConnectionStatus.loading && !onlySettings) {
      appStatus.value = AppConnectionStatus.loading;
      update();
    }

    var inDio = InDio();
    var dio = inDio.instance;
    try {
      var resp = await dio.get('/app', queryParameters: {"platform": Platform.isAndroid ? 'android' : 'ios'});
      var appStatusResponse = appStatusModelFromJson(json.encode(resp.data));
      if (appStatusResponse.success == true) {
        Log.success('Успешно подключено');
        appStatus.value = AppConnectionStatus.done;
      } else {
        Log.error("Ошибка подключения");
        appStatus.value = AppConnectionStatus.error;
      }
    } catch (_) {
      Log.error('Ошибка подключения $_');
      appStatus.value = AppConnectionStatus.error;
    }
    update();
  }

  static Future<void> loadAppData() async {
    // TODO load app data
    return;
  }

  // Locale
  var locale = Rx<Locale>(const Locale('ru', 'RU'));

  static List<AppLocaleModel> supportedLocales = [
    AppLocaleModel(id: 1, locale: const Locale('kk', 'KZ'), title: 'Қазақша'),
    AppLocaleModel(id: 2, locale: const Locale('ru', 'RU'), title: 'Русский')
  ];

  Future<void> initLocale() async {
    var cachedLocale = prefs?.getString('locale');
    if (cachedLocale != null) {
      locale.value = Locale(cachedLocale);
      Get.updateLocale(locale.value);
      Log.success('Locale loaded from cache: $cachedLocale');
      update();
    } else {}
  }

  int get getLangIdByCurrentLocale {
    var currentLocale = locale.value;
    var matchedLocale = supportedLocales.firstWhere(
      (localeModel) => localeModel.locale.languageCode == currentLocale.languageCode,
      orElse: () => supportedLocales.first,
    );
    return matchedLocale.id;
  }

  void switchLocale(Locale newLocale) async {
    await prefs?.setString('locale', newLocale.languageCode);
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    Log.success('Locale switched to ${newLocale.languageCode}');
  }
}
