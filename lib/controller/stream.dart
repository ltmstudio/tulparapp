import 'dart:async';

import 'package:get/get.dart';

class WidgetStreamController extends GetxController {
  ///Стримы на экраны
  final StreamController<String> widgetsStreamController = StreamController<String>.broadcast();
  Stream<String> get widgetStream => widgetsStreamController.stream;

  void switchTab(int index) {
    widgetsStreamController.sink.add('switch-tab:$index');
  }
}
