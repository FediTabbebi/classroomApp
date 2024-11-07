import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

String? validateEmailAddress(String value, bool isRegister) {
  if (value.isEmpty) {
    return "Please enter ${isRegister ? "your" : "user"} email address";
  } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
    return "Please enter a valid email address";
  }
  return null;
}

String? validateEmptyField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "This filed cannot be empty";
  }
  return null;
}

String? validatefirstName(String? value, bool isRegister) {
  if (value == null || value.trim().isEmpty) {
    return "Please enter ${isRegister ? "your" : "user"} first name";
  } else if (value.trim().length < 3) {
    return "first name must be at least 3 characters";
  }
  return null;
}

String? validatelastName(String? value, bool isRegister) {
  if (value == null || value.trim().isEmpty) {
    return "Please enter ${isRegister ? "your" : "user"} last name";
  } else if (value.trim().length < 3) {
    return "last name must be at least 3 characters";
  }
  return null;
}

String? validatePassword(String value, bool isRegister) {
  if (value.trim().isEmpty) {
    return "Please enter ${isRegister ? "your" : "user"} password";
  }
  if (value.length < 6) {
    return "Password must be at least 6 characters";
  }

  return null;
}

String? validateConfirmPassword(String password, String confirmPassword) {
  if (confirmPassword.trim().isEmpty) {
    return "Please confirm your password";
  }
  if (confirmPassword != password) {
    return "Passwords do not match";
  }
  return null;
}

String? validateEmptyList(List<dynamic>? value) {
  if (value == null || value.isEmpty) {
    return "Please assign a member to this project";
  }
  return null;
}

String? validateEmptyFieldWithResponse(String? value, String responseMessage) {
  if (value == null || value.trim().isEmpty) {
    return responseMessage;
  }
  return null;
}

String formatDuration(DateTime givenDate) {
  Duration difference = DateTime.now().difference(givenDate);
  if (difference.inDays > 365) {
    int years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''}';
  } else if (difference.inDays > 30) {
    int months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''}';
  } else if (difference.inDays > 7) {
    int weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''}';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
  } else {
    return 'Just now';
  }
}

Future<bool> platformChecker(DeviceInfoPlugin deviceInfo) async {
  if (kIsWeb) {
    // Return false if running on the web, as there is no "mobile" distinction
    return false;
  }

  bool isEmulator = false;
  bool isTablet = false;

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Check if it's a physical device or an emulator
    isEmulator = androidInfo.model.toLowerCase().contains('sdk') ||
        androidInfo.hardware.toLowerCase().contains('goldfish') ||
        androidInfo.hardware.toLowerCase().contains('ranchu') ||
        androidInfo.hardware.toLowerCase().contains('qemu') ||
        androidInfo.product.toLowerCase().contains('sdk_google') ||
        androidInfo.brand.toLowerCase().startsWith('generic') ||
        androidInfo.fingerprint.toLowerCase().contains('generic') ||
        androidInfo.manufacturer.toLowerCase().contains('unknown') ||
        androidInfo.model.toLowerCase().contains('emulator') ||
        androidInfo.model.toLowerCase().contains('virtual');

    // Check if it's a tablet (generally large screen sizes in Android)
    isTablet = (androidInfo.systemFeatures.contains('android.hardware.telephony') == false);

    // Return true if it's a mobile device (physical or emulator), but false if it's a tablet
    return (androidInfo.isPhysicalDevice || isEmulator) && !isTablet;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    // Check if it's a physical device or an emulator
    isEmulator = iosInfo.model.toLowerCase().contains('simulator');

    // Check if it's a tablet (iPads are tablets on iOS)
    isTablet = iosInfo.model.toLowerCase().contains('ipad');

    // Return true if it's a mobile device (physical or emulator), but false if it's a tablet
    return (iosInfo.isPhysicalDevice || isEmulator) && !isTablet;
  }

  return false; // Assume it's not mobile if it's another platform
}
