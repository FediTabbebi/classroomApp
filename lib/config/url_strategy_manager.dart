// url_strategy_manager.dart

import 'package:classroom_app/config/url_strategy_mobile.dart';

abstract class UrlStrategyManager {
  void configureUrlStrategy();

  // Factory constructor to get platform-specific instance
  factory UrlStrategyManager() => getUrlStrategyManager();
}
