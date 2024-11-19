// url_strategy_factory.dart
export '../config/url_strategy_stub.dart'
    if (dart.library.js) 'url_strategy_web.dart' // Web platform (JS)
    if (dart.library.io) 'url_strategy_mobile.dart'; // Mobile platforms (iOS, Android)
