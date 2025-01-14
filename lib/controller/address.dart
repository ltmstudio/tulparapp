import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/model/user/address.dart';

class AddressController extends GetxController {
  var addresses = Rx<List<AddressModel>>([]);
  var isAddressesLoading = Rx<bool>(false);

  Future<void> fetchAddresses() async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      isAddressesLoading.value = true;
      update();

      var resp = await dio.get('/user/address/all');
      var data = addressModelFromJson(json.encode(resp.data));
      addresses.value = data;
      update();
      Log.success("Получен список из ${data.length} адресов");
    } on DioException catch (e) {
      Log.error("Ошибка получения списка адресов $e");
    } catch (e) {
      Log.error("Ошибка получения списка адресов $e");
    }
    isAddressesLoading.value = false;
    update();
  }

  Future<bool> addAddress({required String address, String? geo, Function(AddressModel)? onDone}) async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      isAddressesLoading.value = true;
      update();
      var resp = await dio.post('/user/address/add', data: {'address': address, 'geo': geo});
      var data = addressModelFromJson(json.encode(resp.data));
      addresses.value = data;
      update();
      Log.success("Адрес добавлен");
      isAddressesLoading.value = false;
      if (onDone != null) {
        var addedAddresss = addresses.value.firstWhereOrNull((a) => a.address == address && a.geo == geo);
        if (addedAddresss != null) {
          onDone(addedAddresss);
        }
      }
      update();
      return true;
    } on DioException catch (e) {
      Log.error("Ошибка добавления адреса $e");
    } catch (e) {
      Log.error("Ошибка добавления адреса $e");
    }
    isAddressesLoading.value = false;
    update();
    return false;
  }

  Future<void> deleteAddress(int addressId) async {
    var inDio = InDio();
    var dio = inDio.instance;
    isAddressesLoading.value = true;
    update();
    try {
      var resp = await dio.delete('/user/address/delete/$addressId');
      var data = addressModelFromJson(json.encode(resp.data));
      addresses.value = data;
      update();
      Log.success("Адрес удален");
    } on DioException catch (e) {
      Log.error("Ошибка удаления адреса $e");
    } catch (e) {
      Log.error("Ошибка удаления адреса $e");
    }
    isAddressesLoading.value = false;
    update();
  }
}
