// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide MultipartFile, FormData, Response;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tulpar/controller/dio.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/model/cars/car.dart';
import 'package:tulpar/model/cars/model.dart';
import 'package:tulpar/model/driver/moderation.dart';
import 'package:tulpar/view/screen/driver/moderation/1_info.dart';
import 'package:tulpar/view/screen/driver/moderation/2_personal.dart';
import 'package:tulpar/view/screen/driver/moderation/3_auto.dart';
import 'package:tulpar/view/screen/driver/moderation/4_license.dart';
import 'package:tulpar/view/screen/driver/moderation/5_confirmation.dart';

enum DriverModerationImageFields {
  car_image_1,
  car_image_2,
  car_image_3,
  car_image_4,
  ts_passport_front,
  ts_passport_back,
  driver_license_front,
  driver_license_back
}

class DriverModerationController extends GetxController {
  var moderation = Rx<DriverModerationModel?>(null);
  var catalogCars = Rx<List<CatalogCarModel>>([]);
  var searchResultCars = Rx<List<CatalogCarModel>>([]);
  var catalogCarsLoading = Rx<bool>(false);
  var searchCarsLoading = Rx<bool>(false);

  final carImagesFields = [
    DriverModerationImageFields.car_image_1,
    DriverModerationImageFields.car_image_2,
    DriverModerationImageFields.car_image_3,
    DriverModerationImageFields.car_image_4,
  ];
  final driverLicenseImagesFields = [
    DriverModerationImageFields.driver_license_front,
    DriverModerationImageFields.driver_license_back
  ];

  final stoImagesFields = [DriverModerationImageFields.ts_passport_front, DriverModerationImageFields.ts_passport_back];

  @override
  void onInit() {
    ever(moderation, (m) {
      if (m != null) {
        moderationForm.patchValue({
          'name': m.name,
          'lastname': m.lastname,
          'birthdate': m.birthdate,
          'car_id': m.carId,
          'car_model_id': m.carModelId,
          'car_vin': m.carVin,
          'car_year': m.carYear,
          'car_gos_number': m.carGosNumber,
          'driver_license_number': m.driverLicenseNumber,
          'driver_license_date': m.driverLicenseDate,
          for (var field in carImagesFields) field.name: m.carImages[field.name],
          for (var field in driverLicenseImagesFields) field.name: m.driverLicenseImages[field.name],
          for (var field in stoImagesFields) field.name: m.stoImages[field.name]
        });
        setSelectedCarByModerarionFileds();
      }
    });
    super.onInit();
  }

  // set selected car by moderation fields
  void setSelectedCarByModerarionFileds() async {
    if (moderation.value?.carId != null) {
      selectedCar.value = catalogCars.value.firstWhereOrNull((element) => element.id == moderation.value?.carId);
      if (selectedCar.value == null) {
        await fetchCatalogCars(all: true);
        selectedCar.value = catalogCars.value.firstWhereOrNull((element) => element.id == moderation.value?.carId);
      }
      if (moderation.value?.carModelId != null && selectedCar.value != null) {
        selectedCarModel.value =
            selectedCar.value?.models?.firstWhereOrNull((element) => element.id == moderation.value?.carModelId);
        if (selectedCarModel.value == null) {
          await fetchCarModels(moderation.value?.carId ?? '');
          selectedCarModel.value =
              selectedCar.value?.models?.firstWhereOrNull((element) => element.id == moderation.value?.carModelId);
        }
      }
      update();
    }
  }

  // fetch cars
  Future<void> fetchCatalogCars({bool all = false}) async {
    var inDio = InDio();
    var dio = inDio.instance;
    catalogCarsLoading.value = true;
    update();
    try {
      var resp = await dio.get(all ? '/catalog/cars/all' : '/catalog/cars');
      if (resp.statusCode == 200 && resp.data != null) {
        catalogCars.value = catalogCarModelFromJson(json.encode(resp.data));
        update();
      } else {
        Log.error("Ошибка загрузки каталога авто ${resp.statusCode} ${resp.data}");
      }
    } catch (e) {
      Log.error("Ошибка загрузки каталога авто $e");
    }
    catalogCarsLoading.value = false;
    update();
  }

  //fetch car models
  Future<void> fetchCarModels(String carId) async {
    var inDio = InDio();
    var dio = inDio.instance;
    catalogCarsLoading.value = true;
    update();
    try {
      var resp = await dio.get('/catalog/cars/$carId');
      if (resp.statusCode == 200 && resp.data != null) {
        var carModels = CatalogCarModel.fromJson(json.decode(json.encode(resp.data)));
        catalogCars.value = [
          for (var car in catalogCars.value)
            if (car.id == carId) car.copyWith(models: carModels.models) else car
        ];
        update();
      } else {
        Log.error("Ошибка загрузки моделей авто ${resp.statusCode} ${resp.data}");
      }
    } catch (e) {
      Log.error("Ошибка загрузки моделей авто $e");
    }
    catalogCarsLoading.value = false;
    update();
  }

  // search cars
  Future<void> searchCatalogCars(String search) async {
    var inDio = InDio();
    var dio = inDio.instance;
    searchCarsLoading.value = true;
    update();
    try {
      var resp = await dio.get('/catalog/search', queryParameters: {'search': search});
      if (resp.statusCode == 200 && resp.data != null) {
        searchResultCars.value = catalogCarModelFromJson(json.encode(resp.data));
        update();
      } else {
        Log.error("Ошибка поиска авто ${resp.statusCode} ${resp.data}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        CoreToast.showToast("Автомобиль не найден");
        searchResultCars.value = [];
        update();
      } else {
        CoreToast.showToast("Ошибка запроса");
        Log.error("Ошибка поиска авто $e");
      }
    } catch (e) {
      CoreToast.showToast("Ошибка запроса");
      Log.error("Ошибка поиска авто $e");
    }
    searchCarsLoading.value = false;
    update();
  }

  // fetch moderation
  Future<void> fetchModeration() async {
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      var resp = await dio.get('/driver/moderation');
      if (resp.statusCode == 200 && resp.data != null) {
        moderation.value = driverModerationModelFromJson(json.encode(resp.data));
        update();
      } else {
        Log.error("Ошибка загрузки модерации ${resp.statusCode} ${resp.data}");
      }
    } catch (e) {
      Log.error("Ошибка загрузки модерации $e");
    }
  }

  // form
  var stageLoading = Rx<bool>(false);
  var agreed = Rx<bool>(false);
  var selectedCar = Rx<CatalogCarModel?>(null);
  var selectedCarModel = Rx<CatalogCarModelModel?>(null);

  final moderationForm = FormGroup({
    'name': FormControl<String>(
      validators: [Validators.required],
    ),
    'lastname': FormControl<String>(
      validators: [Validators.required],
    ),
    'birthdate': FormControl<DateTime>(
      validators: [Validators.required],
    ),
    'car_vin': FormControl<String>(
      validators: [Validators.required, Validators.minLength(17), Validators.maxLength(17)],
    ),
    'car_year': FormControl<int>(
      validators: [Validators.required],
    ),
    'car_gos_number': FormControl<String>(
      validators: [Validators.required],
    ),
    'driver_license_number': FormControl<String>(
      validators: [Validators.required],
    ),
    'driver_license_date': FormControl<DateTime>(
      validators: [Validators.required],
    ),
    for (var field in DriverModerationImageFields.values) field.name: FormControl<String?>()
  });

  Future<bool> storeModeration(List<String> fields) async {
    var inDio = InDio();
    var dio = inDio.instance;
    var scs = false;
    final postData = {
      for (var field in fields)
        if (field == 'birthdate' || field == 'driver_license_date')
          field: moderationForm.control(field).value?.toIso8601String()
        else
          field: moderationForm.control(field).value
    };
    if (selectedCar.value?.id != null) {
      postData['car_id'] = selectedCar.value?.id;
    }
    if (selectedCarModel.value?.id != null) {
      postData['car_model_id'] = selectedCarModel.value?.id;
    }
    stageLoading.value = true;
    update();
    try {
      var resp = await dio.post('/driver/moderation', data: postData);
      if (resp.statusCode == 200 && resp.data != null) {
        moderation.value = driverModerationModelFromJson(json.encode(resp.data));
        update();
        Log.success("Даные модерации по полям ${fields.toString()} сохранены");
        scs = true;
      } else {
        Log.error("Ошибка сохранения данных модерации ${resp.statusCode} ${resp.data}");
        CoreToast.showToast("Ошибка сохранения данных анкеты");
      }
    } catch (e) {
      Log.error("Ошибка сохранения данных модерации $e");
      CoreToast.showToast("Ошибка сохранения данных анкеты");
    }
    stageLoading.value = false;
    update();
    return scs;
  }

  Future<bool> setToModeration() async {
    var inDio = InDio();
    var dio = inDio.instance;
    var scs = false;
    stageLoading.value = true;
    update();
    try {
      var resp = await dio.post('/driver/moderation/set');
      if (resp.statusCode == 200 && resp.data["message"] != null) {
        fetchModeration();
        Log.success("Даные модерации отправлены на модерацию");
        scs = true;
      } else {
        Log.error("Ошибка отправки данных модерации на модерацию ${resp.statusCode} ${resp.data}");
        CoreToast.showToast("Ошибка отправки данных анкеты на модерацию");
      }
    } catch (e) {
      Log.error("Ошибка отправки данных модерации на модерацию $e");
      CoreToast.showToast("Ошибка отправки данных анкеты на модерацию");
    }
    stageLoading.value = false;
    update();
    return scs;
  }

  // steps
  var currentPage = Rx<int>(0);

  final allScreens = [
    const ModerationInfoScreen(),
    const ModerationPersonalScreen(),
    const ModerationAutoScreen(),
    const ModerationLicenseScreen(),
    const ModerationConfirmationScreen(),
  ];

  Future<bool> validateStage() async {
    var res = false;

    switch (currentPage.value) {
      // info
      case 0:
        if (agreed.value) {
          res = true;
        } else {
          CoreToast.showToast("Отметьте пункт ознакомления");
        }
      case 1:
        if (moderationForm.control('name').invalid ||
            moderationForm.control('lastname').invalid ||
            moderationForm.control('birthdate').invalid) {
          CoreToast.showToast("Заполните все обязательные поля");
          res = false;
        } else {
          bool scs = await storeModeration(['name', 'lastname', 'birthdate']);
          res = scs;
        }
      case 2:
        if (moderationForm.control('car_vin').invalid ||
            moderationForm.control('car_year').invalid ||
            moderationForm.control('car_gos_number').invalid ||
            selectedCarModel.value == null ||
            selectedCar.value == null) {
          CoreToast.showToast("Заполните все поля");
          res = false;
        } else {
          bool scs = await storeModeration(['car_vin', 'car_year', 'car_gos_number']);
          res = scs;
        }
      case 3:
        if (moderationForm.control('driver_license_date').invalid ||
            moderationForm.control('driver_license_number').invalid) {
          CoreToast.showToast("Заполните все поля");
          res = false;
        } else {
          bool scs = await storeModeration(['driver_license_date', 'driver_license_number']);
          res = scs;
        }
        break;
      default:
    }
    return res;
  }

  void nextPage() {
    if (currentPage.value < allScreens.length - 1) {
      currentPage.value++;
      update();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      update();
    }
  }

  void goToPage(int page) {
    currentPage.value = page;
    update();
  }

  var tempFile = Rx<Map<String, XFile?>>({});
  var tempFileLoading = Rx<Map<String, bool>>({});

  Future<bool?> pickNUploadPhoto(
      {required String key, required ImageSource source, CropAspectRatio? aspectRatio}) async {
    final ImagePicker picker = ImagePicker();
    tempFile.value[key] = await picker.pickImage(source: source);
    update();
    if (tempFile.value[key] == null) return false;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: tempFile.value[key]!.path,
      aspectRatio: aspectRatio ?? const CropAspectRatio(ratioX: 1, ratioY: 0.5),
      maxWidth: 1000,
      // aspectRatioPresets: [
      //   CropAspectRatioPreset.original,
      // ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Редактирование фото',
            toolbarColor: CoreColors.primary,
            toolbarWidgetColor: CoreColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            cropFrameColor: CoreColors.primary,
            backgroundColor: CoreColors.white,
            activeControlsWidgetColor: CoreColors.primary),
        IOSUiSettings(title: 'Редактирование фото', aspectRatioLockEnabled: true),
      ],
    );
    if (croppedFile == null) {
      tempFile.value[key] = null;
      update();
      return false;
    }
    tempFile.value[key] = XFile(croppedFile.path);
    tempFileLoading.value[key] = true;
    update();
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      FormData formData =
          FormData.fromMap({'field_key': key, "image": await MultipartFile.fromFile(tempFile.value[key]!.path)});
      var resp = await dio.post('/driver/moderation/upload_image', data: formData);
      if (resp.statusCode == 200 && resp.data['image_path'] != null) {
        Log.success('Фото успешно загружено');
        fetchModeration();
        moderationForm.control(key).updateValue(resp.data['image_path'].toString());
        tempFile.value.remove(key);
        tempFileLoading.value.remove(key);
        update();
        return true;
      } else {
        Log.error('Ошибка выгрузки фото ${resp.data.toString()}');
      }
    } catch (_) {
      Log.error(_.toString());
    }
    tempFile.value.remove(key);
    tempFileLoading.value.remove(key);
    update();
    return false;
  }

  Future<bool?> deleteUploadedPhoto({required String key}) async {
    tempFileLoading.value[key] = true;
    update();
    var inDio = InDio();
    var dio = inDio.instance;
    try {
      var resp = await dio.post('/driver/moderation/delete_image', data: {
        'field_key': key,
      });
      if (resp.statusCode == 200) {
        Log.success('Фото успешно удалено');
        fetchModeration();
        moderationForm.control(key).updateValue(null);
        tempFile.value.remove(key);
        tempFileLoading.value.remove(key);
        update();
        return true;
      } else {
        Log.error('Ошибка удаления фото ${resp.data.toString()}');
      }
    } catch (_) {
      Log.error(_.toString());
    }
    tempFile.value.remove(key);
    tempFileLoading.value.remove(key);
    update();
    return false;
  }

  void resetController() {
    moderation.value = null;
    catalogCars.value = [];
    catalogCarsLoading.value = false;
    stageLoading.value = false;
    agreed.value = false;
    selectedCar.value = null;
    selectedCarModel.value = null;
    currentPage.value = 0;
    tempFile.value = {};
    tempFileLoading.value = {};
    moderationForm.reset();
  }
}
