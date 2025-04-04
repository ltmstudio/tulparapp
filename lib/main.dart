import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:navi/navi.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tulpar/controller/address.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/controller/driver_shift.dart';
import 'package:tulpar/controller/other/log.dart';
import 'package:tulpar/controller/pay.dart';
import 'package:tulpar/controller/route_launcher.dart';
import 'package:tulpar/controller/stream.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/translation/translation.dart';
import 'package:tulpar/view/screen/app/start.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _informationParser = NaviInformationParser();
  final _routerDelegate = NaviRouterDelegate.material(child: const AppStartScreen());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromView(View.of(context)).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: ReactiveFormConfig(
        validationMessages: AppController.validationMessages,
        child: GetMaterialApp.router(
          title: 'tulpar',
          locale: const Locale('ru', 'RU'),
          debugShowCheckedModeBanner: false,
          supportedLocales: AppController.supportedLocales.map((e) => e.locale).toList(),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          translations: CoreTranslations(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: CoreColors.primary),
            useMaterial3: true,
            fontFamily: 'Mulish',
            progressIndicatorTheme: const ProgressIndicatorThemeData(color: CoreColors.primary),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: CoreColors.primary)),
            dropdownMenuTheme: DropdownMenuThemeData(
                inputDecorationTheme: InputDecorationTheme(
              errorStyle: CoreStyles.hint.copyWith(color: CoreColors.error),
              hintStyle: CoreStyles.hint,
              prefixStyle: CoreStyles.h4,
              labelStyle: CoreStyles.hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: CoreDecoration.secondaryPadding),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius), borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                  borderSide: const BorderSide(color: CoreColors.primary, width: 2)),
              fillColor: CoreColors.white,
              filled: true,
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                  borderSide: const BorderSide(color: CoreColors.error, width: 2)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                  borderSide: const BorderSide(color: CoreColors.errorFocused, width: 2)),
            )),
          ),
          initialBinding: BindingsBuilder(() {
            Get.put<LogController>(LogController(), permanent: true);
            Get.put<WidgetStreamController>(WidgetStreamController(), permanent: true);
            Get.put<AppController>(AppController(), permanent: true);
            Get.put<UserController>(UserController(), permanent: true);
            Get.put<UserOrderController>(UserOrderController(), permanent: true);
            Get.put<AddressController>(AddressController(), permanent: true);
            Get.put<DriverController>(DriverController(), permanent: true);
            Get.put<DriverModerationController>(DriverModerationController(), permanent: true);
            Get.put<DriverOrderController>(DriverOrderController(), permanent: true);
            Get.put<DriverShiftController>(DriverShiftController(), permanent: true);
            Get.put<RouteLauncher>(RouteLauncher(), permanent: true);
            Get.put<PayController>(PayController(), permanent: true);
          }),
          routeInformationParser: _informationParser,
          routerDelegate: _routerDelegate,
        ),
      ),
    );
  }
}
