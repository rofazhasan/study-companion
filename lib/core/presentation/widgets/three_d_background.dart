import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThreeDBackground extends StatefulWidget {
  final Widget child;
  final bool enableBlur;

  const ThreeDBackground({
    super.key,
    required this.child,
    this.enableBlur = true,
  });

  @override
  State<ThreeDBackground> createState() => _ThreeDBackgroundState();
}

class _ThreeDBackgroundState extends State<ThreeDBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Deep Formal Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2027), // Deep Blue/Black
                Color(0xFF203A43), // Formal Teal/Grey
                Color(0xFF2C5364), // Slate Blue
              ],
            ),
          ),
        ),

        // 2. Animated 3D Shapes (Simulated with Gradients & Shadows)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Large Sphere Top Left
                _buildFloatingShape(
                  alignment: const Alignment(-0.8, -0.6),
                  size: 200,
                  color: Colors.purple.withOpacity(0.3),
                  controllerValue: _controller.value,
                  speed: 1.0,
                ),
                // Medium Cube Bottom Right
                _buildFloatingShape(
                  alignment: const Alignment(0.8, 0.6),
                  size: 150,
                  color: Colors.blue.withOpacity(0.3),
                  controllerValue: _controller.value,
                  speed: 1.5,
                  isCube: true,
                ),
                // Small Sphere Center Right
                _buildFloatingShape(
                  alignment: const Alignment(0.5, -0.2),
                  size: 100,
                  color: Colors.teal.withOpacity(0.2),
                  controllerValue: _controller.value,
                  speed: 0.8,
                ),
              ],
            );
          },
        ),

        // 3. Glass Blur Overlay (Optional)
        if (widget.enableBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),

        // 4. Content
        widget.child,
      ],
    );
  }

  Widget _buildFloatingShape({
    required Alignment alignment,
    required double size,
    required Color color,
    required double controllerValue,
    required double speed,
    bool isCube = false,
  }) {
    // Calculate movement based on controller value
    final double offsetX = math.sin((controllerValue * 2 * math.pi * speed) + (alignment.x * 10)) * 30;
    final double offsetY = math.cos((controllerValue * 2 * math.pi * speed) + (alignment.y * 10)) * 30;

    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform.rotate(
          angle: isCube ? controllerValue * 2 * math.pi * speed : 0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isCube ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isCube ? BorderRadius.circular(20) : null,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.0),
                ],
                center: const Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
