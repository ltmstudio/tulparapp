import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/env.dart';
import 'package:tulpar/core/log.dart';

class InDio {
  late Dio _dio;

  InDio() {
    var headers = <String, String>{};
    if (Get.isRegistered<UserController>()) {
      var appController = Get.find<UserController>();
      if (appController.token.value != null) {
        headers['Authorization'] = "Bearer ${appController.token.value}";
      }
    }
    BaseOptions options = BaseOptions(
      baseUrl: "${CoreEnvironment.appUrl}/api", // Наш базовый URL
      connectTimeout: const Duration(seconds: 20), // Таймаут подключения
      receiveTimeout: const Duration(seconds: 20), // Таймаут ожидания ответа
      headers: {'Accept': 'application/json', ...headers},
    );

    _dio = Dio(options);
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(ConnectionInterceptor());
  }

  Dio get instance => _dio;
}

enum LoadingStatus { firstLoading, loading, empty, error, done }

class ConnectionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError) {
      Log.error("Проблема с интернетом! ${err.message}");
      // if (Get.isRegistered<AppController>()) {
      //   Get.find<AppController>()
      //     ..status.value = AppConnStatus.err
      //     ..update([AppController.statusKey]);
      // }
    }
    super.onError(err, handler);
  }
}
