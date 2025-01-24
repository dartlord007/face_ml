import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

double translatex(final double x, final InputImageRotation rotation,
    final Size size, final Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);

    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translatey(final double y, final InputImageRotation rotation,
  final Size size, final Size absoluteImageSize) {
  switch (rotation) {
  case InputImageRotation.rotation90deg:
  case InputImageRotation.rotation270deg:
    return y * size.height / (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
  default:
    return y * size.height / absoluteImageSize.height;
  }
}