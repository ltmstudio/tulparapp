import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/env.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/view/screen/driver/cars/cars.dart';
import 'package:tulpar/view/screen/driver/cars/models.dart';

class ModerationAutoScreen extends StatefulWidget {
  const ModerationAutoScreen({super.key});

  @override
  State<ModerationAutoScreen> createState() => _ModerationAutoScreenState();
}

class _ModerationAutoScreenState extends State<ModerationAutoScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DriverModerationController>().fetchCatalogCars();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DriverModerationController>(builder: (moderationController) {
        return ReactiveForm(
          formGroup: moderationController.moderationForm,
          child: ListView(
            padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
            children: [
              Text(
                "Автомобиль".tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 15),
                            child: Text('Марка авто'.tr,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        TextField(
                          readOnly: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const CatalogCarsScreen()),
                            );
                          },
                          controller: TextEditingController(text: moderationController.selectedCar.value?.name),
                          decoration: CoreDecoration.textField.copyWith(
                            hintText: 'Выберите марку авто'.tr,
                            suffixIcon: const Icon(
                              Icons.arrow_forward_ios,
                              color: CoreColors.grey,
                              size: 14,
                            ),
                          ),
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 15),
                            child: Text('Модель авто'.tr,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        TextField(
                          readOnly: true,
                          onTap: () {
                            if (moderationController.selectedCar.value?.id == null) {
                              CoreToast.showToast('Сначала выберите марку авто'.tr);
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CatalogCarModelsScreen(carId: moderationController.selectedCar.value!.id!)),
                            );
                          },
                          controller: TextEditingController(text: moderationController.selectedCarModel.value?.name),
                          decoration: CoreDecoration.textField.copyWith(
                            hintText: 'Выберите модель авто'.tr,
                            suffixIcon: const Icon(
                              Icons.arrow_forward_ios,
                              color: CoreColors.grey,
                              size: 14,
                            ),
                          ),
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Padding(
              //     padding: const EdgeInsets.only(bottom: 10, top: 15),
              //     child:
              //         Text('Модель автомобиля'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              // ReactiveTextField<String?>(
              //   formControlName: 'car_model_id',
              //   decoration: CoreDecoration.textField.copyWith(
              //     hintText: 'Введите модель автомобиля'.tr,
              //   ),
              //   onTapOutside: (event) {
              //     FocusManager.instance.primaryFocus?.unfocus();
              //   },
              // ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Text('VIN автомобиля'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ReactiveTextField(
                formControlName: 'car_vin',
                maxLength: 17,
                decoration: CoreDecoration.textField.copyWith(
                  hintText: 'Введите VIN автомобиля'.tr,
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 15),
                            child: Text('Год автомобиля'.tr,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        ReactiveTextField<int>(
                          formControlName: 'car_year',
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          decoration: CoreDecoration.textField.copyWith(
                            hintText: 'Введите год автомобиля'.tr,
                          ),
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 15),
                            child: Text('Гос. номер автомобиля'.tr,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        ReactiveTextField(
                          formControlName: 'car_gos_number',
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) {
                                return newValue.copyWith(
                                  text: newValue.text.toUpperCase(),
                                );
                              },
                            ),
                          ],
                          decoration: CoreDecoration.textField.copyWith(
                            hintText: 'Введите гос. номер автомобиля'.tr,
                          ),
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text('Фото автомобиля (минимум 2)'.tr,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    for (var field in moderationController.carImagesFields)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FocusedMenuHolder(
                          blurSize: 0.0,
                          menuItemExtent: 45,
                          animateMenuItems: false,
                          openWithTap: true,
                          menuBoxDecoration: const BoxDecoration(
                              color: CoreColors.white,
                              borderRadius: BorderRadius.all(Radius.circular(CoreDecoration.primaryBorderRadius))),
                          duration: const Duration(milliseconds: 30),
                          blurBackgroundColor: Colors.black54,
                          menuOffset: 5.0,
                          bottomOffsetHeight: 80.0,
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                                backgroundColor: Colors.transparent,
                                title: const Text("Открыть камеру"),
                                trailingIcon: const Icon(Icons.camera_alt_outlined, size: 16),
                                onPressed: () {
                                  moderationController.pickNUploadPhoto(key: field.name, source: ImageSource.camera);
                                }),
                            FocusedMenuItem(
                                backgroundColor: Colors.transparent,
                                title: const Text("Открыть галерею"),
                                trailingIcon: const Icon(Icons.photo_library_outlined, size: 16),
                                onPressed: () {
                                  moderationController.pickNUploadPhoto(key: field.name, source: ImageSource.gallery);
                                }),
                            if (moderationController.moderationForm.control(field.name).value?.toString().isNotEmpty ??
                                false)
                              FocusedMenuItem(
                                  backgroundColor: Colors.transparent,
                                  title: const Text("Удалить", style: TextStyle(color: CoreColors.delete)),
                                  trailingIcon:
                                      const Icon(Icons.delete_outline_outlined, size: 16, color: CoreColors.delete),
                                  onPressed: () {
                                    moderationController.deleteUploadedPhoto(key: field.name);
                                  }),
                          ],
                          onPressed: () {},
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                                  child: Builder(builder: (_) {
                                    var formImageUrl = moderationController.moderationForm.control(field.name).value;
                                    var tempFile = moderationController.tempFile.value[field.name];
                                    if (tempFile != null) {
                                      return Image.file(
                                        File(tempFile.path),
                                        width: 200,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    } else if (formImageUrl != null && formImageUrl.toString().isNotEmpty) {
                                      return CachedNetworkImage(
                                        imageUrl:
                                            '${CoreEnvironment.appUrl}/file?path=$formImageUrl&user_folder=user${Get.find<UserController>().user.value?.id}',
                                        httpHeaders: {
                                          "Authorization": "Bearer ${Get.find<UserController>().token.value}",
                                        },
                                        errorListener: (value) {
                                          Log.error(
                                              'Image loading error: $value, token: ${Get.find<UserController>().token.value}');
                                        },
                                        width: 200,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      return Container(
                                        width: 200,
                                        height: 100,
                                        color: CoreColors.white,
                                        child: const Center(
                                          child: Icon(
                                            Icons.add,
                                            color: CoreColors.primary,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                                if (moderationController.tempFileLoading.value[field.name] == true)
                                  Center(
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(color: CoreColors.white, shape: BoxShape.circle),
                                      child: const CircularProgressIndicator(
                                        color: CoreColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
