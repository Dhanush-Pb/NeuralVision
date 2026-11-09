
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class GesturePrediction {
  final String label;
  final double confidence;
  final List<double> probabilities;

  const GesturePrediction({
    required this.label,
    required this.confidence,
    required this.probabilities,
  });
}

class GestureService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  List<String> get labels => List.unmodifiable(_labels);

  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/flutter_assets/gesture_classifier.tflite',
    );

    final jsonString = await rootBundle.loadString(
      'assets/flutter_assets/gesture_labels.json',
    );

    _labels = List<String>.from(jsonDecode(jsonString));

    if (_labels.length != 7) {
      throw StateError('Expected 7 labels, found ${_labels.length}');
    }
  }

  List<double> _normalize(List<List<double>> points) {
    if (points.length != 21) {
      throw ArgumentError('Expected 21 landmark points');
    }

    final wristX = points[0][0];
    final wristY = points[0][1];

    final relative = points.map((point) {
      return [
        point[0] - wristX,
        point[1] - wristY,
      ];
    }).toList();

    double maxDistance = 0;

    for (final point in relative) {
      final distance = math.sqrt(
        point[0] * point[0] + point[1] * point[1],
      );

      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    maxDistance += 1e-6;

    return relative
        .expand((point) => [
              point[0] / maxDistance,
              point[1] / maxDistance,
            ])
        .toList();
  }

  GesturePrediction predict(List<List<double>> points) {
    if (_interpreter == null) {
      throw StateError('Gesture model is not initialized');
    }

    final input = [_normalize(points)];
    final output = [
      List<double>.filled(_labels.length, 0),
    ];

    _interpreter!.run(input, output);

    var bestIndex = 0;

    for (int i = 1; i < output[0].length; i++) {
      if (output[0][i] > output[0][bestIndex]) {
        bestIndex = i;
      }
    }

    return GesturePrediction(
      label: _labels[bestIndex],
      confidence: output[0][bestIndex],
      probabilities: List<double>.from(output[0]),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
