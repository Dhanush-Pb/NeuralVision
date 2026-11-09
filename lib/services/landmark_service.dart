import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class LandmarkService {
  static const int imgSize = 192;
  static const int inner = 124;
  static const int pad = 34;

  static const double offset = 34 / 192;
  static const double scale = 124 / 192;

  /// Fine tuning. If the dots look turned, try 90, 180 or 270.
  static const int extraRotation = 0;

  /// Python mirrors the camera picture (cv2.flip). The front preview is
  /// mirrored too, so the model input is mirrored for the front camera.
  /// If the dots look left-right swapped, set this to false.
  static const bool mirrorFront = true;

  Interpreter? _interpreter;

  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/flutter_assets/hand_landmarks.tflite',
    );
  }

  int _clamp(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

  /// Runs the landmark model and returns 21 points (0..1 inside the guide box).
  List<List<double>> predict(
    CameraImage image, {
    required int sensorOrientation,
    required bool isFront,
  }) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Landmark model is not initialized');
    }

    final rotation = (sensorOrientation + extraRotation) % 360;
    final mirror = isFront && mirrorFront;

    final rawW = image.width;
    final rawH = image.height;
    final swap = rotation == 90 || rotation == 270;
    final upW = swap ? rawH : rawW; // size of the upright picture
    final upH = swap ? rawW : rawH;

    // Same square as Python guide_box(): centre, 80% of the shorter side.
    final side = (math.min(upW, upH) * 0.8).toInt();
    final x0 = (upW - side) ~/ 2;
    final y0 = (upH - side) ~/ 2;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;
    final yRow = yPlane.bytesPerRow;
    final uRow = uPlane.bytesPerRow;
    final vRow = vPlane.bytesPerRow;
    final uPix = uPlane.bytesPerPixel ?? 1;
    final vPix = vPlane.bytesPerPixel ?? 1;

    // Colour (0xRRGGBB) of point (cx, cy) inside the square crop.
    int colourAt(int cx, int cy) {
      cx = _clamp(cx, 0, side - 1);
      cy = _clamp(cy, 0, side - 1);

      final upX = x0 + cx;
      final upY = y0 + cy;
      final sx = mirror ? upW - 1 - upX : upX; // undo the mirror

      int rx;
      int ry;
      switch (rotation) {
        case 90:
          rx = upY;
          ry = rawH - 1 - sx;
          break;
        case 180:
          rx = rawW - 1 - sx;
          ry = rawH - 1 - upY;
          break;
        case 270:
          rx = rawW - 1 - upY;
          ry = sx;
          break;
        default:
          rx = sx;
          ry = upY;
      }
      rx = _clamp(rx, 0, rawW - 1);
      ry = _clamp(ry, 0, rawH - 1);

      final yi = _clamp(ry * yRow + rx, 0, yBytes.length - 1);
      final ui = _clamp((ry >> 1) * uRow + (rx >> 1) * uPix, 0, uBytes.length - 1);
      final vi = _clamp((ry >> 1) * vRow + (rx >> 1) * vPix, 0, vBytes.length - 1);

      final yy = math.max(0, yBytes[yi] - 16).toDouble();
      final u = uBytes[ui] - 128;
      final v = vBytes[vi] - 128;

      final r = _clamp((1.164 * yy + 1.596 * v).round(), 0, 255);
      final g = _clamp((1.164 * yy - 0.392 * u - 0.813 * v).round(), 0, 255);
      final b = _clamp((1.164 * yy + 2.017 * u).round(), 0, 255);
      return (r << 16) | (g << 8) | b;
    }

    // Median colour of the 4-pixel border of the crop (like Python).
    final rs = <int>[];
    final gs = <int>[];
    final bs = <int>[];
    void addBorder(int cx, int cy) {
      final c = colourAt(cx, cy);
      rs.add((c >> 16) & 255);
      gs.add((c >> 8) & 255);
      bs.add(c & 255);
    }

    for (int t = 0; t < 4; t++) {
      for (int i = 0; i < side; i += 3) {
        addBorder(i, t);
        addBorder(i, side - 1 - t);
        addBorder(t, i);
        addBorder(side - 1 - t, i);
      }
    }

    double median(List<int> values) {
      values.sort();
      return values[values.length ~/ 2].toDouble();
    }

    final bg = <double>[median(rs), median(gs), median(bs)];

    // Shrink the crop to 124 x 124 (average of 4 samples per pixel).
    final small = List<int>.filled(inner * inner, 0);
    final step = side / inner;
    for (int oy = 0; oy < inner; oy++) {
      for (int ox = 0; ox < inner; ox++) {
        int r = 0, g = 0, b = 0;
        for (int sy = 0; sy < 2; sy++) {
          for (int sx = 0; sx < 2; sx++) {
            final c = colourAt(
              ((ox + (sx + 0.5) / 2) * step).floor(),
              ((oy + (sy + 0.5) / 2) * step).floor(),
            );
            r += (c >> 16) & 255;
            g += (c >> 8) & 255;
            b += c & 255;
          }
        }
        small[oy * inner + ox] = ((r ~/ 4) << 16) | ((g ~/ 4) << 8) | (b ~/ 4);
      }
    }

    // 192 x 192 canvas: border colour, with the small picture in the middle.
    final input = [
      List.generate(
        imgSize,
        (y) => List.generate(imgSize, (x) {
          if (x >= pad && x < pad + inner && y >= pad && y < pad + inner) {
            final c = small[(y - pad) * inner + (x - pad)];
            return <double>[
              ((c >> 16) & 255).toDouble(),
              ((c >> 8) & 255).toDouble(),
              (c & 255).toDouble(),
            ];
          }
          return bg;
        }),
      ),
    ];

    final output = [List<double>.filled(42, 0)];
    interpreter.run(input, output);

    final points = <List<double>>[];
    for (int i = 0; i < 21; i++) {
      points.add([
        (output[0][i * 2] - offset) / scale,
        (output[0][i * 2 + 1] - offset) / scale,
      ]);
    }
    return points;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}