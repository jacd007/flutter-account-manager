class AppConfigMainApp {
  /// Flag para el modo de pruebas (Fake Auth)
  static bool useFakeAuth = false;

  /// Indica si el banner de DEBUG debe mostrarse
  static bool get showDebugBanner => useFakeAuth;
}
