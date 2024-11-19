// url_strategy_web.dart

import 'package:classroom_app/config/url_strategy_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Web-specific plugin

class UrlStrategyWeb implements UrlStrategyManager {
  @override
  void configureUrlStrategy() {
    // Removing the # from the URL (PathUrlStrategy)
    setUrlStrategy(PathUrlStrategy());
  }
}

// Return an instance of the web-specific UrlStrategyManager
UrlStrategyManager getUrlStrategyManager() => UrlStrategyWeb();
