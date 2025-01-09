import 'package:fluttertoast/fluttertoast.dart';
import 'package:tulpar/core/colors.dart';

class CoreToast {
  static showToast(String x) {
    return Fluttertoast.showToast(
      backgroundColor: CoreColors.primary,
      textColor: CoreColors.white,
      msg: x,
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
