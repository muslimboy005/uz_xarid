import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// UZXARID AI yordamchi maskoti — to'liq tanali (boshi, ko'zlari, antennasi,
/// tanasi, qo'llari, oyoqlari) robot. Bitta [CustomPainter] orqali ikkala
/// holatda ham chiziladi:
///  * `flat: true`  — appbar leadingidagi kichik 2D variant (soya/gloss yo'q);
///  * `walk: true`   — bodyda aylanib yuruvchi katta "3D" variant.
///
/// Barcha harakat bitta `_idle` tickeridan (sin/cos fazalar bilan) olinadi,
/// ko'z pirpirashi alohida qisqa kontroller bilan tasodifiy oraliqda bo'ladi.
class RobotMascot extends StatefulWidget {
  const RobotMascot({
    super.key,
    this.size = const Size(96, 132),
    this.flat = false,
    this.walk = false,
    this.lookX = 0.0,
  });

  /// Chizma o'lchami (portret nisbati ~0.73 tavsiya etiladi).
  final Size size;

  /// Tekis 2D variant (leading uchun) — blur/gloss/soya o'chiriladi.
  final bool flat;

  /// Yurish/suzish rejimi — amplitudalar kuchayadi (roamer uchun).
  final bool walk;

  /// Ko'z/bosh harakat yo'nalishi (-1..1). Roamer yurish tomoniga "qaraydi".
  final double lookX;

  @override
  State<RobotMascot> createState() => _RobotMascotState();
}

class _RobotMascotState extends State<RobotMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _blink;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce == _reducedMotion && (reduce || _idle.isAnimating)) return;
    _reducedMotion = reduce;
    if (reduce) {
      _idle.stop();
      _idle.value = 0.25; // neytral, tinch poza
    } else {
      if (!_idle.isAnimating) _idle.repeat();
      _scheduleBlink();
    }
  }

  void _scheduleBlink() {
    if (_reducedMotion) return;
    final delay = 2200 + math.Random().nextInt(2800);
    Future.delayed(Duration(milliseconds: delay), () async {
      if (!mounted || _reducedMotion) return;
      await _blink.forward(from: 0);
      if (!mounted) return;
      await _blink.reverse();
      if (mounted) _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _idle.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = RobotPalette.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _blink]),
        builder: (context, _) {
          final p = 2 * math.pi * _idle.value;
          final blink = Curves.easeInOut.transform(_blink.value);

          double bob, armSwing, legSwing, walkPhase, antennaGlow, headTilt, wave;
          if (widget.walk) {
            walkPhase = p * 2;
            bob = math.sin(p * 2);
            legSwing = math.sin(p * 2) * 0.16;
            armSwing = math.sin(p * 2 + math.pi) * 0.22;
            antennaGlow = 0.5 + 0.5 * math.sin(p * 3);
            headTilt = math.sin(p * 0.5) * 0.05 + widget.lookX * 0.05;
            wave = math.max(0.0, math.sin(p * 1.5)) * 0.4;
          } else {
            walkPhase = 0;
            bob = math.sin(p) * (widget.flat ? 0.4 : 0.5);
            legSwing = math.sin(p) * 0.02;
            armSwing = math.sin(p) * 0.06;
            antennaGlow = 0.5 + 0.5 * math.sin(p * 1.3 + math.pi / 3);
            headTilt = math.sin(p * 0.5) * 0.035 + widget.lookX * 0.05;
            wave = 0;
          }

          return CustomPaint(
            size: widget.size,
            isComplex: !widget.flat,
            painter: RobotMascotPainter(
              palette: palette,
              bob: bob,
              blink: blink,
              armSwing: armSwing,
              legSwing: legSwing,
              headTilt: headTilt,
              antennaGlow: antennaGlow,
              walkPhase: walkPhase,
              lookX: widget.lookX,
              wave: wave,
              flat: widget.flat,
            ),
          );
        },
      ),
    );
  }
}

/// Robotning rang palitrasi — faqat `isDark` ga bog'liq, shu sababli tenglik
/// ham aynan shunga asoslanadi (painter qayta chizishni to'g'ri aniqlaydi).
@immutable
class RobotPalette {
  const RobotPalette({
    required this.isDark,
    required this.bodyLight,
    required this.bodyMid,
    required this.bodyBase,
    required this.bodyRim,
    required this.headLight,
    required this.headMid,
    required this.headDeep,
    required this.panelTop,
    required this.panelBottom,
    required this.panelLine,
    required this.bodyStroke,
    required this.faceTop,
    required this.faceBottom,
    required this.eyeGlow,
    required this.eyeCore,
    required this.eyeShine,
    required this.pupil,
    required this.mouth,
    required this.stalkLight,
    required this.stalkDeep,
    required this.bulbHot,
    required this.bulbBase,
    required this.bulbGlow,
    required this.limbLight,
    required this.limbDeep,
    required this.jointLight,
    required this.jointDeep,
    required this.handLit,
    required this.handBase,
    required this.metalHighlight,
    required this.coreHot,
    required this.coreCool,
    required this.dropShadow,
  });

  final bool isDark;
  final Color bodyLight, bodyMid, bodyBase, bodyRim;
  final Color headLight, headMid, headDeep;
  final Color panelTop, panelBottom, panelLine, bodyStroke;
  final Color faceTop, faceBottom;
  final Color eyeGlow, eyeCore, eyeShine, pupil, mouth;
  final Color stalkLight, stalkDeep, bulbHot, bulbBase, bulbGlow;
  final Color limbLight, limbDeep, jointLight, jointDeep, handLit, handBase;
  final Color metalHighlight, coreHot, coreCool, dropShadow;

  factory RobotPalette.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static const _cyan = Color(0xFF36B3E4);

  static final RobotPalette _light = RobotPalette(
    isDark: false,
    bodyLight: const Color(0xFF9FC4FF),
    bodyMid: const Color(0xFF4F8BF0),
    bodyBase: const Color(0xFF2E6BD6),
    bodyRim: const Color(0xFFBFE0FF).withValues(alpha: 0.65),
    headLight: const Color(0xFFFFFFFF),
    headMid: const Color(0xFFECF3FF),
    headDeep: const Color(0xFFDCE7F5),
    panelTop: const Color(0xFFFFFFFF),
    panelBottom: const Color(0xFFDCE8F7),
    panelLine: const Color(0xFF0077FF).withValues(alpha: 0.20),
    bodyStroke: const Color(0xFF143A78).withValues(alpha: 0.30),
    faceTop: const Color(0xFF0A2A4D),
    faceBottom: const Color(0xFF06203F),
    eyeGlow: _cyan.withValues(alpha: 0.55),
    eyeCore: const Color(0xFF7FE9FF),
    eyeShine: const Color(0xFFFFFFFF),
    pupil: const Color(0xFF053B6E),
    mouth: _cyan.withValues(alpha: 0.9),
    stalkLight: const Color(0xFFD7DEE8),
    stalkDeep: const Color(0xFFB0B5BB),
    bulbHot: const Color(0xFFBFF3FF),
    bulbBase: _cyan,
    bulbGlow: _cyan.withValues(alpha: 0.55),
    limbLight: const Color(0xFF9FB4CC),
    limbDeep: const Color(0xFF5E7B9E),
    jointLight: const Color(0xFFC9DBF2),
    jointDeep: const Color(0xFF5C84C4),
    handLit: const Color(0xFF8FB8FF),
    handBase: const Color(0xFF2E6BD6),
    metalHighlight: const Color(0xFFFFFFFF).withValues(alpha: 0.85),
    coreHot: const Color(0xFFBFF3FF),
    coreCool: _cyan,
    dropShadow: const Color(0xFF0A1A33).withValues(alpha: 0.18),
  );

  static final RobotPalette _dark = RobotPalette(
    isDark: true,
    bodyLight: const Color(0xFF5C90E8),
    bodyMid: const Color(0xFF2E6BD6),
    bodyBase: const Color(0xFF1E4FA8),
    bodyRim: _cyan.withValues(alpha: 0.55),
    headLight: const Color(0xFFD7DEE8),
    headMid: const Color(0xFFB7C3D4),
    headDeep: const Color(0xFF9FB0C4),
    panelTop: const Color(0xFFD9E2EE),
    panelBottom: const Color(0xFF9AA9BD),
    panelLine: const Color(0xFF0077FF).withValues(alpha: 0.28),
    bodyStroke: const Color(0xFF0B254D).withValues(alpha: 0.55),
    faceTop: const Color(0xFF0B2238),
    faceBottom: const Color(0xFF05131F),
    eyeGlow: _cyan.withValues(alpha: 0.70),
    eyeCore: const Color(0xFF9FF0FF),
    eyeShine: const Color(0xFFFFFFFF),
    pupil: const Color(0xFF042033),
    mouth: _cyan.withValues(alpha: 0.9),
    stalkLight: const Color(0xFF9AA3AE),
    stalkDeep: const Color(0xFF6B7280),
    bulbHot: const Color(0xFFBFF3FF),
    bulbBase: _cyan,
    bulbGlow: _cyan.withValues(alpha: 0.70),
    limbLight: const Color(0xFF6E83A0),
    limbDeep: const Color(0xFF3C546F),
    jointLight: const Color(0xFF8FA6C4),
    jointDeep: const Color(0xFF334963),
    handLit: const Color(0xFF5C90E8),
    handBase: const Color(0xFF1E4FA8),
    metalHighlight: const Color(0xFFFFFFFF).withValues(alpha: 0.55),
    coreHot: const Color(0xFFBFF3FF),
    coreCool: _cyan,
    dropShadow: const Color(0xFF000000).withValues(alpha: 0.40),
  );

  @override
  bool operator ==(Object other) =>
      other is RobotPalette && other.isDark == isDark;

  @override
  int get hashCode => isDark.hashCode;
}

class RobotMascotPainter extends CustomPainter {
  RobotMascotPainter({
    required this.palette,
    required this.bob,
    required this.blink,
    required this.armSwing,
    required this.legSwing,
    required this.headTilt,
    required this.antennaGlow,
    required this.walkPhase,
    required this.lookX,
    required this.wave,
    required this.flat,
  });

  final RobotPalette palette;
  final double bob; // -1..1
  final double blink; // 0..1
  final double armSwing; // rad
  final double legSwing; // rad
  final double headTilt; // rad
  final double antennaGlow; // 0..1
  final double walkPhase;
  final double lookX; // -1..1
  final double wave; // 0..0.5 rad
  final bool flat;

  late Size _s;

  Offset _p(double nx, double ny) => Offset(nx * _s.width, ny * _s.height);
  double _l(double n) => n * _s.shortestSide;

  @override
  void paint(Canvas canvas, Size size) {
    _s = size;

    // 0) Yer soyasi (bob ko'tarilganda kichrayadi).
    if (!flat) {
      final liftedW = (0.42 - 0.10 * bob.clamp(0.0, 1.0)) * size.width;
      final shadowRect = Rect.fromCenter(
        center: _p(0.5, 0.95),
        width: liftedW,
        height: 0.06 * size.height,
      );
      canvas.drawOval(
        shadowRect,
        Paint()
          ..color = palette.dropShadow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _l(0.02)),
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: _p(0.5, 0.95),
          width: 0.40 * size.width,
          height: 0.05 * size.height,
        ),
        Paint()..color = palette.dropShadow.withValues(alpha: 0.12),
      );
    }

    // 1) Butun figura bob bilan suzadi (soya tashqarida qoladi).
    final bobPx = bob * size.height * (flat ? 0.012 : 0.025);
    canvas.save();
    canvas.translate(0, -bobPx);

    // 2) Uzoq (chap) qo'l va oyoq — tana ortida, biroz to'qroq/kichikroq.
    _drawLeg(canvas, side: -1, swing: -legSwing, far: true);
    _drawArm(canvas, side: -1, swing: armSwing, far: true);

    // 3) Tana + ko'krak paneli.
    _drawTorso(canvas);

    // 4) Yaqin (o'ng) oyoq va qo'l — tana ustida.
    _drawLeg(canvas, side: 1, swing: legSwing, far: false);
    _drawArm(canvas, side: 1, swing: -armSwing + wave, far: false);

    // 5) Bo'yin.
    _fillVolume(
      canvas,
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: _p(0.5, 0.41),
          width: 0.16 * size.width,
          height: 0.05 * size.height,
        ),
        Radius.circular(_l(0.02)),
      ),
      palette.stalkDeep,
      palette.stalkDeep,
      palette.limbDeep,
    );

    // 6) Bosh guruhi (headTilt bilan biroz egiladi).
    final headCenter = _p(0.5, 0.235);
    canvas.save();
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(headTilt);
    canvas.translate(-headCenter.dx, -headCenter.dy);
    _drawHead(canvas);
    canvas.restore();

    // 7) Antenna.
    _drawAntenna(canvas);

    canvas.restore();
  }

  // ---- Tana ----------------------------------------------------------------

  void _drawTorso(Canvas canvas) {
    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: _p(0.5, 0.565),
        width: 0.46 * _s.width,
        height: 0.27 * _s.height,
      ),
      Radius.circular(_l(0.12)),
    );
    _rim(canvas, torso);
    _fillVolume(canvas, torso, palette.bodyLight, palette.bodyMid,
        palette.bodyBase);
    _gloss(canvas, torso);
    _keyline(canvas, torso);

    // Ko'krak paneli (ichkariga botgan — teskari gradient).
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: _p(0.5, 0.575),
        width: 0.28 * _s.width,
        height: 0.18 * _s.height,
      ),
      Radius.circular(_l(0.09)),
    );
    _fillVolume(canvas, panel, palette.panelTop, palette.panelBottom,
        palette.panelBottom,
        concave: true);
    if (!flat) {
      canvas.drawRRect(
        panel.shift(Offset(0, _l(0.006))),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = palette.bodyStroke.withValues(alpha: 0.25),
      );
    }

    // Yurak (reaktor) — antennaGlow bilan pulslaydi.
    final coreCenter = _p(0.5, 0.55);
    final coreR = _l(0.045) * (0.9 + 0.18 * antennaGlow);
    if (!flat) {
      canvas.drawCircle(
        coreCenter,
        coreR * 1.7,
        Paint()
          ..color = palette.coreCool.withValues(alpha: 0.30 * antennaGlow + 0.1)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _l(0.02)),
      );
    }
    canvas.drawCircle(
      coreCenter,
      coreR,
      Paint()
        ..shader = ui.Gradient.radial(
          coreCenter.translate(-coreR * 0.3, -coreR * 0.3),
          coreR * 1.3,
          [palette.coreHot, palette.coreCool],
        ),
    );

    // Status LED chiroqlari.
    if (!flat) {
      for (var i = 0; i < 3; i++) {
        final a = (0.4 + 0.6 * (0.5 + 0.5 * math.sin(walkPhase + i * 2.1)))
            .clamp(0.0, 1.0);
        canvas.drawCircle(
          _p(0.44 + i * 0.06, 0.64),
          _l(0.012),
          Paint()..color = palette.coreCool.withValues(alpha: a),
        );
      }
    }
  }

  // ---- Qo'l/oyoq -----------------------------------------------------------

  void _drawArm(Canvas canvas,
      {required int side, required double swing, required bool far}) {
    final shoulder = _p(0.5 + side * 0.20, 0.47);
    final rest = Offset(side * _l(0.03), _l(0.20));
    final hand = shoulder + _rotate(rest, swing);
    final w = _l(0.075) * (far ? 0.92 : 1.0);

    final light = far ? _mix(palette.limbLight, palette.limbDeep, 0.4)
        : palette.limbLight;
    final deep = far ? _mix(palette.limbDeep, palette.bodyBase, 0.3)
        : palette.limbDeep;

    _capsule(canvas, shoulder, hand, w, light, deep);
    _ball(canvas, shoulder, _l(0.05) * (far ? 0.9 : 1.0),
        far ? _mix(palette.jointLight, palette.jointDeep, 0.4)
            : palette.jointLight,
        palette.jointDeep);
    // Qo'l (mitten).
    _ball(canvas, hand, _l(0.055) * (far ? 0.9 : 1.0),
        far ? _mix(palette.handLit, palette.handBase, 0.4) : palette.handLit,
        palette.handBase);
  }

  void _drawLeg(Canvas canvas,
      {required int side, required double swing, required bool far}) {
    final hip = _p(0.5 + side * 0.09, 0.70);
    final rest = Offset(side * _l(0.004), _l(0.15));
    final foot = hip + _rotate(rest, swing);
    final w = _l(0.085) * (far ? 0.92 : 1.0);

    final light = far ? _mix(palette.limbLight, palette.limbDeep, 0.4)
        : palette.limbLight;
    final deep = far ? _mix(palette.limbDeep, palette.bodyBase, 0.3)
        : palette.limbDeep;

    _capsule(canvas, hip, foot, w, light, deep);
    _ball(canvas, hip, _l(0.04) * (far ? 0.9 : 1.0),
        far ? _mix(palette.jointLight, palette.jointDeep, 0.4)
            : palette.jointLight,
        palette.jointDeep);

    // Oyoq kafti (botinka).
    final boot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: foot.translate(side * _l(0.02), _l(0.01)),
        width: _l(0.13) * (far ? 0.92 : 1.0),
        height: _l(0.06),
      ),
      Radius.circular(_l(0.025)),
    );
    _fillVolume(
      canvas,
      boot,
      far ? _mix(palette.handLit, palette.handBase, 0.4) : palette.handLit,
      palette.handBase,
      palette.handBase,
    );
  }

  // ---- Bosh ----------------------------------------------------------------

  void _drawHead(Canvas canvas) {
    // Quloq podlari.
    for (final side in [-1, 1]) {
      final pod = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: _p(0.5 + side * 0.235, 0.235),
          width: 0.05 * _s.width,
          height: 0.12 * _s.height,
        ),
        Radius.circular(_l(0.025)),
      );
      _fillVolume(canvas, pod, palette.limbLight, palette.limbDeep,
          palette.limbDeep);
    }

    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: _p(0.5, 0.235),
        width: 0.44 * _s.width,
        height: 0.30 * _s.height,
      ),
      Radius.circular(_l(0.11)),
    );
    _rim(canvas, head);
    _fillVolume(canvas, head, palette.headLight, palette.headMid,
        palette.headDeep);
    _gloss(canvas, head);
    _keyline(canvas, head);

    // Vizor (botgan qora ekran).
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: _p(0.5, 0.245),
        width: 0.32 * _s.width,
        height: 0.165 * _s.height,
      ),
      Radius.circular(_l(0.08)),
    );
    _fillVolume(canvas, visor, palette.faceTop, palette.faceBottom,
        palette.faceBottom,
        concave: true);
    if (!flat) {
      // Vizordagi yorug' chiziq (specular).
      canvas.save();
      canvas.clipRRect(visor);
      canvas.drawOval(
        Rect.fromCenter(
          center: _p(0.42, 0.205),
          width: 0.2 * _s.width,
          height: 0.03 * _s.height,
        ),
        Paint()
          ..color = palette.metalHighlight.withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _l(0.008)),
      );
      canvas.restore();
    }

    // Ko'zlar.
    _drawEye(canvas, _p(0.42, 0.245));
    _drawEye(canvas, _p(0.58, 0.245));

    // Og'iz (LED tabassum).
    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _l(0.012)
      ..color = palette.mouth;
    final mouthPath = Path()
      ..moveTo(_p(0.45, 0.30).dx, _p(0.45, 0.30).dy)
      ..quadraticBezierTo(
        _p(0.5, 0.315).dx, _p(0.5, 0.315).dy,
        _p(0.55, 0.30).dx, _p(0.55, 0.30).dy,
      );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawEye(Canvas canvas, Offset center) {
    final eyeW = 0.05 * _s.width;
    final eyeH = 0.08 * _s.height;
    final open = (1 - blink).clamp(0.12, 1.0);

    // Yorug'lik halosi.
    if (!flat) {
      canvas.drawCircle(
        center,
        eyeW * (0.9 + 0.5 * antennaGlow),
        Paint()
          ..color = palette.eyeGlow
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, _l(0.02) * (0.6 + 0.6 * antennaGlow)),
      );
    }

    // Ko'z yadrosi (pirpirashda balandligi kichrayadi).
    final eyeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: eyeW,
        height: eyeH * open,
      ),
      Radius.circular(eyeW / 2),
    );
    canvas.drawRRect(eyeRect, Paint()..color = palette.eyeCore);

    if (blink < 0.5) {
      // Qorachiq (qarash tomoniga siljiydi).
      canvas.drawCircle(
        center.translate(lookX * _l(0.012), 0),
        eyeW * 0.28,
        Paint()..color = palette.pupil,
      );
      // Aks-yorug' (kichik oq nuqta).
      canvas.drawCircle(
        center.translate(eyeW * 0.22, -eyeH * open * 0.22),
        eyeW * 0.16,
        Paint()..color = palette.eyeShine,
      );
    }
  }

  // ---- Antenna -------------------------------------------------------------

  void _drawAntenna(Canvas canvas) {
    final base = _p(0.5, 0.10);
    final tip = _p(0.5, 0.06);
    _capsule(canvas, base, tip, _l(0.018), palette.stalkLight,
        palette.stalkDeep);

    final bulb = _p(0.5, 0.05);
    final r = _l(0.035);
    if (!flat) {
      canvas.drawCircle(
        bulb,
        r * (1.8 + 0.8 * antennaGlow),
        Paint()
          ..color = palette.bulbGlow.withValues(
              alpha: (palette.bulbGlow.a) * (0.5 + 0.5 * antennaGlow))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _l(0.02)),
      );
    } else {
      canvas.drawCircle(
        bulb,
        r * 1.5,
        Paint()..color = palette.bulbGlow.withValues(alpha: 0.4),
      );
    }
    canvas.drawCircle(
      bulb,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          bulb.translate(-r * 0.3, -r * 0.3),
          r * 1.4,
          [palette.bulbHot, palette.bulbBase],
        ),
    );
  }

  // ---- Yordamchi chizish ---------------------------------------------------

  /// To'ldirilgan vertikal gradientli RRect (concave bo'lsa teskari).
  void _fillVolume(Canvas canvas, RRect rr, Color light, Color mid, Color base,
      {bool concave = false}) {
    final r = rr.outerRect;
    final colors = concave ? [base, mid, light] : [light, mid, base];
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = ui.Gradient.linear(
          r.topCenter,
          r.bottomCenter,
          colors,
          const [0.0, 0.45, 1.0],
        ),
    );
  }

  /// Pastki-o'ng tomonda metall "orqa yorug'lik" qoldiradi.
  void _rim(Canvas canvas, RRect rr) {
    if (flat) return;
    final d = _l(0.01);
    canvas.drawRRect(
      rr.shift(Offset(d * 0.6, d)),
      Paint()..color = palette.bodyRim,
    );
  }

  /// Yuqori-chap uchdagi yumshoq oq porlash (silhuetdan tashqariga chiqmaydi).
  void _gloss(Canvas canvas, RRect rr) {
    if (flat) return;
    canvas.save();
    canvas.clipRRect(rr);
    final r = rr.outerRect;
    canvas.drawOval(
      Rect.fromLTWH(
        r.left + r.width * 0.12,
        r.top + r.height * 0.07,
        r.width * 0.55,
        r.height * 0.38,
      ),
      Paint()
        ..color = palette.metalHighlight
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _l(0.012)),
    );
    canvas.restore();
  }

  void _keyline(Canvas canvas, RRect rr) {
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, _l(0.006))
        ..color = palette.bodyStroke,
    );
  }

  void _capsule(
      Canvas canvas, Offset a, Offset b, double w, Color light, Color deep) {
    final bounds = Rect.fromPoints(a, b).inflate(w);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w
        ..shader = ui.Gradient.linear(
          bounds.topLeft,
          bounds.bottomRight,
          [light, deep],
        ),
    );
  }

  void _ball(Canvas canvas, Offset center, double r, Color light, Color deep) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          center.translate(-r * 0.35, -r * 0.35),
          r * 1.25,
          [light, deep],
        ),
    );
  }

  Offset _rotate(Offset v, double a) {
    final ca = math.cos(a), sa = math.sin(a);
    return Offset(v.dx * ca - v.dy * sa, v.dx * sa + v.dy * ca);
  }

  Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  bool shouldRepaint(RobotMascotPainter old) =>
      old.bob != bob ||
      old.blink != blink ||
      old.armSwing != armSwing ||
      old.legSwing != legSwing ||
      old.headTilt != headTilt ||
      old.antennaGlow != antennaGlow ||
      old.walkPhase != walkPhase ||
      old.lookX != lookX ||
      old.wave != wave ||
      old.flat != flat ||
      old.palette != palette;
}
