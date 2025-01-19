import 'package:flutter/material.dart';
import 'package:tulpar/core/icons.dart';
import 'package:tulpar/view/screen/tabs/driver/account.dart';
import 'package:tulpar/view/screen/tabs/driver/feed.dart';
import 'package:tulpar/view/screen/tabs/driver/orders.dart';
import 'package:tulpar/view/screen/tabs/user/history.dart';
import 'package:tulpar/view/screen/tabs/user/home.dart';
import 'package:tulpar/view/screen/tabs/user/settings.dart';

List<TabDataModel> tabUserData = [
  TabDataModel(
    icon: Icons.history_rounded,
    label: 'История',
    screen: const HistoryTab(),
  ),
  TabDataModel(
    icon: Icons.home_rounded,
    label: 'Главная',
    screen: const HomeTab(),
  ),
  TabDataModel(
    icon: Icons.settings_rounded,
    label: 'Настройки',
    screen: const SettingsTab(),
  ),
];

List<TabDataModel> tabDriverData = [
  TabDataModel(
    icon: Icons.notes_outlined,
    label: 'Мои заказы',
    screen: const DriverOrdersTab(),
  ),
  TabDataModel(
    icon: TulparIcons.logo,
    label: 'Лента',
    screen: const DriverFeedTab(),
  ),
  TabDataModel(
    icon: Icons.person_rounded,
    label: 'Аккаунт',
    screen: const DriverAccountTab(),
  ),
];

class TabDataModel {
  Widget screen;
  IconData? icon;
  String label;
  bool badge;
  var navigatorKey = GlobalKey<NavigatorState>();
  TabDataModel({required this.screen, required this.icon, required this.label, this.badge = false});
}
