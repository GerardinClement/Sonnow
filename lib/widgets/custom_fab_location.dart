import 'package:flutter/material.dart';

class CustomFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double screenWidth = scaffoldGeometry.scaffoldSize.width;
    final double screenHeight = scaffoldGeometry.scaffoldSize.height;

    final double fabWidth = scaffoldGeometry.floatingActionButtonSize.width;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    const double rightPadding = 32;
    const double bottomPadding = 100;

    return Offset(
      screenWidth - fabWidth - rightPadding,
      screenHeight - fabHeight - bottomPadding,
    );
  }
}
