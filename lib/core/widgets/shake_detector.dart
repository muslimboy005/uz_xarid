import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Qurilma silkitilganini aniqlovchi va [onShake] ni chaqiruvchi wrapper.
///
/// Akselerometr oqimini kuzatadi: g-kuch [shakeThresholdGravity] dan oshib,
/// [shakeCountResetMs] oralig'ida [requiredShakeCount] marta takrorlansa,
/// silkitish deb hisoblanadi. Ketma-ket noto'g'ri ishga tushishlarni oldini
/// olish uchun har bir aniqlashdan keyin [minShakeIntervalMs] kutiladi.
class ShakeDetector extends StatefulWidget {
  const ShakeDetector({
    super.key,
    required this.child,
    required this.onShake,
    this.shakeThresholdGravity = 2.5,
    this.requiredShakeCount = 3,
    this.minShakeIntervalMs = 2000,
    this.shakeCountResetMs = 1000,
  });

  final Widget child;

  /// Silkitish aniqlanganda chaqiriladi.
  final VoidCallback onShake;

  /// Silkitish deb hisoblanish uchun minimal g-kuch (1 g ≈ tinch holat).
  final double shakeThresholdGravity;

  /// Ishga tushish uchun kerakli ketma-ket silkitishlar soni.
  final int requiredShakeCount;

  /// Bir aniqlashdan keyingi keyingi aniqlashgacha kutish (ms).
  final int minShakeIntervalMs;

  /// Hisoblagich nolga tushadigan tinchlik oralig'i (ms).
  final int shakeCountResetMs;

  @override
  State<ShakeDetector> createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastShakeTime;
  DateTime? _lastForceTime;
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _subscription =
        accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
            .listen(_onAccelerometer, onError: (_) {});
  }

  void _onAccelerometer(AccelerometerEvent event) {
    const g = 9.80665;
    final gX = event.x / g;
    final gY = event.y / g;
    final gZ = event.z / g;
    final gForce = math.sqrt(gX * gX + gY * gY + gZ * gZ);

    if (gForce <= widget.shakeThresholdGravity) return;

    final now = DateTime.now();

    // Bitta keskin harakatni bir necha marta sanab yubormaslik uchun.
    if (_lastForceTime != null &&
        now.difference(_lastForceTime!).inMilliseconds < 100) {
      return;
    }

    // Yaqinda silkitish aniqlangan bo'lsa, biroz kutamiz (cooldown).
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!).inMilliseconds <
            widget.minShakeIntervalMs) {
      return;
    }

    // Uzoq tanaffusdan keyin hisoblagichni boshidan boshlaymiz.
    if (_lastForceTime != null &&
        now.difference(_lastForceTime!).inMilliseconds >
            widget.shakeCountResetMs) {
      _shakeCount = 0;
    }

    _lastForceTime = now;
    _shakeCount++;

    if (_shakeCount >= widget.requiredShakeCount) {
      _shakeCount = 0;
      _lastShakeTime = now;
      widget.onShake();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
