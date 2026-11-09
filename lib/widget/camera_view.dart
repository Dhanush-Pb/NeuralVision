import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'landmark_painter.dart';

class CameraView extends StatelessWidget {
  final CameraController controller;
  final List<List<double>> landmarks;

  const CameraView({
    super.key,
    required this.controller,
    required this.landmarks,
  });

  @override
  Widget build(BuildContext context) {
    // Center gives the preview its real shape (no stretching), and the
    // painter sits on top of the preview with exactly the same size.
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: CameraPreview(
          controller,
          child: CustomPaint(
            painter: LandmarkPainter(points: landmarks, mirror: false),
          ),
        ),
      ),
    );
  }
}