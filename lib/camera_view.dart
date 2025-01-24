// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:face_ml/main.dart';
import 'package:face_ml/utils/screen_Mode.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

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

Future<void> _initializeCameras() async {
  cameras = await availableCameras();
  // setState(() {});
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.live;
  CameraController? _controller;
  File? _image;
  // String? _text;
  String? _path;
  ImagePicker? _imagePicker;
  int? _cameraindex;
  double zoomlevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;

  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    _initializeCameras();
    super.initState();
    _imagePicker = ImagePicker();
    if (cameras.any((element) =>
        element.lensDirection == widget.initialDirection &&
        element.sensorOrientation == 90)) {
      _cameraindex = cameras.indexOf(cameras.firstWhere((element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90));
    } else if (cameras.any((element) =>
        element.lensDirection == widget.initialDirection &&
        element.sensorOrientation == 270)) {
      _cameraindex = cameras.indexOf(cameras.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.front));
    }
    // else {print("The list is empty");}
    _startLive();
    // if (_cameraindex != null) {
    //   _processCameraImage(_cameraindex);
    // } else {
    //   print("The list is empty");
    // }
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final permissionStatus = await Permission.camera.request();
      if (permissionStatus.isGranted) {
        print('Camera permission granted');
      } else {
        print('Camera permission denied');
      }
    }
  }

  Future _startLive() async {
    final camera = cameras[_cameraindex ?? 0];
    _controller =
        CameraController(camera, ResolutionPreset.max, enableAudio: false);
    _controller?.initialize().then((_) {
      if (!mounted) return;
    });
    _controller?.getMaxZoomLevel().then((value) {
      maxZoomLevel = value;
    });
    _controller?.getMinZoomLevel().then((value) {
      zoomlevel = value;
      minZoomLevel = value;
    });
    _controller?.startImageStream(_processCameraImage).then((_) {
      setState(() {});
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

  Widget? _floatingActionButton() {
    if (_mode == ScreenMode.gallery) return null;
    if (cameras.length == 1) return null;
    return SizedBox(
      height: 70,
      width: 70,
      child: FloatingActionButton(
        onPressed: _switcherCamera,
        child: Icon(
          Platform.isIOS ? Icons.flip_camera_ios : Icons.flip_camera_android,
          size: 40,
        ),
      ),
    );
  }

  Future _switcherCamera() async {
    setState(() => _changingCameraLens = true);

    _cameraindex = (_cameraindex! + 1) % cameras.length;
    await _stopLive();
    await _startLive();

    setState(() => _changingCameraLens = false);
  }

  Widget _body() {
    if (_mode == ScreenMode.live) {
      return _liveBody();
    } else {
      return _galleryBody();
    }
  }

  Widget _galleryBody() => ListView(
        shrinkWrap: true,
        children: [
          _image == null
              ? SizedBox(
                  height: 400,
                  width: 400,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_image!),
                      if (widget.customPaint != null) widget.customPaint!
                    ],
                  ),
                )
              : const Icon(Icons.image, size: 200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery),
              child: const Text("From Gallery"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
                onPressed: () => _getImage(ImageSource.camera),
                child: const Text("Take a Picture")),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
                '${_path == null ? '' : 'image path: $_path '}\n\n${widget.text ?? ''}'),
          ),
        ],
      );

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker!.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
      setState(() {
        _image = null;
        _path = null;
      });
    }
    setState(() {});
  }

  Future _processPickedFile(final XFile pickedFile) async {
    final path = pickedFile.path;
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage!(inputImage);
  }

  Widget _liveBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * (_controller?.value.aspectRatio ?? 1.0);
    if (scale < 1.0) scale = 1.0 / scale;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: _changingCameraLens || _controller == null
                ? Container()
                : CameraPreview(_controller!),
          ),
          if (widget.customPaint != null) widget.customPaint!,
          Positioned(
              child: Slider(
            value: zoomlevel,
            min: minZoomLevel,
            max: maxZoomLevel,
            onChanged: (final newsSliderValue) {
              setState(() {
                zoomlevel = newsSliderValue;
                _controller?.setZoomLevel(zoomlevel);
              });
            },
            divisions:
                (maxZoomLevel - 1).toInt() < 1 ? null : maxZoomLevel.toInt(),
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
