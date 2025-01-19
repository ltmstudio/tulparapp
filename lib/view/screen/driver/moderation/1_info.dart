import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/model/driver/moderation.dart';

class ModerationInfoScreen extends StatefulWidget {
  const ModerationInfoScreen({super.key});

  @override
  State<ModerationInfoScreen> createState() => _ModerationInfoScreenState();
}

class _ModerationInfoScreenState extends State<ModerationInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
      children: [
        Text(
          "Общая информация",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        GetBuilder<DriverModerationController>(builder: (moderationController) {
          return moderationController.moderation.value?.status == DriverModerationStatus.rejected &&
                  moderationController.moderation.value?.rejectMessage != null
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(CoreDecoration.primaryPadding),
                  decoration: BoxDecoration(
                      color: CoreColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ваша анкета была отклонена модератором.\nПричина:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 7),
                      Text(moderationController.moderation.value?.rejectMessage ?? ""),
                      const SizedBox(height: 7),
                    ],
                  ),
                )
              : Container();
        }),
        Text("Чтобы выполнять заказы в системе TULPAR требуется заполнить анкету водителя и пройти модерацию."),
        const SizedBox(height: 7),
        Text("После проверки анкеты и документов, вам будет доступен следующий функционал:"),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. Просмотр заказов"),
              Text("2. Пополнение баланса"),
              Text("3. Получение номера телефона клиента"),
              Text("4. Статистика выполненных заказов"),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text("В анкете потребуется указать следующие данные и документы:"),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. ФИО"),
              Text("2. Дата рождения"),
              Text("3. Общая информация об авто"),
              Text("4. Фото авто"),
              Text("5. Информация о водительском удостоверении"),
              Text("6. Фото водительского удостоверения"),
              Text("7. Фото тех. паспорта"),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
            "Все внесенные данные сохраняются на сервере в защищенном хранилище и не передаются третьим лицам. Модерация анкеты проходит в течение 2 рабочих дней после подтвержения отправки."),
        const SizedBox(height: 7),
        Text("После успешной модерации вам придет смс на ваш номер телефона."),
        const SizedBox(height: 7),
        Text("Чтобы прожолжить отметьте пункт ознакомления с правилами использования сервиса."),
        const SizedBox(height: 7),
        GetBuilder<DriverModerationController>(builder: (moderationController) {
          return CheckboxListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            value: moderationController.agreed.value,
            onChanged: (value) {
              if (value == null) return;
              moderationController.agreed.value = value;
              moderationController.update();
            },
            title: Text(
              "Я ознакомлен с правилами использования сервиса",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          );
        }),
      ],
    ));
  }
}
