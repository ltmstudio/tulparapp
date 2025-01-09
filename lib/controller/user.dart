import 'package:get/get.dart';
import 'package:tulpar/model/auth/user.dart';

enum UserLoginStage { phone, sms, done }

class UserController extends GetxController {
  var userStage = Rx<UserLoginStage>(UserLoginStage.phone);

  var user = Rx<UserModel?>(null);
  var token = Rx<String?>(null);
}
