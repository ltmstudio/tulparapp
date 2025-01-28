import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';

class ModerationConfirmationScreen extends StatefulWidget {
  const ModerationConfirmationScreen({super.key});

  @override
  State<ModerationConfirmationScreen> createState() => _ModerationConfirmationScreenState();
}

class _ModerationConfirmationScreenState extends State<ModerationConfirmationScreen> {
  final labelStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  final valueStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  final labelPadding = const EdgeInsets.only(bottom: 5, top: 10);
  final valuePadding = const EdgeInsets.only(bottom: 5);
  final notSettedValue = Text.rich(TextSpan(text: "", children: [
    const WidgetSpan(
        child: Icon(
      Icons.error,
      size: 18,
      color: CoreColors.error,
    )),
    TextSpan(
        text: 'Не указано'.tr,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CoreColors.grey))
  ]));
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverModerationController>(builder: (moderationController) {
      var moderation = moderationController.moderation.value;
      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
          children: [
            Text(
              "Подтверждение данных".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 7),
            Text("Убедитесь что все данные заполнены верно".tr),
            const Divider(),
            Padding(padding: labelPadding, child: Text('Имя'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.name != null ? Text('${moderation?.name}'.tr, style: valueStyle) : notSettedValue),
            Padding(padding: labelPadding, child: Text('Фамилия'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.lastname != null
                    ? Text('${moderation?.lastname}'.tr, style: valueStyle)
                    : notSettedValue),
            Padding(padding: labelPadding, child: Text('Дата рождения'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.birthdate != null
                    ? Text(DateFormat('dd.MM.yyyy').format(moderation!.birthdate!).tr, style: valueStyle)
                    : notSettedValue),
            // авто
            Padding(padding: labelPadding, child: Text('Марка авто'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.carId != null ? Text('${moderation?.carId}'.tr, style: valueStyle) : notSettedValue),
            Padding(padding: labelPadding, child: Text('Модель авто'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.carModelId != null
                    ? Text('${moderation?.carModelId}'.tr, style: valueStyle)
                    : notSettedValue),
            Padding(padding: labelPadding, child: Text('VIN'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child:
                    moderation?.carVin != null ? Text('${moderation?.carVin}'.tr, style: valueStyle) : notSettedValue),
            Padding(padding: labelPadding, child: Text('Год выпуска'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.carYear != null
                    ? Text('${moderation?.carYear}'.tr, style: valueStyle)
                    : notSettedValue),
            Padding(padding: labelPadding, child: Text('Гос. номер'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.carGosNumber != null
                    ? Text('${moderation?.carGosNumber}'.tr, style: valueStyle)
                    : notSettedValue),
            Padding(padding: labelPadding, child: Text('Фото авто'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.carImages.entries.where((e) => e.value != null).isNotEmpty ?? false
                    ? Text('${moderation?.carImages.entries.where((e) => e.value != null).length} фото'.tr,
                        style: valueStyle)
                    : notSettedValue),
            // водительское удостоверение
            Padding(padding: labelPadding, child: Text('Номер вод. удостоверения'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.driverLicenseNumber != null
                    ? Text('${moderation?.driverLicenseNumber}'.tr, style: valueStyle)
                    : notSettedValue),
            Padding(padding: labelPadding, child: Text('Дата выдачи'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.driverLicenseDate != null
                    ? Text(DateFormat('dd.MM.yyyy').format(moderation!.driverLicenseDate!).tr, style: valueStyle)
                    : notSettedValue),
            Padding(padding: labelPadding, child: Text('Фото вод. удостоверения'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.driverLicenseFront != null && moderation?.driverLicenseBack != null
                    ? Text('2 фото'.tr, style: valueStyle)
                    : notSettedValue),
            // тех. паспорт
            Padding(padding: labelPadding, child: Text('Фото тех. паспорта'.tr, style: labelStyle)),
            Padding(
                padding: valuePadding,
                child: moderation?.tsPassportFront != null && moderation?.tsPassportBack != null
                    ? Text('2 фото'.tr, style: valueStyle)
                    : notSettedValue),
            const Divider(),
            Text(
                "Нажмите \"Подтвердить\" для отправки ваших данных на модерацию. Статус проверки будет отображаться на экране профиля"
                    .tr),
          ],
        ),
      );
    });
  }
}
