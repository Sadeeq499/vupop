import 'package:flutter/material.dart';

class TopRightNotchContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double notchSize;
  final EdgeInsets? margin;

  const TopRightNotchContainer({
    Key? key,
    required this.child,
    this.color = Colors.white,
    this.borderRadius = 20,
    this.notchSize = 15,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: CustomPaint(
        painter: TopRightNotchPainter(
          color: color,
          borderRadius: borderRadius,
          notchSize: notchSize,
        ),
        child: Container(
          child: child,
        ),
      ),
    );
  }
}

class TopRightNotchPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double notchSize;

  TopRightNotchPainter({
    required this.color,
    required this.borderRadius,
    required this.notchSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from top-left, going clockwise
    path.moveTo(borderRadius, 0);

    // Top edge to the notch start
    path.lineTo(size.width - borderRadius - notchSize, 0);

    // Top-right corner before notch
    path.arcToPoint(
      Offset(size.width - notchSize, borderRadius),
      radius: Radius.circular(borderRadius),
    );

    // Create the notch (triangle pointing top-right)
    path.lineTo(size.width - notchSize, borderRadius);
    path.lineTo(size.width, 0); // Point of the notch
    path.lineTo(size.width - notchSize / 2, borderRadius + notchSize / 2);
    path.lineTo(size.width - notchSize, borderRadius + notchSize);

    // Right edge
    path.lineTo(size.width - notchSize, size.height - borderRadius);

    // Bottom-right corner
    path.arcToPoint(
      Offset(size.width - borderRadius - notchSize, size.height),
      radius: Radius.circular(borderRadius),
    );

    // Bottom edge
    path.lineTo(borderRadius, size.height);

    // Bottom-left corner
    path.arcToPoint(
      Offset(0, size.height - borderRadius),
      radius: Radius.circular(borderRadius),
    );

    // Left edge
    path.lineTo(0, borderRadius);

    // Top-left corner
    path.arcToPoint(
      Offset(borderRadius, 0),
      radius: Radius.circular(borderRadius),
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
