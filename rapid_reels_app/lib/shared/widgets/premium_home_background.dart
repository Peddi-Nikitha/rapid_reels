import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PremiumHomeBackground extends StatefulWidget {
  const PremiumHomeBackground({super.key});

  @override
  State<PremiumHomeBackground> createState() => _PremiumHomeBackgroundState();
}

class _PremiumHomeBackgroundState extends State<PremiumHomeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return CustomPaint(
              painter: _PremiumHomeBackgroundPainter(t),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumHomeBackgroundPainter extends CustomPainter {
  final double t;

  _PremiumHomeBackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t * 2 * math.pi;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..color = AppColors.background,
    );

    _paintAuroraBand(
      canvas,
      size,
      phase: phase,
      topFactor: 0.18,
      amplitude: size.height * 0.08,
      thickness: size.height * 0.18,
      startColor: AppColors.homeGlowCyan.withValues(alpha: 0.14),
      endColor: AppColors.homeGlowMagenta.withValues(alpha: 0.1),
    );
    _paintAuroraBand(
      canvas,
      size,
      phase: phase + 1.3,
      topFactor: 0.55,
      amplitude: size.height * 0.07,
      thickness: size.height * 0.14,
      startColor: AppColors.homeGlowMagenta.withValues(alpha: 0.09),
      endColor: AppColors.homeGlowCyan.withValues(alpha: 0.07),
    );

    _paintNeonGlow(
      canvas,
      center: Offset(
        size.width * (0.16 + (0.06 * math.sin(phase))),
        size.height * 0.12,
      ),
      radius: size.width * 0.62,
      color: AppColors.homeGlowCyan.withValues(alpha: 0.15),
    );
    _paintNeonGlow(
      canvas,
      center: Offset(
        size.width * (0.92 - (0.05 * math.cos(phase * 0.9))),
        size.height * 0.34,
      ),
      radius: size.width * 0.58,
      color: AppColors.homeGlowMagenta.withValues(alpha: 0.11),
    );
    _paintNeonGlow(
      canvas,
      center: Offset(
        size.width * (0.45 + (0.03 * math.sin(phase * 1.15))),
        size.height * 0.88,
      ),
      radius: size.width * 0.72,
      color: AppColors.homeGlowLime.withValues(alpha: 0.06),
    );

    _paintMicroOrbs(canvas, size, phase);
    _paintVignette(canvas, size);
  }

  void _paintAuroraBand(
    Canvas canvas,
    Size size, {
    required double phase,
    required double topFactor,
    required double amplitude,
    required double thickness,
    required Color startColor,
    required Color endColor,
  }) {
    final topY = size.height * topFactor;
    final leftY = topY + (math.sin(phase) * amplitude);
    final centerY = topY + (math.cos(phase * 1.2) * amplitude * 0.8);
    final rightY = topY + (math.sin((phase * 0.9) + 1.1) * amplitude);
    final bottomOffset = thickness;

    final path = Path()
      ..moveTo(0, leftY)
      ..quadraticBezierTo(size.width * 0.35, centerY, size.width, rightY)
      ..lineTo(size.width, rightY + bottomOffset)
      ..quadraticBezierTo(
        size.width * 0.35,
        centerY + bottomOffset,
        0,
        leftY + bottomOffset,
      )
      ..close();

    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [startColor, endColor],
    ).createShader(Offset.zero & size);

    canvas.drawPath(
      path,
      Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
  }

  void _paintNeonGlow(
    Canvas canvas,
    {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final shader = RadialGradient(
      colors: [
        color,
        color.withValues(alpha: color.a * 0.18),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, Paint()..shader = shader);
  }

  void _paintMicroOrbs(Canvas canvas, Size size, double phase) {
    final points = <Offset>[
      Offset(size.width * 0.12, size.height * 0.22),
      Offset(size.width * 0.84, size.height * 0.18),
      Offset(size.width * 0.28, size.height * 0.66),
      Offset(size.width * 0.74, size.height * 0.74),
    ];
    final colors = [
      AppColors.homeGlowCyan.withValues(alpha: 0.08),
      AppColors.homeGlowMagenta.withValues(alpha: 0.07),
      AppColors.homeGlowLime.withValues(alpha: 0.05),
      AppColors.homeGlowCyan.withValues(alpha: 0.04),
    ];
    for (var i = 0; i < points.length; i++) {
      final drift = Offset(
        12 * math.sin(phase + i),
        10 * math.cos((phase * 0.9) + i),
      );
      _paintNeonGlow(
        canvas,
        center: points[i] + drift,
        radius: size.width * 0.16,
        color: colors[i],
      );
    }
  }

  void _paintVignette(Canvas canvas, Size size) {
    final shader = RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        Colors.transparent,
        AppColors.homeVignette.withValues(alpha: 0.32),
        AppColors.homeVignette.withValues(alpha: 0.62),
      ],
      stops: const [0.6, 0.85, 1.0],
    ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _PremiumHomeBackgroundPainter oldDelegate) =>
      oldDelegate.t != t;
}
