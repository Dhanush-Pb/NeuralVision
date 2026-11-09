# NeuralVision-Flutter

**Neural Vision – AI-Powered Hand Gesture Recognition**

A Flutter mobile application that integrates custom-trained AI models for real-time hand landmark detection and hand gesture recognition. The application uses TensorFlow Lite to perform on-device inference, enabling live hand tracking and gesture classification.

## Features

- **Real-Time Hand Tracking** – Detects and tracks hand landmarks using a custom-trained model.
- **21-Point Landmark Detection** – Visualizes 21 key points across the hand.
- **Gesture Classification** – Recognizes hand gestures using a custom neural network.
- **Live Camera Integration** – Processes camera frames for real-time recognition.
- **On-Device AI Inference** – Runs TensorFlow Lite models directly on the mobile device.
- **Gesture Confidence** – Displays prediction confidence during recognition.

## AI Model Architecture

The application integrates two custom-trained models:

### 1. Hand Landmark Detection
- Custom CNN-based heatmap prediction model.
- Detects 21 hand landmarks.
- Produces 42 X/Y coordinate values.
- Trained using the FreiHAND dataset.

### 2. Gesture Classification
- Custom Multi-Layer Perceptron (MLP).
- Uses 42 normalized landmark coordinate features.
- Classifies 7 deployed hand gesture classes.
- Trained using prepared HG14 gesture samples.

## Recognition Pipeline

```text
Live Camera Input
       ↓
Hand Landmark Detection
       ↓
21 Hand Landmarks
       ↓
42 Normalized Coordinates
       ↓
Gesture Classification
       ↓
Predicted Gesture + Confidence
       ↓
Flutter UI
```

## Technology Stack

- Flutter
- Dart
- TensorFlow Lite
- Python (AI model development)
- TensorFlow & Keras
- OpenCV
- Camera Integration

## Project Repositories

**AI/ML Model Development:**  
[HandGestureAI-ML](https://github.com/your-username/HandGestureAI-ML)

This repository contains the Python-based model development, training workflows, dataset preparation, evaluation and TensorFlow Lite conversion.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android device or emulator with camera support

### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/NeuralVision-Flutter.git
```

2. Navigate to the project:

```bash
cd NeuralVision-Flutter
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Model Assets

The application uses TensorFlow Lite model files stored in:

```text
assets/
└── flutter_assets/
    ├── hand_landmarks.tflite
    └── gesture_classifier.tflite
```

These models are exported from the Python AI/ML development project and integrated into the Flutter application.

## Application Goal

To demonstrate how custom-trained deep learning models can be integrated into a Flutter mobile application to achieve real-time hand tracking and gesture recognition directly on-device.

---

**Neural Vision | Custom AI Models • Computer Vision • Mobile AI**