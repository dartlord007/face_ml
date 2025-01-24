import 'dart:math';

import 'package:face_ml/utils/coordinates_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorPainter extends CustomPainter {

  final List<Face> faces;
  final Size absoluteImageSize;
  // final CameraLensDirection cameraLensDirection;
  final InputImageRotation rotation;

  FaceDetectorPainter({
    required this.faces,
    required this.absoluteImageSize,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (final face in faces) {
      canvas.drawRect(
          Rect.fromLTRB(
            translatex(
                face.boundingBox.left, rotation, size, absoluteImageSize),
            translatey(face.boundingBox.top, rotation, size, absoluteImageSize),
            translatex(
                face.boundingBox.right, rotation, size, absoluteImageSize),
            translatey(
                face.boundingBox.bottom, rotation, size, absoluteImageSize),
          ),
          paint);

      void paintContour(final FaceContourType type) {
        final faceContour = face.contours[type];

        if (faceContour?.points != null) {
          for (final Point point in faceContour!.points) {
            canvas.drawCircle(
              Offset(
                translatex(
                    point.x.toDouble(), rotation, size, absoluteImageSize),
                translatey(
                    point.y.toDouble(), rotation, size, absoluteImageSize),
              ),
              1.0,
              paint,
            );
          }
        }
      }

      paintContour(FaceContourType.face);
      paintContour(FaceContourType.leftEyebrowTop);
      paintContour(FaceContourType.leftEyebrowBottom);
      paintContour(FaceContourType.rightEyebrowBottom);
      paintContour(FaceContourType.rightEyebrowTop);
      paintContour(FaceContourType.leftEye);
      paintContour(FaceContourType.rightCheek);
      paintContour(FaceContourType.leftCheek);
      paintContour(FaceContourType.rightEye);
      paintContour(FaceContourType.upperLipTop);
      paintContour(FaceContourType.upperLipBottom);
      paintContour(FaceContourType.lowerLipBottom);
      paintContour(FaceContourType.lowerLipTop);
      paintContour(FaceContourType.noseBottom);
      paintContour(FaceContourType.noseBridge);
    }
  }
  @override
  bool shouldRepaint(final FaceDetectorPainter  oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
    oldDelegate.faces != faces;
  }
}
