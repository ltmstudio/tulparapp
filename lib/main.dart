import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:navi/navi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tulpar/controller/address.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/other/log.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/colors.dart';
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
  final _routerDelegate = NaviRouterDelegate.material(
    child: const AppStartScreen(),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'TULPAR',
      locale: const Locale('ru', 'RU'),
      supportedLocales: AppController.supportedLocales.map((e) => e.locale).toList(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      translations: CoreTranslations(),
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: CoreColors.primary),
          useMaterial3: true,
          fontFamily: 'Mulish',
          progressIndicatorTheme: const ProgressIndicatorThemeData(color: CoreColors.primary),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: CoreColors.primary))),
      initialBinding: BindingsBuilder(() {
        Get.put<LogController>(LogController(), permanent: true);
        Get.put<AppController>(AppController(), permanent: true);
        Get.put<UserController>(UserController(), permanent: true);
        Get.put<UserOrderController>(UserOrderController(), permanent: true);
        Get.put<AddressController>(AddressController(), permanent: true);
      }),
      routeInformationParser: _informationParser,
      routerDelegate: _routerDelegate,
    );
  }
}
