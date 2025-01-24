import 'dart:convert';

import 'package:get/get.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/model/pay/info.dart';

class PayController extends GetxController {
  var payInfo = Rx<PayInfoModel?>(null);
  var payInfoLoading = Rx<bool>(false);

  Future<void> fetchPayInfo() async {
    var inDio = InDio();
    var dio = inDio.instance;
    payInfoLoading.value = true;
    update();

    try {
      var response = await dio.get('/pay/info');
      payInfo.value = payInfoModelFromJson(json.encode(response.data));
      Log.info('Получена информация о платеже');
    } catch (e) {
      CoreToast.showToast("Ошибка запроса");
      Log.error("Ощибка получения информации о платеже: $e");
    } finally {
      payInfoLoading.value = false;
      update();
    }
  }
}
