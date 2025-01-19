import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/view/dialog/date_picker.dart';

class ModerationPersonalScreen extends StatefulWidget {
  const ModerationPersonalScreen({super.key});

  @override
  State<ModerationPersonalScreen> createState() => _ModerationPersonalScreenState();
}

class _ModerationPersonalScreenState extends State<ModerationPersonalScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverModerationController>(builder: (moderationController) {
      return Scaffold(
        body: ReactiveForm(
          formGroup: moderationController.moderationForm,
          child: ListView(
            padding: EdgeInsets.all(CoreDecoration.primaryPadding),
            children: [
              Text(
                "Личная информация",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Text('Имя'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ReactiveTextField(
                formControlName: 'name',
                decoration: CoreDecoration.textField.copyWith(
                  hintText: 'Введите имя'.tr,
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Text('Фамилия'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ReactiveTextField(
                formControlName: 'lastname',
                decoration: CoreDecoration.textField.copyWith(
                  hintText: 'Введите фамилию'.tr,
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Text('Дата рождения'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ReactiveTextField<DateTime>(
                formControlName: 'birthdate',
                readOnly: true,
                onTap: (control) async {
                  DateTime? newDate = await showDialog(
                      context: context, builder: (context) => DateNumberPickerDialog(initialDate: control.value));
                  if (newDate != null) {
                    control.value = newDate;
                  }
                },
                decoration: CoreDecoration.textField.copyWith(
                  hintText: 'Выберите дату'.tr,
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
