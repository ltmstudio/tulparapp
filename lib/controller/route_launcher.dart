import 'package:get/get.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteLauncher extends GetxController {
  Future<void> openGoogleMaps(double lat1, double lon1, double lat2, double lon2) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$lat1,$lon1&destination=$lat2,$lon2');
    try {
      await launchUrl(url);
    } catch (e) {
      CoreToast.showToast("Нет возможности построить маршрут в Google Maps");
      Log.error("Ошибка построения маршрута в гугл картах $e");
    }
  }

  Future<void> open2GIS(double lat1, double lon1, double lat2, double lon2) async {
    final url = Uri.parse('dgis://2gis.ru/routeSearch/rsType/car/from/$lon1,$lat1/to/$lon2,$lat2');
    try {
      await launchUrl(url);
    } catch (e) {
      CoreToast.showToast("Нет возможности построить маршрут в 2ГИС");
      Log.error("Ошибка построения маршрута в 2ГИС $e");
    }
  }
}
