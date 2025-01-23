// ignore_for_file: dead_code

import 'package:camera/camera.dart';
import 'package:face_ml/utils/screen_Mode.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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
    required this.initialDirection,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

Widget _floatingActionButton() {
  return FloatingActionButton(
    onPressed: () {
      // Add your onPressed code here!
    },
    child: const Icon(Icons.camera),
  );
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.live;
  CameraController? _controller;
  File? _image;
  String? _text;
  ImagePicker? _imagePicker;
  int? _cameraindex;
  double zoomlevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  final bool _changingCameraLens = false;

  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    // _initializeCameras();
    super.initState();
    _imagePicker = ImagePicker();
    if (cameras.any((element) =>
        element.lensDirection == widget.initialDirection &&
        element.sensorOrientation == 90)) {
      _cameraindex = cameras.indexOf(cameras.firstWhere((element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90));
    } else {
      _cameraindex = cameras.indexOf(cameras.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.front));
    }
    _startLive();
  }

  Future _startLive() async {
    final camera = cameras[_cameraindex!];
    _controller =
        CameraController(camera, ResolutionPreset.max, enableAudio: false);
    _controller?.initialize().then((_) {
      if (!mounted) return;
    });
    _controller?.getMaxZoomLevel().then((value) {
      maxZoomLevel = value;
      minZoomLevel = value;
    });
  }

  Future _processCameraImage(final image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraindex!];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );

    widget.onImage!(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_allowPicker)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: _switchSceenMode,
                child: Icon(
                  _mode == ScreenMode.live
                      ? Icons.photo_library_rounded
                      : Icons.camera,
                  size: 30,
                ),
              ),
            )
        ],
      ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() {
    if (_mode == ScreenMode.live) {
      return _liveBody();
    } else {
      return _galleryBody();
    }
  }

  Widget _galleryBody() {
    return const Center(
      child: Text('Gallery Mode'),
    );
  }

  Widget _liveBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1.0) scale = 1.0 / scale;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child:
                _changingCameraLens ? Container() : CameraPreview(_controller!),
          ),
          if (widget.customPaint != null) widget.customPaint!,
          Positioned(
              child: Slider(
            value: zoomlevel,
            min: minZoomLevel ?? 0.0,
            max: maxZoomLevel ?? 1.0,
            onChanged: (final newsSliderValue) {
              setState(() {
                zoomlevel = newsSliderValue;
                _controller?.setZoomLevel(zoomlevel);
              });
            },
            divisions: (maxZoomLevel - 1).toInt() < 1
                ? null
                : maxZoomLevel.toInt(),
          ))
        ],
      ),
    );
  }

  void _switchSceenMode() {
    _image = null;
    if (_mode == ScreenMode.live) {
      _mode = ScreenMode.gallery;
      _stopLive();
    } else {
      _mode = ScreenMode.live;
      _startLive();
    }
    setState(() {});
  }

  Future _stopLive() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }
}
