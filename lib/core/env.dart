abstract class CoreEnvironment {
  static const bool useMockApi = true;
  static const String globalIp = '216.250.14.206';
  // static const String globalIp = '192.168.0.122';

  static const String tileServerUrl =
      'http://$globalIp:8080/tiles/{z}/{x}/{y}.png';
  static const double defaultMapLat = 37.9601; // Ashgabat
  static const double defaultMapLng = 58.3261; // Ashgabat
  static const String appUrl = 'https://tulpar-qyzmeti.kz';
  // static const String appUrl = 'http://192.168.50.72:8000';
  static const appStorageUrl = '$appUrl/storage';
}
