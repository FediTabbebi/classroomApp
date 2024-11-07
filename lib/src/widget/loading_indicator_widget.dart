import 'dart:math' as math;

import 'package:flutter/material.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  final double size;
  final Color? color;

  const LoadingIndicatorWidget({
    super.key,
    this.color,
    required this.size,
  });

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2200,
      ),
    )..repeat();
  }

  Widget _rotatingDots({
    required bool visible,
    required Color color,
    required double dotSize,
    required double offset,
    required double initialAngle,
    required double finalAngle,
    required Interval interval,
  }) {
    final double angle = _animationController.eval(
      Tween<double>(begin: initialAngle, end: finalAngle),
      curve: interval,
    );
    return Visibility(
      visible: visible,
      child: Transform.rotate(
        angle: angle,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.translate(
              offset: Offset(-offset, 0),
              child: DrawDot.circular(
                dotSize: dotSize,
                color: color,
              ),
            ),
            Transform.translate(
              offset: Offset(offset, 0),
              child: DrawDot.circular(
                dotSize: dotSize,
                color: color,
              ),
            ),
            Transform.translate(
              offset: Offset(0, -offset),
              child: DrawDot.circular(
                dotSize: dotSize,
                color: color,
              ),
            ),
            Transform.translate(
              offset: Offset(0, offset),
              child: DrawDot.circular(
                dotSize: dotSize,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatingDots({
    required bool fixedSize,
    required Color color,
    required double dotInitialSize,
    required double initialOffset,
    required double finalOffset,
    required Interval interval,
    double? dotFinalSize,
    required bool visible,
  }) {
    final double dotSize = fixedSize
        ? dotInitialSize
        : _animationController.eval(
            Tween<double>(begin: dotInitialSize, end: dotFinalSize),
            curve: interval,
          );

    return Visibility(
      visible: visible,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.translate(
            offset: _animationController.eval(
              Tween<Offset>(
                begin: Offset(-initialOffset, 0),
                end: Offset(-finalOffset, 0),
              ),
              curve: interval,
            ),
            child: DrawDot.circular(
              dotSize: dotSize,
              color: color,
            ),
          ),
          Transform.translate(
            offset: _animationController.eval(
              Tween<Offset>(
                begin: Offset(initialOffset, 0),
                end: Offset(finalOffset, 0),
              ),
              curve: interval,
            ),
            child: DrawDot.circular(
              dotSize: dotSize,
              color: color,
            ),
          ),
          Transform.translate(
            offset: _animationController.eval(
              Tween<Offset>(
                begin: Offset(0, -initialOffset),
                end: Offset(0, -finalOffset),
              ),
              curve: interval,
            ),
            child: DrawDot.circular(
              dotSize: dotSize,
              color: color,
            ),
          ),
          Transform.translate(
            offset: _animationController.eval(
              Tween<Offset>(
                begin: Offset(0, initialOffset),
                end: Offset(0, finalOffset),
              ),
              curve: interval,
            ),
            child: DrawDot.circular(
              dotSize: dotSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final Color color = widget.color ?? Theme.of(context).colorScheme.primary;
    final double dotMaxSize = size * 0.30;
    final double dotMinSize = size * 0.14;
    final double maxOffset = size * 0.35;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Transform.rotate(
                angle: _animationController.evalDouble(
                  to: math.pi / 8,
                  begin: 0.0,
                  end: 0.18,
                ),
                child: _animatingDots(
                  visible: _animationController.value <= 0.18,
                  fixedSize: true,
                  color: color,
                  dotInitialSize: dotMaxSize,
                  initialOffset: maxOffset,
                  finalOffset: 0,
                  interval: const Interval(
                    0.0,
                    0.18,
                    curve: Curves.easeInQuart,
                  ),
                ),
              ),
              Transform.rotate(
                angle: _animationController.evalDouble(
                  from: math.pi / 8,
                  to: math.pi / 4,
                  begin: 0.18,
                  end: 0.36,
                ),
                child: _animatingDots(
                  visible: _animationController.value >= 0.18 && _animationController.value <= 0.36,
                  fixedSize: false,
                  color: color,
                  dotInitialSize: dotMaxSize,
                  dotFinalSize: dotMinSize,
                  initialOffset: 0,
                  finalOffset: maxOffset,
                  interval: const Interval(
                    0.18,
                    0.36,
                    curve: Curves.easeOutQuart,
                  ),
                ),
              ),
              _rotatingDots(
                visible: _animationController.value >= 0.36 && _animationController.value <= 0.60,
                color: color,
                dotSize: dotMinSize,
                initialAngle: math.pi / 4,
                finalAngle: 7 * math.pi / 4,
                interval: const Interval(
                  0.36,
                  0.60,
                  curve: Curves.easeInOutSine,
                ),
                offset: maxOffset,
              ),
              Transform.rotate(
                angle: _animationController.evalDouble(
                  from: 7 * math.pi / 4,
                  to: 2 * math.pi,
                  begin: 0.6,
                  end: 0.78,
                ),
                child: _animatingDots(
                  visible: _animationController.value >= 0.60 && _animationController.value <= 0.78,
                  fixedSize: false,
                  color: color,
                  dotInitialSize: dotMinSize,
                  dotFinalSize: dotMaxSize,
                  initialOffset: maxOffset,
                  finalOffset: 0,
                  interval: const Interval(
                    0.60,
                    0.78,
                    curve: Curves.easeInQuart,
                  ),
                ),
              ),
              _animatingDots(
                visible: _animationController.value >= 0.78 && _animationController.value <= 1.0,
                fixedSize: true,
                color: color,
                dotInitialSize: dotMaxSize,
                initialOffset: 0,
                finalOffset: maxOffset,
                interval: const Interval(
                  0.78,
                  0.96,
                  curve: Curves.easeOutQuart,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class DrawDot extends StatelessWidget {
  final double width;
  final double height;
  final bool circular;
  final Color color;

  const DrawDot.circular({
    super.key,
    required double dotSize,
    required this.color,
  })  : width = dotSize,
        height = dotSize,
        circular = true;

  const DrawDot.elliptical({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  }) : circular = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }
}

extension LoadingAnimationControllerX on AnimationController {
  T eval<T>(Tween<T> tween, {Curve curve = Curves.linear}) => tween.transform(curve.transform(value));

  double evalDouble({
    double from = 0,
    double to = 1,
    double begin = 0,
    double end = 1,
    Curve curve = Curves.linear,
  }) {
    return eval(
      Tween<double>(begin: from, end: to),
      curve: Interval(begin, end, curve: curve),
    );
  }
}
