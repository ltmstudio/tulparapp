import 'package:get/get.dart';
import 'package:tulpar/model/other/log.dart';

class LogController extends GetxController {
  var list = Rx<List<LogModel>>([]);

  void set(LogModel l) {
    if (list.value.length > 300) {
      list.value = list.value.sublist(20, list.value.length);
    }
    list.value.add(l);
    update();
  }
}
