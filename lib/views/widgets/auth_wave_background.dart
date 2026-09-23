import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class AuthWaveBackground extends StatelessWidget {
  final double height;
  const AuthWaveBackground({super.key, this.height = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _AuthWavePainter(),
      ),
    );
  }
}

class _AuthWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Layer 1: Back subtle wave (lightest sky blue)
    final path1 = Path();
    path1.moveTo(0, h * 0.45);
    path1.cubicTo(
      w * 0.25, h * 0.15,
      w * 0.65, h * 0.75,
      w, h * 0.35,
    );
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();

    final paint1 = Paint()
      ..color = AppColors.waveLight1.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path1, paint1);

    // Layer 2: Middle wave
    final path2 = Path();
    path2.moveTo(0, h * 0.65);
    path2.cubicTo(
      w * 0.35, h * 0.85,
      w * 0.70, h * 0.30,
      w, h * 0.55,
    );
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    final paint2 = Paint()
      ..color = AppColors.waveLight2.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path2, paint2);

    // Layer 3: Foreground soft wave
    final path3 = Path();
    path3.moveTo(0, h * 0.78);
    path3.cubicTo(
      w * 0.40, h * 0.55,
      w * 0.75, h * 0.85,
      w, h * 0.68,
    );
    path3.lineTo(w, h);
    path3.lineTo(0, h);
    path3.close();

    final paint3 = Paint()
      ..color = AppColors.waveLight1.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
