import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masked_text_field/masked_text_field.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/view/screen/auth/public_offer.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  var phoneController = TextEditingController();
  var checked = ValueNotifier(false);
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
                      'Введите номер телефона'.tr,
                      style: CoreStyles.h3,
                    ),
                    Text(
                      'Мы отправим СМС с кодом подтверждения'.tr,
                      style: CoreStyles.h4,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: MaskedTextField(
                        textFieldController: phoneController,
                        onChange: (value) {},
                        mask: '(###) ###-##-##',
                        escapeCharacter: '#',
                        maxLength: 15,
                        inputDecoration: CoreDecoration.textField.copyWith(
                          prefixText: '+7 ',
                        ),
                        keyboardType: TextInputType.phone,
                        // textInputAction: TextInputAction.next,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PublicOfferScreen()),
                        );
                      },
                      title: Text.rich(
                        TextSpan(
                          text: 'Я ознакомился с '.tr,
                          children: [
                            TextSpan(
                                text: 'Лицензионным соглашением'.tr,
                                style:
                                    const TextStyle(color: CoreColors.primary, decoration: TextDecoration.underline)),
                            TextSpan(text: ' и принимаю условия публичной оферты')
                          ],
                        ),
                        style: TextStyle(height: 1.1),
                      ),
                      trailing: ValueListenableBuilder(
                          valueListenable: checked,
                          builder: (_, c, __) {
                            return Checkbox(
                                value: c,
                                onChanged: (_) {
                                  checked.value = !c;
                                });
                          }),
                    ),
                    SizedBox(height: 15),
                    GetBuilder<UserController>(builder: (userController) {
                      var loading = userController.phoneToSmsLoading.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: PrimaryElevatedButton(
                          text: 'Получить код'.tr,
                          loading: loading,
                          onPressed: () {
                            var phone = phoneController.text.replaceAll(RegExp(r'\D'), '');
                            if (phone.length < 10) {
                              CoreToast.showToast("Введите корректный номер телефона".tr);
                              return;
                            }
                            if (checked.value != true) {
                              CoreToast.showToast('Ознакомьтесь с Лицензионным соглашением');
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            userController.phoneToSms(phone);
                          },
                        ),
                      );
                    }),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('или'.tr, style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 10),
                    GetBuilder<UserController>(builder: (userController) {
                      var loading = userController.googleSignInLoading.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: OutlinedButton(
                          onPressed: loading ? null : () {
                            if (checked.value != true) {
                              CoreToast.showToast('Ознакомьтесь с Лицензионным соглашением');
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            userController.loginWithGoogle();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: CoreColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.g_mobiledata, size: 28, color: CoreColors.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Войти через Google'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: CoreColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
