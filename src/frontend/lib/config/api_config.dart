class ApiConfig {
  static const bool isProd = false;

  static const String localBaseUrl = "http://localhost:8080";
  static const String prodBaseUrl = "https://YOUR-CLOUDRUN-URL.a.run.app";

  static String get baseUrl => isProd ? prodBaseUrl : localBaseUrl;
}
