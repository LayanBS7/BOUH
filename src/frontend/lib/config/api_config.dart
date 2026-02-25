class ApiConfig {
  static const bool isProd = false;

  static const String localBaseUrl = "http://10.0.2.2:8080";
  static const String physicalBaseUrl = "http://192.168.100.119:8080";//wehen Using real device
  static const String prodBaseUrl = "https://YOUR-CLOUDRUN-URL.a.run.app";

  static String get baseUrl => isProd ? prodBaseUrl : localBaseUrl;
  static String get physicalDeviceBaseUrl => isProd ? prodBaseUrl : physicalBaseUrl;//wehen Using real device
}
