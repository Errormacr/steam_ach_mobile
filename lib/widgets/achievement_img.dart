import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Achievement extends StatelessWidget {
  final String gameName;
  final String imgUrl;
  final double percentage;

  const Achievement({
    Key? key,
    required this.gameName,
    required this.imgUrl,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> getColor(double percentage) {
      if (percentage < 5) {
        return [
          const Color.fromARGB(255, 244, 193, 54),
          const Color.fromARGB(255, 255, 0, 255)
        ];
      } else if (percentage < 20) {
        return [
          const Color.fromARGB(255, 255, 0, 255),
          const Color.fromARGB(255, 59, 150, 255)
        ];
      } else if (percentage < 50) {
        return [const Color.fromARGB(255, 59, 150, 255), Colors.lightGreen];
      } else if (percentage < 80) {
        return [Colors.lightGreen, Colors.green];
      } else {
        return [Colors.green, const Color.fromARGB(255, 11, 61, 13)];
      }
    }

    double getStop(double percentage) {
      if (percentage < 5) {
        return 1.0 - percentage / 5;
      } else if (percentage < 20) {
        return 1.0 - (percentage - 5) / (20 - 5);
      } else if (percentage < 50) {
        return 1.0 - (percentage - 20) / (50 - 20);
      } else if (percentage < 80) {
        return 1.0 - (percentage - 50) / (80 - 50);
      } else {
        return 1.0 - (percentage - 80) / (100 - 80);
      }
    }

    double achImgWidth = 90;
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          stops: [getStop(percentage), 1.0],
          colors: getColor(percentage),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            gameName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          CachedNetworkImage(
            imageUrl: imgUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                Image.asset('assets/image/noAch.svg'),
            width: achImgWidth,
            height: achImgWidth,
            fit: BoxFit.contain,
            cacheKey: imgUrl, // Specify a custom cache key
            fadeInDuration:
                const Duration(milliseconds: 500), // Adjust fade-in duration
          ),
          Text(
            '${percentage.toStringAsFixed(2)}%',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
