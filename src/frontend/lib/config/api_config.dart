class ApiConfig {
  static const bool isProd = false;

  static const String localBaseUrl = "http://10.0.2.2:8080";
  static const String prodBaseUrl = "https://YOUR-CLOUDRUN-URL.a.run.app";

  static String get baseUrl => isProd ? prodBaseUrl : localBaseUrl;
}
