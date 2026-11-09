
class GestureResult {
  final String label;
  final double confidence;
  final List<List<double>> landmarks;

  const GestureResult({
    required this.label,
    required this.confidence,
    required this.landmarks,
  });
}
