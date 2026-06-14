import 'package:flutter/widgets.dart';

extension SizeExtension on BuildContext {
  static const double figmaHeight = 812;
  static const double figmaWidth = 375;

  // Function for responsive height
  double h(double height) {
    return height * MediaQuery.of(this).size.height / figmaHeight;
  }

  // Function for responsive width
  double w(double width) {
    return width * MediaQuery.of(this).size.width / figmaWidth;
  }

  // Useful for font sizes or icons to scale based on width
  double sp(double size) => w(size);
}