import 'dart:async';

import 'package:dio/dio.dart';

class MockApiInterceptor extends Interceptor {
  MockApiInterceptor();

  static const Duration _latency = Duration(milliseconds: 450);

  static final DateTime _now = DateTime.now();
  static final Map<String, dynamic> _user = {
    'id': 1,
    'name': 'Test User',
    'email': 'test.user@mock.local',
    'phone': '7012345678',
    'role': 'DRV',
    'driver_id': 10,
    'status': 1,
    'email_verified_at': null,
    'created_at': _now.subtract(const Duration(days: 30)).toIso8601String(),
    'updated_at': _now.toIso8601String(),
  };

  static final List<Map<String, dynamic>> _cities = [
    {'id': 1, 'name': 'Almaty'},
    {'id': 2, 'name': 'Astana'},
    {'id': 3, 'name': 'Shymkent'},
  ];

  static final List<Map<String, dynamic>> _orderTypes = [
    {'id': 1, 'name': 'Стандарт'},
    {'id': 2, 'name': 'Межгород'},
  ];

  static final List<Map<String, dynamic>> _carClasses = [
    {
      'id': 1,
      'name': 'Эконом',
      'image': null,
      'cost': 1200,
      'priority': 1,
      'created_at': _now.toIso8601String(),
      'updated_at': _now.toIso8601String(),
    },
    {
      'id': 2,
      'name': 'Комфорт',
      'image': null,
      'cost': 1800,
      'priority': 2,
      'created_at': _now.toIso8601String(),
      'updated_at': _now.toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _catalogCars = [
    {
      'id': 'toyota',
      'name': 'Toyota',
      'cyrillic-name': 'Тойота',
      'popular': 1,
      'country': 'JP',
      'image': 'cars/toyota.png',
      'models': [
        {
          'id': 'camry',
          'car_id': 'toyota',
          'name': 'Camry',
          'cyrillic-name': 'Камри',
          'year-from': 2015,
          'year-to': 2024,
          'class': 'D',
        }
      ],
    },
    {
      'id': 'hyundai',
      'name': 'Hyundai',
      'cyrillic-name': 'Хундай',
      'popular': 1,
      'country': 'KR',
      'image': 'cars/hyundai.png',
      'models': [
        {
          'id': 'sonata',
          'car_id': 'hyundai',
          'name': 'Sonata',
          'cyrillic-name': 'Соната',
          'year-from': 2016,
          'year-to': 2024,
          'class': 'D',
        }
      ],
    },
  ];

  static final List<Map<String, dynamic>> _addresses = [
    {'id': 1, 'user_id': 1, 'address': 'Abay Ave 10', 'geo': '43.2389,76.8897'},
    {
      'id': 2,
      'user_id': 1,
      'address': 'Satpayev St 22',
      'geo': '43.2565,76.9285'
    },
  ];

  static final List<Map<String, dynamic>> _orders = List.generate(18, (index) {
    final id = index + 1;
    final classData = _carClasses[index % _carClasses.length];
    final cityA = _cities[0];
    final cityB = _cities[1];
    return {
      'id': id,
      'phone': '7012345678',
      'type_id': 1,
      'class_id': classData['id'],
      'user_id': 1,
      'driver_id': index < 3 ? 10 : null,
      'user_cost': 2000 + (index * 100),
      'user_time':
          DateTime.now().add(Duration(minutes: 15 + id)).toIso8601String(),
      'people': 2,
      'user_comment': 'Mock order #$id',
      'driver_comment': null,
      'point_a': 'Point A $id',
      'point_b': 'Point B $id',
      'geo_a': '43.2389,76.8897',
      'geo_b': '43.2220,76.8512',
      'city_a_id': cityA['id'],
      'city_b_id': cityB['id'],
      'city_a': cityA,
      'city_b': cityB,
      'is_delivery': false,
      'is_cargo': false,
      'class': classData,
      'status': index < 3 ? 'accepted' : 'new',
      'driver': index < 3 ? _driverProfileData() : null,
      'created_at':
          DateTime.now().subtract(Duration(minutes: id * 6)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  });

  static final Map<String, dynamic> _moderation = {
    'id': 1,
    'user_id': 1,
    'name': 'Test',
    'lastname': 'Driver',
    'birthdate': '1995-04-15',
    'car_id': 'toyota',
    'car_model_id': 'camry',
    'car_vin': 'JT2BG22K8V0123456',
    'car_year': 2019,
    'car_gos_number': '777AAA02',
    'car_image_1': null,
    'car_image_2': null,
    'car_image_3': null,
    'car_image_4': null,
    'driver_license_number': 'DL-555001',
    'driver_license_front': null,
    'driver_license_back': null,
    'driver_license_date': '2018-05-20',
    'ts_passport_front': null,
    'ts_passport_back': null,
    'status': 'preparation',
    'reject_message': null,
    'created_at': _now.subtract(const Duration(days: 7)).toIso8601String(),
    'updated_at': _now.toIso8601String(),
  };

  static final List<Map<String, dynamic>> _shiftOrders = [];
  static int? _activeShiftEndsAtMs;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(_latency);

    final method = options.method.toUpperCase();
    final path = options.path;
    final segments = path.split('/').where((e) => e.isNotEmpty).toList();

    if (method == 'GET' && path == '/app') {
      return _ok(handler, options, {
        'success': true,
        'appVersion': '1.0.0-mock',
        'cities': _cities,
        'orderTypes': _orderTypes,
        'carClasses': _carClasses,
      });
    }
    if (method == 'POST' && path == '/auth/phone_to_sms') {
      return _ok(handler, options, {
        'success': true,
        'message': 'SMS mock code: 1111',
        'data': {'salt': 'mock-salt', 'sms': 1111},
      });
    }
    if (method == 'POST' &&
        (path == '/auth/login' ||
            path == '/auth/google/mobile' ||
            path == '/auth/apple/mobile')) {
      return _ok(handler, options, {
        'success': true,
        'message': 'Успешная mock авторизация',
        'data': {'token': 'mock-token-123', 'profile': _user},
      });
    }
    if (method == 'GET' && path == '/user') {
      return _ok(handler, options, {
        'success': true,
        'message': 'OK',
        'data': _user,
      });
    }

    if (method == 'GET' && path == '/catalog/car_classes') {
      return _ok(handler, options, _carClasses);
    }
    if (method == 'GET' && path == '/app/cities') {
      return _ok(handler, options, _cities);
    }
    if (method == 'GET' && path == '/app/order-types') {
      return _ok(handler, options, _orderTypes);
    }

    if (method == 'POST' && path == '/customer/geo/geocode') {
      return _ok(handler, options, {'address': 'Mock Address, Almaty'});
    }
    if (method == 'POST' && path == '/customer/geo/route') {
      return _ok(handler, options, _mockRoute());
    }

    if (method == 'GET' && path == '/orders') {
      final offset = int.tryParse(
            options.queryParameters['offset']?.toString() ?? '0',
          ) ??
          0;
      final sliced = offset >= _orders.length
          ? <Map<String, dynamic>>[]
          : _orders.skip(offset).take(15).toList();
      return _ok(handler, options, sliced);
    }
    if (method == 'POST' && path == '/orders') {
      final body = (options.data as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final newId = (_orders.isEmpty ? 0 : (_orders.first['id'] as int)) + 1;
      final classId = int.tryParse(body['class_id']?.toString() ?? '') ?? 1;
      final classData = _carClasses.firstWhere(
        (e) => e['id'] == classId,
        orElse: () => _carClasses.first,
      );
      _orders.insert(0, {
        'id': newId,
        'phone': _user['phone'],
        'type_id': int.tryParse(body['type_id']?.toString() ?? '') ?? 1,
        'class_id': classId,
        'user_id': _user['id'],
        'driver_id': null,
        'user_cost': int.tryParse(body['user_cost']?.toString() ?? '') ?? 2500,
        'user_time':
            body['user_time']?.toString() ?? DateTime.now().toIso8601String(),
        'people': int.tryParse(body['people']?.toString() ?? '') ?? 1,
        'user_comment': body['user_comment']?.toString(),
        'driver_comment': null,
        'point_a': body['point_a']?.toString() ?? 'Point A',
        'point_b': body['point_b']?.toString() ?? 'Point B',
        'geo_a': body['geo_a']?.toString() ?? '43.2389,76.8897',
        'geo_b': body['geo_b']?.toString() ?? '43.2220,76.8512',
        'city_a_id': int.tryParse(body['city_a_id']?.toString() ?? '') ?? 1,
        'city_b_id': int.tryParse(body['city_b_id']?.toString() ?? '') ?? 2,
        'city_a': _cities.first,
        'city_b': _cities[1],
        'is_delivery': body['is_delivery'] ?? false,
        'is_cargo': body['is_cargo'] ?? false,
        'class': classData,
        'status': 'new',
        'driver': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return _ok(handler, options, {'success': true}, statusCode: 201);
    }
    if (method == 'DELETE' &&
        segments.length == 2 &&
        segments.first == 'orders') {
      final orderId = int.tryParse(segments[1]);
      _orders.removeWhere((e) => e['id'] == orderId);
      return _ok(handler, options, {'success': true});
    }

    if (method == 'GET' && path == '/pay/info') {
      return _ok(handler, options, {
        'pay_link': 'https://example.com/mock-pay',
        'pay_qr_image': null,
        'pay_qr_phone': '+7 777 000 00 00',
      });
    }

    if (method == 'GET' && path == '/user/address/all') {
      return _ok(handler, options, _addresses);
    }
    if (method == 'POST' && path == '/user/address/add') {
      final body = (options.data as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final newId = (_addresses.isEmpty ? 0 : _addresses.last['id'] as int) + 1;
      _addresses.add({
        'id': newId,
        'user_id': _user['id'],
        'address': body['address']?.toString() ?? 'Mock address',
        'geo': body['geo']?.toString() ?? '43.2389,76.8897',
      });
      return _ok(handler, options, _addresses);
    }
    if (method == 'DELETE' &&
        segments.length == 4 &&
        segments[0] == 'user' &&
        segments[1] == 'address' &&
        segments[2] == 'delete') {
      final addressId = int.tryParse(segments[3]);
      _addresses.removeWhere((e) => e['id'] == addressId);
      return _ok(handler, options, _addresses);
    }

    if (method == 'GET' && path == '/driver/profile') {
      return _ok(
          handler, options, {'success': true, 'data': _driverProfileData()});
    }
    if (method == 'POST' && path == '/driver/avatar') {
      return _ok(handler, options, {'image_path': null});
    }
    if (method == 'DELETE' && path == '/driver/avatar') {
      return _ok(handler, options, {'success': true});
    }

    if (method == 'GET' &&
        (path == '/catalog/cars' || path == '/catalog/cars/all')) {
      return _ok(handler, options, _catalogCars);
    }
    if (method == 'GET' &&
        segments.length == 3 &&
        segments[0] == 'catalog' &&
        segments[1] == 'cars') {
      final carId = segments[2];
      final car = _catalogCars.firstWhere(
        (e) => e['id'] == carId,
        orElse: () => _catalogCars.first,
      );
      return _ok(handler, options, car);
    }
    if (method == 'GET' && path == '/catalog/search') {
      final search =
          options.queryParameters['search']?.toString().toLowerCase() ?? '';
      final filtered = _catalogCars.where((e) {
        final name = (e['name']?.toString().toLowerCase() ?? '');
        final cyr = (e['cyrillic-name']?.toString().toLowerCase() ?? '');
        return search.isEmpty || name.contains(search) || cyr.contains(search);
      }).toList();
      return _ok(handler, options, filtered);
    }

    if (method == 'GET' && path == '/driver/moderation') {
      return _ok(handler, options, _moderation);
    }
    if (method == 'POST' && path == '/driver/moderation') {
      final body = (options.data as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      body.forEach((k, v) {
        _moderation[k] = v;
      });
      _moderation['updated_at'] = DateTime.now().toIso8601String();
      return _ok(handler, options, _moderation);
    }
    if (method == 'POST' && path == '/driver/moderation/set') {
      _moderation['status'] = 'moderation';
      _moderation['updated_at'] = DateTime.now().toIso8601String();
      return _ok(
          handler, options, {'message': 'Анкета отправлена на модерацию'});
    }
    if (method == 'POST' && path == '/driver/moderation/upload_image') {
      final fieldKey = _extractFieldKey(options.data) ?? 'car_image_1';
      _moderation[fieldKey] = null;
      _moderation['updated_at'] = DateTime.now().toIso8601String();
      return _ok(handler, options, {'image_path': null});
    }
    if (method == 'POST' && path == '/driver/moderation/delete_image') {
      final body = (options.data as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final fieldKey = body['field_key']?.toString();
      if (fieldKey != null) {
        _moderation[fieldKey] = null;
      }
      _moderation['updated_at'] = DateTime.now().toIso8601String();
      return _ok(handler, options, {'success': true});
    }

    if (method == 'GET' && path == '/driver/orders') {
      final available = _orders.where((e) => e['status'] == 'new').toList();
      return _ok(handler, options, available);
    }
    if (method == 'GET' &&
        segments.length == 3 &&
        segments[0] == 'driver' &&
        segments[1] == 'orders') {
      final orderId = int.tryParse(segments[2]);
      final order = _orders.firstWhere(
        (e) => e['id'] == orderId,
        orElse: () => <String, dynamic>{},
      );
      if (order.isEmpty) {
        return _rejectNotFound(handler, options, 'Order not found');
      }
      return _ok(handler, options, order);
    }
    if (method == 'POST' &&
        segments.length == 3 &&
        segments[0] == 'driver' &&
        segments[1] == 'orders') {
      final orderId = int.tryParse(segments[2]);
      final index = _orders.indexWhere((e) => e['id'] == orderId);
      if (index == -1) {
        return _rejectNotFound(handler, options, 'Order not found');
      }
      _orders[index]['driver_id'] = 10;
      _orders[index]['driver'] = _driverProfileData();
      _orders[index]['status'] = 'accepted';
      _orders[index]['updated_at'] = DateTime.now().toIso8601String();
      return _ok(
          handler, options, {'success': true, 'message': 'Order accepted'});
    }
    if (method == 'POST' &&
        segments.length == 4 &&
        segments[0] == 'driver' &&
        segments[1] == 'order') {
      final orderId = int.tryParse(segments[2]);
      final action = segments[3];
      final index = _orders.indexWhere((e) => e['id'] == orderId);
      if (index == -1) {
        return _rejectNotFound(handler, options, 'Order not found');
      }
      if (action == 'close') {
        _orders[index]['status'] = 'closed';
      } else if (action == 'cancel') {
        _orders[index]['status'] = 'cancelled';
      }
      _orders[index]['updated_at'] = DateTime.now().toIso8601String();
      return _ok(handler, options, {'success': true, 'message': 'OK'});
    }
    if (method == 'GET' && path == '/driver/my_orders') {
      final my = _orders
          .where((e) => e['driver_id'] == 10 && e['status'] == 'accepted')
          .toList();
      return _ok(handler, options, my);
    }
    if (method == 'GET' && path == '/driver/history_orders') {
      final history = _orders
          .where((e) => e['driver_id'] == 10 && e['status'] != 'accepted')
          .toList();
      return _ok(handler, options, history);
    }

    if (method == 'GET' && path == '/driver/shift_status') {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final max = _activeShiftEndsAtMs;
      final diffSec =
          max != null ? ((max - nowMs) ~/ 1000).clamp(0, 999999) : 0;
      return _ok(handler, options, {
        'now': nowMs,
        'max': max,
        'diff_sec': diffSec,
      });
    }
    if (method == 'GET' && path == '/driver/shifts') {
      return _ok(handler, options, {
        'shifts': [
          {
            'id': 1,
            'tx_shift_id': 1,
            'tx_level_id': 1,
            'tx_car_class_id': 1,
            'price': 2500,
            'created_at': _now.toIso8601String(),
            'updated_at': _now.toIso8601String(),
            'shift': {'id': 1, 'hours': 12, 'state': 'часов'}
          },
          {
            'id': 2,
            'tx_shift_id': 2,
            'tx_level_id': 1,
            'tx_car_class_id': 1,
            'price': 1500,
            'created_at': _now.toIso8601String(),
            'updated_at': _now.toIso8601String(),
            'shift': {'id': 2, 'hours': 6, 'state': 'часов'}
          }
        ],
        'level': {
          'id': 1,
          'name': 'Bronze',
          'count': 0,
          'color': 'F59E0B',
          'created_at': _now.toIso8601String(),
          'updated_at': _now.toIso8601String(),
        },
        'class_id': 1,
      });
    }
    if (method == 'POST' &&
        segments.length == 3 &&
        segments[0] == 'driver' &&
        segments[1] == 'shifts') {
      _activeShiftEndsAtMs =
          DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch;
      final order = {
        'id': _shiftOrders.length + 1,
        'driver_id': 10,
        'class_id': 1,
        'hours': 6,
        'hours_state': 'часов',
        'level_name': 'Bronze',
        'price': 1500,
        'endtime': _activeShiftEndsAtMs,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      _shiftOrders.insert(0, order);
      return _ok(handler, options, {
        'success': true,
        'message': 'Смена успешно куплена',
        'data': order,
      });
    }
    if (method == 'GET' && path == '/driver/shifts_orders') {
      return _ok(handler, options, _shiftOrders);
    }

    return _rejectNotFound(handler, options, 'No mock route for $method $path');
  }

  void _ok(
    RequestInterceptorHandler handler,
    RequestOptions options,
    dynamic data, {
    int statusCode = 200,
  }) {
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  void _rejectNotFound(
    RequestInterceptorHandler handler,
    RequestOptions options,
    String message,
  ) {
    handler.reject(
      DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 404,
          data: {'message': message},
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }

  static String? _extractFieldKey(dynamic data) {
    if (data is FormData) {
      for (final field in data.fields) {
        if (field.key == 'field_key') {
          return field.value;
        }
      }
    }
    return null;
  }

  static Map<String, dynamic> _mockRoute() {
    return {
      'route': {
        'geometry': {
          'coordinates': [
            [76.8897, 43.2389],
            [76.8740, 43.2320],
            [76.8512, 43.2220]
          ],
          'type': 'LineString',
        },
        'legs': [
          {
            'steps': [],
            'summary': 'Mock route',
            'weight': 1300.0,
            'duration': 960.0,
            'distance': 7800.0,
          }
        ],
        'weight_name': 'routability',
        'weight': 1300.0,
        'duration': 960.0,
        'distance': 7800.0,
      }
    };
  }

  static Map<String, dynamic> _driverProfileData() {
    return {
      'id': 10,
      'phone': _user['phone'],
      'name': 'Test',
      'lastname': 'Driver',
      'avatar': null,
      'car_name': 'Toyota Camry',
      'car_number': '777AAA02',
      'people': 4,
      'class_id': 2,
      'delivery': 1,
      'cargo': 0,
      'balance': 15000,
      'status': 1,
      'car_image_1': null,
      'car_image_2': null,
      'car_image_3': null,
      'car_image_4': null,
      'class': _carClasses[1],
      'level': {
        'id': 1,
        'name': 'Bronze',
        'count': 0,
        'color': 'F59E0B',
        'created_at': _now.toIso8601String(),
        'updated_at': _now.toIso8601String(),
      }
    };
  }
}
