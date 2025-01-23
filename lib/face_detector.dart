import 'package:face_ml/camera_view.dart';
import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:image_picker/image_picker.dart';

import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({super.key,});

  @override
  State<FaceDetectorPage> createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<FaceDetectorPage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
    ),
  );

  bool canProcessImage = true;
  bool isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() {
    canProcessImage = false;
    super.dispose();
  }

  Widget build(BuildContext context) {
    return CameraView();
  }
}
