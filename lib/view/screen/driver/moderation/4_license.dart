import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/env.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/view/dialog/date_picker.dart';

class ModerationLicenseScreen extends StatefulWidget {
  const ModerationLicenseScreen({super.key});

  @override
  State<ModerationLicenseScreen> createState() => _ModerationLicenseScreenState();
}

class _ModerationLicenseScreenState extends State<ModerationLicenseScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverModerationController>(builder: (moderationController) {
      return Scaffold(
          body: ReactiveForm(
        formGroup: moderationController.moderationForm,
        child: ListView(padding: const EdgeInsets.all(CoreDecoration.primaryPadding), children: [
          Text(
            "Водительское удостоверение \nи Тех. пасспорт".tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 15),
              child: Text('Номер ВУ'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          ReactiveTextField(
            formControlName: 'driver_license_number',
            decoration: CoreDecoration.textField.copyWith(
              hintText: 'Введите номер ВУ'.tr,
            ),
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 15),
              child: Text('Дата выдачи ВУ'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          ReactiveTextField<DateTime>(
            formControlName: 'driver_license_date',
            readOnly: true,
            onTap: (control) async {
              DateTime? newDate = await showDialog(
                  context: context, builder: (context) => DateNumberPickerDialog(initialDate: control.value));
              if (newDate != null) {
                control.value = newDate;
              }
            },
            decoration: CoreDecoration.textField.copyWith(
              hintText: 'Укажите дату выдачи ВУ'.tr,
              suffixIcon: const Icon(Icons.calendar_month),
            ),
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text('Фото ВУ (Передняя и задняя стороны)'.tr,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          SizedBox(
            height: 146,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                for (var field in moderationController.driverLicenseImagesFields)
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
                              moderationController.pickNUploadPhoto(
                                  key: field.name,
                                  source: ImageSource.camera,
                                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 0.63));
                            }),
                        FocusedMenuItem(
                            backgroundColor: Colors.transparent,
                            title: const Text("Открыть галерею"),
                            trailingIcon: const Icon(Icons.photo_library_outlined, size: 16),
                            onPressed: () {
                              moderationController.pickNUploadPhoto(
                                  key: field.name,
                                  source: ImageSource.gallery,
                                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 0.63));
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
                        height: 126,
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
                                    height: 126,
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
                                    height: 126,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Container(
                                    width: 200,
                                    height: 126,
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
          Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text('Фото Тех. паспорта (Передняя и задняя стороны)'.tr,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          SizedBox(
            height: 146,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                for (var field in moderationController.stoImagesFields)
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
                              moderationController.pickNUploadPhoto(
                                  key: field.name,
                                  source: ImageSource.camera,
                                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 0.63));
                            }),
                        FocusedMenuItem(
                            backgroundColor: Colors.transparent,
                            title: const Text("Открыть галерею"),
                            trailingIcon: const Icon(Icons.photo_library_outlined, size: 16),
                            onPressed: () {
                              moderationController.pickNUploadPhoto(
                                  key: field.name,
                                  source: ImageSource.gallery,
                                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 0.63));
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
                        height: 126,
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
                                    height: 126,
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
                                    height: 126,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Container(
                                    width: 200,
                                    height: 126,
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
        ]),
      ));
    });
  }
}
