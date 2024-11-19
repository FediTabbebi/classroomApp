// url_strategy_mobile.dart

import 'package:classroom_app/config/url_strategy_manager.dart';

class UrlStrategyMobile implements UrlStrategyManager {
  @override
  void configureUrlStrategy() {
    // No URL strategy configuration needed for mobile platforms
  }
}

// Return an instance of the mobile-specific UrlStrategyManager
UrlStrategyManager getUrlStrategyManager() => UrlStrategyMobile();
