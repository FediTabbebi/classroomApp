import 'package:flutter/material.dart';

/// A tab to display in a [NavigationBarItemWidget]
class NavigationBarItemWidget {
  /// An icon to display.
  final Widget icon;

  /// A primary color to use for this tab.
  final Color? selectedColor;

  /// The color to display when this tab is not selected.
  final Color? unselectedColor;

  NavigationBarItemWidget({
    required this.icon,
    this.selectedColor,
    this.unselectedColor,
  });
}
