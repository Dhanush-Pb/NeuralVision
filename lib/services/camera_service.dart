import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  CameraDescription? _description;

  CameraController? get controller => _controller;

  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  int get sensorOrientation => _description?.sensorOrientation ?? 0;

  bool get isFront => _description?.lensDirection == CameraLensDirection.front;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No camera found');
    }

    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _description = selectedCamera;

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
  }

  Future<void> startImageStream(
    void Function(CameraImage image) onFrame,
  ) async {
    if (!isInitialized) {
      throw StateError('Camera is not initialized');
    }
    if (_controller!.value.isStreamingImages) return;
    await _controller!.startImageStream(onFrame);
  }

  Future<void> stopImageStream() async {
    if (isInitialized && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}