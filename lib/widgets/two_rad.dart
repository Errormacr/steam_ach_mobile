import 'package:flutter/material.dart';

import 'rad_prog.dart';

class NestedRadialProgress extends StatefulWidget {
  final double widthProgress;
  final double heightProgress;
  final String progress;

  const NestedRadialProgress({
    Key? key,
    required this.widthProgress,
    required this.heightProgress,
    required this.progress,
  }) : super(key: key);

  @override
  State<NestedRadialProgress> createState() {
    return _NestedRadialProgressState();
  }
}

class _NestedRadialProgressState extends State<NestedRadialProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bigProgressAnimation;
  late Animation<double> _smallProgressAnimation;
  late String _progress;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    int integerPart = double.parse(widget.progress).truncate();
    double floatPart = double.parse(widget.progress) - integerPart;
    _bigProgressAnimation =
        Tween<double>(begin: 0.0, end: floatPart).animate(_animationController);
    _smallProgressAnimation = Tween<double>(begin: 0.0, end: integerPart / 100)
        .animate(_animationController);
    _progress = widget.progress;

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant NestedRadialProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.animateTo(1.0,
        duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.widthProgress;
    double height = widget.heightProgress;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: AnimatedBuilder(
            animation: _bigProgressAnimation,
            builder: (context, child) {
              return RadialProgress(
                progress: _bigProgressAnimation.value,
                progressColor: Colors.blue,
                strokeWidth: 7.0 * (height + width) / 400,
                backgroundColor: Colors.grey,
              );
            },
          ),
        ),
        Positioned(
          top: 12 * (height / 200),
          left: 12 * (width / 200),
          child: SizedBox(
            width: width * 0.88,
            height: height * 0.88,
            child: AnimatedBuilder(
              animation: _smallProgressAnimation,
              builder: (context, child) {
                return RadialProgress(
                  progress: _smallProgressAnimation.value,
                  progressColor: Colors.red,
                  strokeWidth: 7.0 * (height + width) / 400,
                  backgroundColor: Colors.grey,
                );
              },
            ),
          ),
        ),
        Text(
          _progress,
          style: const TextStyle(fontSize: 24),
        )
      ],
    );
  }
}
