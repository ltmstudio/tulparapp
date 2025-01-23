import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/model/driver/profile.dart';

class DriverController extends GetxController {
  var profile = Rx<DriverProfileModel?>(null);
  var profileLoading = Rx<bool>(false);

  Future<void> fetchProfile() async {
    var inDio = InDio();
    var dio = inDio.instance;
    profileLoading.value = true;
    update();
    try {
      var response = await dio.get('/driver/profile');
      if (response.statusCode == 200 && response.data['success'] == true && response.data['data'] != null) {
        profile.value = driverProfileModelFromJson(json.encode(response.data['data']));
        Log.success('Получен профиль водителя');
      } else {
        Log.error('Ошибка получения профиля водителя ${response.data}');
      }
    } catch (e) {
      Log.error('Ошибка получения профиля водителя $e');
    } finally {
      profileLoading.value = false;
      update();
    }
  }

  var tempFile = Rx<XFile?>(null);
  var tempFileLoading = Rx<bool>(false);

  Future<bool?> pickNUploadPhoto({required ImageSource source, CropAspectRatio? aspectRatio}) async {
    final ImagePicker picker = ImagePicker();
    tempFile.value = await picker.pickImage(source: source);
    update();
    if (tempFile.value == null) return false;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: tempFile.value!.path,
      aspectRatio: aspectRatio ?? const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 1000,
      // aspectRatioPresets: [
      //   CropAspectRatioPreset.original,
      // ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Фото профиля',
            toolbarColor: CoreColors.primary,
            toolbarWidgetColor: CoreColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            cropFrameColor: CoreColors.primary,
            backgroundColor: CoreColors.white,
            activeControlsWidgetColor: CoreColors.primary),
        IOSUiSettings(title: 'Фото профиля', aspectRatioLockEnabled: true),
      ],
    );
    if (croppedFile == null) {
      tempFile.value = null;
      update();
      return false;
    }
    tempFile.value = XFile(croppedFile.path);
    tempFileLoading.value = true;
    update();
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      FormData formData = FormData.fromMap({"image": await MultipartFile.fromFile(tempFile.value!.path)});
      var resp = await dio.post('/driver/avatar', data: formData);
      if (resp.statusCode == 200 && resp.data['image_path'] != null) {
        Log.success('Фото успешно загружено');
        profile.value?.avatar = resp.data['image_path'];
        update();
        fetchProfile();
        tempFile.value = null;
        tempFileLoading.value = false;
        update();
        return true;
      } else {
        Log.error('Ошибка выгрузки фото ${resp.data.toString()}');
      }
    } catch (_) {
      Log.error(_.toString());
    }
    tempFile.value = null;
    tempFileLoading.value = false;
    update();
    return false;
  }

  Future<void> deleteAvatar() async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      var response = await dio.delete('/driver/avatar');
      if (response.statusCode == 200) {
        Log.success('Аватар успешно удален');
        profile.value?.avatar = null;
        update();
        fetchProfile();
      } else {
        Log.error('Ошибка удаления аватара ${response.data}');
      }
    } catch (e) {
      Log.error('Ошибка удаления аватара $e');
    }
  }
}
