import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraView extends StatefulWidget {
  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage)? onImage;
  final CameraLensDirection initialDirection;

  const CameraView({
    super.key,
    this.title = 'Camera View',
    this.customPaint,
    this.text,
    required this.onImage,
    required this.initialDirection ,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}