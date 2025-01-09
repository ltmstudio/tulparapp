import 'package:flutter/material.dart';
import 'package:tulpar/view/screen/tabs/history.dart';
import 'package:tulpar/view/screen/tabs/home.dart';
import 'package:tulpar/view/screen/tabs/settings.dart';

List<TabDataModel> tabData = [
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

class TabDataModel {
  Widget screen;
  IconData? icon;
  String label;
  bool badge;
  var navigatorKey = GlobalKey<NavigatorState>();
  TabDataModel({required this.screen, required this.icon, required this.label, this.badge = false});
}
