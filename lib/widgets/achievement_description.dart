import 'package:flutter/material.dart';

class DescriptionAch extends StatelessWidget {
  final String text;
  final double minFontSize;
  final double maxFontSize;
  final double stepGranularity;

  const DescriptionAch({
    Key? key,
    required this.text,
    this.minFontSize = 8,
    this.maxFontSize = 16,
    this.stepGranularity = 1,
  }) : super(key: key);

  double calculateFontSize(
      String text, TextStyle style, double maxWidth, double maxHeight) {
    for (double fontSize = maxFontSize;
        fontSize >= minFontSize;
        fontSize -= stepGranularity) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style.copyWith(fontSize: fontSize)),
        maxLines: 5,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      if (painter.width <= maxWidth && painter.height <= maxHeight) {
        return fontSize;
      }
    }

    return minFontSize;
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = 70;
    double maxWidth = 140;
    return Text(
      text,
      overflow: TextOverflow.fade,
      maxLines: 5,
      style: TextStyle(
        fontSize: calculateFontSize(
            text, TextStyle(fontSize: maxFontSize), maxWidth, maxHeight),
        color: Colors.white,
      ),
    );
  }
}
