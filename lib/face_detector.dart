// ignore_for_file: non_constant_identifier_names

import 'package:face_ml/camera_view.dart';
import 'package:face_ml/utils/face_detector_painter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:image_picker/image_picker.dart';

import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({
    super.key,
  });

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

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      initialDirection: CameraLensDirection.front,
      onImage: (inputImage) {
        // Add your image processing code here
      },
    );
  }

  Future<void> processImage(final InputImage InputImage) async {
    if (!canProcessImage) return;
    if (!isBusy) return;
    isBusy = true;
    setState(() {
      _text = 'Processing...';
    });
    final faces = await _faceDetector.processImage(InputImage);
    if (InputImage.metadata?.size != null &&
        InputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces: faces,
        absoluteImageSize: InputImage.metadata!.size,
        rotation: InputImage.metadata!.rotation,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces Found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
