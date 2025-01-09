import 'package:flutter/material.dart';
import 'package:tulpar/view/screen/tabs/home.dart';

List<TabDataModel> tabData = [
  TabDataModel(
    icon: Icons.home,
    label: 'Главная',
    screen: const HomeTab(),
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
