import 'package:get/get.dart';
import 'package:tulpar/model/other/log.dart';

class LogController extends GetxController {
  var list = Rx<List<LogModel>>([]);

  void set(LogModel l) {
    if (list.value.length > 300) {
      list.value = list.value.sublist(20, list.value.length);
    }
    if (list.value.isNotEmpty) {
      var lastLog = list.value.last;
      if (lastLog.text == l.text && lastLog.color.toString() == l.color.toString()) {
        list.value.removeLast();
      }
    }
    list.value.add(l);
    update();
  }
}
