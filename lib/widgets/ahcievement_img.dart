import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Achievement extends StatelessWidget {
  final String gameName;
  final String imgUrl;
  final String achievementName;
  final double percentage;
  final int dateOfAch;

  const Achievement({
    Key? key,
    required this.gameName,
    required this.imgUrl,
    required this.achievementName,
    required this.percentage,
    required this.dateOfAch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
            ),
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  Image.asset('assets/image/noAch.svg'),
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievementName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Percentage: ${percentage.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}