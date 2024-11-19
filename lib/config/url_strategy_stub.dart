// url_strategy_stub.dart

import 'package:classroom_app/config/url_strategy_manager.dart';

class UrlStrategyStub implements UrlStrategyManager {
  @override
  void configureUrlStrategy() {
    // Throw an error for unsupported platforms
    throw UnsupportedError('Cannot configure URL strategy for this platform.');
  }
}

// Return an instance of the stub implementation
UrlStrategyManager getUrlStrategyManager() => UrlStrategyStub();
