
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../model/gesture_result.dart';
import '../services/camera_service.dart';
import '../services/landmark_service.dart';
import '../services/gsture_service.dart';

class GestureController extends ChangeNotifier {
  final CameraService cameraService = CameraService();
  final LandmarkService landmarkService = LandmarkService();
  final GestureService gestureService = GestureService();

  static const int skip = 2;
  static const int smooth = 6;

  static const double confidenceLimit = 0.60;
  static const double minConfidence = 0.40;
  static const double margin = 0.15;

  static const int confirm = 2;
  static const int holdMilliseconds = 600;

  CameraController? get cameraController => cameraService.controller;

  GestureResult? result;
  List<List<double>> landmarks = [];

  bool isLoading = true;
  bool isProcessing = false;
  String? error;

  final List<List<double>> _recent = [];

  int _frameNumber = 0;
  int? _candidate;
  int _votes = 0;
  int? _shown;
  int _holdUntil = 0;

  Future<void> initialize() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await landmarkService.initialize();
      await gestureService.initialize();
      await cameraService.initialize();

      isLoading = false;
      notifyListeners();

      await cameraService.startImageStream(_processFrame);
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void _processFrame(CameraImage frame) {
    if (isProcessing || isLoading || error != null) return;

    // Run inference on every second frame, like Python.
    if (_frameNumber++ % skip != 0) return;

    isProcessing = true;

    try {
      final points = landmarkService.predict(
        frame,
        sensorOrientation: cameraService.sensorOrientation,
        isFront: cameraService.isFront,
      );      landmarks = points;

      final prediction = gestureService.predict(points);

      // Keep the latest six probability arrays.
      _recent.add(prediction.probabilities);

      if (_recent.length > smooth) {
        _recent.removeAt(0);
      }

      // Average probabilities across recent predictions.
      final count = _recent.length;
      final classCount = prediction.probabilities.length;

      final average = List<double>.generate(classCount, (i) {
        double total = 0;

        for (final values in _recent) {
          total += values[i];
        }

        return total / count;
      });

      // Find the best and second-best classes.
      final ranked = List<int>.generate(classCount, (i) => i)
        ..sort((a, b) => average[b].compareTo(average[a]));

      final top = ranked[0];
      final topConfidence = average[top];
      final secondConfidence =
          ranked.length > 1 ? average[ranked[1]] : 0.0;

      // Same acceptance rule as Python.
      final sure = topConfidence >= confidenceLimit ||
          (topConfidence >= minConfidence &&
              topConfidence - secondConfidence >= margin);

      if (sure) {
        _votes = top == _candidate ? _votes + 1 : 1;
        _candidate = top;

        if (_votes >= confirm || _shown == top) {
          _shown = top;
          _holdUntil =
              DateTime.now().millisecondsSinceEpoch + holdMilliseconds;
        }
      } else {
        _candidate = null;
        _votes = 0;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final active = _shown != null && now < _holdUntil;

      if (active) {
        result = GestureResult(
          label: gestureService.labels[_shown!],
          confidence: average[_shown!],
          landmarks: landmarks,
        );
      } else {
        result = null;
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isProcessing = false;
    }
  }

  @override
  void dispose() {
    cameraService.stopImageStream();
    cameraService.dispose();
    landmarkService.dispose();
    gestureService.dispose();
    super.dispose();
  }
}
