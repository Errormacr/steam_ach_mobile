import 'package:flutter/material.dart';
import 'achievement_img.dart' as ach_front;
import 'background_achievement.dart' as ach_back;

class Achievement extends StatefulWidget {
  final String gameName;
  final String imgUrl;
  final String achievementName;
  final double percentage;
  final int dateOfAch;
  final bool achieved;
  final String description;

  const Achievement({
    Key? key,
    required this.gameName,
    required this.imgUrl,
    required this.achievementName,
    required this.percentage,
    required this.dateOfAch,
    required this.achieved,
    required this.description,
  }) : super(key: key);

  @override
  _AchievementState createState() => _AchievementState();
}

class _AchievementState extends State<Achievement>
    with TickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });

        _isFlipped
            ? _animationController.forward()
            : _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_isFlipped
                  ? _animationController.value * 3.14159265359
                  : _animationController.value * 3.14159265359 * 2),
            child: _isFlipped ? _buildBack() : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return ach_front.Achievement(
      gameName: widget.gameName,
      imgUrl: widget.imgUrl,
      percentage: widget.percentage,
    );
  }

  Widget _buildBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_animationController.value * 3.14159265359),
      child: ach_back.Achievement(
        achievementName: widget.achievementName,
        dateOfAch: widget.dateOfAch,
        description: widget.description,
        percentage: widget.percentage,
      ),
    );
  }
}
