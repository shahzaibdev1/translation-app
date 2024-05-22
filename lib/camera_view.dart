import "dart:ui" as ui;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:translation_app/painters/text_detector_painter.dart';
import 'package:translation_app/translation_details.dart';
import "package:image/image.dart" as img;

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      required this.fromLang,
      required this.targetLang,
      required this.recognizer,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);

  final TextRecognizer recognizer;
  final TranslateLanguage fromLang;
  final TranslateLanguage targetLang;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;
  TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Image? image;
  final _cameraLensDirection = CameraLensDirection.back;
  CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();

    setState(() {
      _textRecognizer = widget.recognizer;
    });

    _initialize();
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recognizer != oldWidget.recognizer) {
      // Text prop has changed, update state (if needed) and rebuild

      setState(() {
        _textRecognizer = widget.recognizer;
        // ... update state here ...
      });
    }
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }

    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int yRowStride = image.planes[0].bytesPerRow;
    final int uvRowStride = (image.planes.length > 1) ? image.planes[1].bytesPerRow : 0;
    final int uvPixelStride = (image.planes.length > 1) ? image.planes[1].bytesPerPixel! : 0;

    final img.Image imgImage = img.Image(width: width, height: height);

    // Iterate over the pixels
    for (int y = 0; y < height; y++) {
      final int yOffset = y * yRowStride;

      for (int x = 0; x < width; x++) {
        final int uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;
        final int yIndex = yOffset + x;

        // Get Y value
        final int yValue = image.planes[0].bytes[yIndex];

        // Get U and V values if available
        int uValue = 128;
        int vValue = 128;

        if (image.planes.length > 1) {
          uValue = image.planes[1].bytes[uvIndex];
          vValue = image.planes[2].bytes[uvIndex];
        }

        // Convert YUV to RGB
        int r = (yValue + (1.370705 * (vValue - 128))).toInt();
        int g = (yValue - (0.337633 * (uValue - 128)) - (0.698001 * (vValue - 128))).toInt();
        int b = (yValue + (1.732446 * (uValue - 128))).toInt();

        // Clamp RGB values
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        // Set pixel
        imgImage.setPixel(x, y, imgImage.getColor(r, g, b));
      }
    }

    return img.copyRotate(imgImage, angle: 90);
  }

  _takePicture() async {
    if (_controller != null) {
      if (widget.customPaint != null) {
        await _controller?.stopImageStream();
        await _controller?.startImageStream((image) async {
          await _controller?.stopImageStream();

          InputImage? inputImage = _inputImageFromCameraImage(image);
          if (inputImage == null) {
            return;
          }
          var newImg = _convertYUV420ToImage(image);

          await _processImage(inputImage, newImg);
        });
      }
    }
  }

  Future<void> _processImage(InputImage inputImage, uiImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      List<Map<String, dynamic>> lst = [];

      final TranslateLanguage sourceLang = widget.fromLang;
      final TranslateLanguage targetLang = widget.targetLang;

      final onDeviceTranslator =
          OnDeviceTranslator(sourceLanguage: sourceLang, targetLanguage: targetLang);

      for (final textBlock in recognizedText.blocks) {
        final String text = await onDeviceTranslator.translateText(textBlock.text);
        lst.add({
          "boundingBox": textBlock.boundingBox,
          "cornerPoints": textBlock.cornerPoints,
          "lines": textBlock.lines,
          "text": text,
          "recognizedLanguages": textBlock.recognizedLanguages
        });
      }

      final painter = TextRecognizerPainter(
        lst,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);

      if (_customPaint != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Builder(
                builder: (context) {
                  return TranslationDetails(text: lst, customPaint: _customPaint!, image: uiImage);
                },
              );
            },
          ),
        ).then((value) => _startLiveFeed);
      }
      // // _isBusy = false;
      // if (mounted) {
      //   setState(() {});
      // }
    } else {
      print('Recognized text:\n\n${recognizedText.text}');
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    // _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();

    return Scaffold(
        appBar: AppBar(
          title: const Text("Camera"),
        ),
        body: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Center(
                child: _changingCameraLens
                    ? const Center(
                        child: Text('Changing camera lens'),
                      )
                    : CameraPreview(
                        _controller!,
                        child: widget.customPaint,
                      ),
              ),
              _switchLiveCameraToggle(),
              _detectionViewModeToggle(),
              _zoomControl(),
              _exposureControl(),
              _takePictureControl()
            ],
          ),
        ));
  }

  Widget _takePictureControl() => Positioned(
        bottom: 16,
        left: MediaQuery.of(context).size.width * 0.5 - 35,
        child: SizedBox(
          height: 80.0,
          width: 80.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => _takePicture(),
            backgroundColor: Colors.black54,
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 80,
            ),
          ),
        ),
      );

  Widget _detectionViewModeToggle() => Positioned(
        bottom: 126,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: widget.onDetectorViewModeChanged,
            backgroundColor: Colors.black54,
            child: const Icon(
              Icons.photo_library_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _switchLiveCameraToggle() => Positioned(
        bottom: 126,
        right: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: _switchLiveCamera,
            backgroundColor: Colors.black54,
            child: Icon(
              Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined,
              size: 25,
            ),
          ),
        ),
      );

  Widget _zoomControl() => Positioned(
        bottom: 130,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _exposureControl() => Positioned(
        top: 40,
        right: 8,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 250,
          ),
          child: Column(children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentExposureOffset.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // Get the camera description and sensor orientation
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    // Determine the rotation value for the image
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      // Get the rotation compensation based on device orientation
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      // Adjust rotation for front-facing camera
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    // Get the image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    // Validate the format for the platform
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // Ensure the image has the correct number of planes
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // Compose the InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // Used only in Android
        format: format, // Used only in iOS
        bytesPerRow: plane.bytesPerRow, // Used only in iOS
      ),
    );
  }
}
