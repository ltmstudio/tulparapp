import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class AuthSmsScreen extends StatefulWidget {
  const AuthSmsScreen({super.key});

  @override
  State<AuthSmsScreen> createState() => _AuthSmsScreenState();
}

class _AuthSmsScreenState extends State<AuthSmsScreen> {
  var smsController = TextEditingController();
  var sendAgainCounter = ValueNotifier<int>(60);

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sendAgainCounter.value > 0) {
        sendAgainCounter.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryBorderRadius),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Введите код'.tr,
                      style: CoreStyles.h3,
                    ),
                    Text(
                      'На указанный номер было отправлено сообщение с кодом подтверждения'.tr,
                      style: CoreStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextField(
                        controller: smsController,
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: CoreStyles.h4,
                        obscureText: true,
                        obscuringCharacter: '*',
                        decoration: CoreDecoration.textField,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    GetBuilder<UserController>(builder: (userController) {
                      var loading = userController.smsToTokenLoading.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: PrimaryElevatedButton(
                          text: 'Подтвердить'.tr,
                          loading: loading,
                          onPressed: () {
                            if (smsController.text.isEmpty) {
                              CoreToast.showToast("Введите корректный код".tr);
                              return;
                            }
                            userController.login(smsController.text);
                          },
                        ),
                      );
                    }),
                    GetBuilder<UserController>(builder: (userController) {
                      var loading = userController.phoneToSmsLoading.value;
                      return ValueListenableBuilder(
                          valueListenable: sendAgainCounter,
                          builder: (_, c, __) {
                            return TextButton(
                                onPressed: c != 0
                                    ? null
                                    : () {
                                        Get.find<UserController>().phoneToSms(userController.phone.value);
                                      },
                                child: Text(loading
                                    ? "..."
                                    : "${"Отправить еще раз".tr} ${c > 0 ? '(${c.toString()} сек)' : ''}"));
                          });
                    }),
                    TextButton(
                        onPressed: () {
                          Get.find<UserController>()
                            ..clearForm()
                            ..userStage.value = UserLoginStage.phone
                            ..update();
                        },
                        child: Text("Ввести другой номер телефона".tr)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        CoreAssets.logoBlueTransparent,
                        width: 100,
                      ),
                    ),
                    const Text(
                      'TULPAR',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CoreColors.primary),
                    ),
                    Text(
                      'Сервис бронирования\nпопутного транспорта'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
