
import 'package:flutter/material.dart';

import '../controllers/gesture_controller.dart';
import '../widget/camera_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GestureController controller;

  static const Color background = Color(0xFF070B14);
  static const Color panel = Color(0xFF101827);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color violet = Color(0xFF9D6BFF);
  static const Color muted = Color(0xFF8493A8);

  @override
  void initState() {
    super.initState();
    controller = GestureController();
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String formatLabel(String label) {
    const display = {
      'five': 'OPEN HAND',
      'flat_hand': 'FLAT HAND',
    };

    return display[label] ??
        label.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final result = controller.result;
        final isDetected = result != null;
        final confidence =
            (result?.confidence ?? 0.0).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: controller.isLoading
                ? _loadingScreen()
                : controller.error != null
                    ? _errorScreen(controller.error!)
                    : controller.cameraController == null ||
                            !controller.cameraController!.value.isInitialized
                        ? _cameraUnavailable()
                        : _mainInterface(
                            isDetected: isDetected,
                            confidence: confidence,
                          ),
          ),
        );
      },
    );
  }

Widget _mainInterface({
  required bool isDetected,
  required double confidence,
}) {
  final result = controller.result;

  return Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 12),

        // Camera gets most of the available screen space.
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cyan.withOpacity(0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(0.07),
                  blurRadius: 20,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraView(
                    controller: controller.cameraController!,
                    landmarks: controller.landmarks,
                  ),

                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            background.withOpacity(0.55),
                            Colors.transparent,
                            Colors.transparent,
                            background.withOpacity(0.45),
                          ],
                          stops: const [0, 0.18, 0.78, 1],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 13,
                    left: 13,
                    right: 13,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _hudTag(
                          icon: Icons.radar_rounded,
                          text: 'AI VISION',
                        ),
                        _statusIndicator(isDetected),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 13,
                    left: 13,
                    right: 13,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _cameraInfo(
                          Icons.scatter_plot_rounded,
                          '21 LANDMARKS',
                        ),
                        _cameraInfo(
                          Icons.memory_rounded,
                          'TFLITE ACTIVE',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        _predictionPanel(
          isDetected: isDetected,
          confidence: confidence,
          label: result == null
              ? 'SCANNING FOR HAND'
              : formatLabel(result.label),
        ),

        const SizedBox(height: 10),

        _modelStatus(),
      ],
    ),
  );
}


  Widget _header() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [cyan, violet],
            ),
            boxShadow: [
              BoxShadow(
                color: cyan.withOpacity(0.22),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: background,
            size: 27,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEURAL VISION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'HAND GESTURE INTELLIGENCE',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: cyan.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cyan.withOpacity(0.3),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, color: cyan, size: 7),
              SizedBox(width: 6),
              Text(
                'ONLINE',
                style: TextStyle(
                  color: cyan,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVE ANALYSIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Real-time hand landmark detection',
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Icon(
          Icons.graphic_eq_rounded,
          color: cyan.withOpacity(0.8),
          size: 25,
        ),
      ],
    );
  }

  Widget _hudTag({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background.withOpacity(0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cyan.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: cyan, size: 14),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIndicator(bool detected) {
    final color = detected ? cyan : violet;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background.withOpacity(0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            detected ? Icons.check_circle : Icons.radar,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            detected ? 'DETECTED' : 'SCANNING',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: cyan, size: 13),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

Widget _predictionPanel({
  required bool isDetected,
  required double confidence,
  required String label,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (isDetected ? cyan : violet).withOpacity(0.25),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DETECTED GESTURE',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),
            Icon(
              Icons.auto_awesome,
              color: isDetected ? cyan : violet,
              size: 17,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDetected ? cyan : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: isDetected ? cyan : muted,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              isDetected ? cyan : violet,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _modelStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1320),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _ModelItem(
              title: 'LANDMARK AI',
              subtitle: '21 POINTS',
              icon: Icons.scatter_plot_rounded,
              color: cyan,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _ModelItem(
              title: 'GESTURE AI',
              subtitle: '7 CLASSES',
              icon: Icons.account_tree_rounded,
              color: violet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingScreen() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_rounded, color: cyan, size: 55),
          SizedBox(height: 20),
          CircularProgressIndicator(color: cyan),
          SizedBox(height: 18),
          Text(
            'INITIALIZING NEURAL ENGINE',
            style: TextStyle(
              color: cyan,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Loading vision models...',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _errorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 45,
            ),
            const SizedBox(height: 15),
            const Text(
              'NEURAL ENGINE ERROR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraUnavailable() {
    return const Center(
      child: Text(
        'CAMERA UNAVAILABLE',
        style: TextStyle(
          color: cyan,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _ModelItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ModelItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8493A8),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 35,
      color: Colors.white.withOpacity(0.12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
