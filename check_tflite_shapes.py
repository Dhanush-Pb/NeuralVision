import tensorflow as tf

models = [
    "assets/flutter_assets/hand_landmarks.tflite",
    "assets/flutter_assets/gesture_classifier.tflite",
]

for path in models:
    interpreter = tf.lite.Interpreter(model_path=path)
    interpreter.allocate_tensors()

    print("\nMODEL:", path)
    print("INPUT:", interpreter.get_input_details()[0]["shape"])
    print("OUTPUT:", interpreter.get_output_details()[0]["shape"])