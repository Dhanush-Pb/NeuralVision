import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check TFLite model shapes', () async {
    final landmark = await Interpreter.fromAsset(
      'assets/flutter_assets/hand_landmarks.tflite',
    );

    final gesture = await Interpreter.fromAsset(
      'assets/flutter_assets/gesture_classifier.tflite',
    );

    print('LANDMARK MODEL');
    print('Input: ${landmark.getInputTensor(0).shape}');
    print('Output: ${landmark.getOutputTensor(0).shape}');

    print('\nGESTURE MODEL');
    print('Input: ${gesture.getInputTensor(0).shape}');
    print('Output: ${gesture.getOutputTensor(0).shape}');

    landmark.close();
    gesture.close();
  });
}