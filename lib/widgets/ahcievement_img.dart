import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:unixtime/unixtime.dart';

class Achievement extends StatelessWidget {
  final String gameName;
  final String imgUrl;
  final String achievementName;
  final double percentage;
  final int dateOfAch;
  final bool achieved;

  const Achievement({
    Key? key,
    required this.gameName,
    required this.imgUrl,
    required this.achievementName,
    required this.percentage,
    required this.dateOfAch,
    required this.achieved,
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
            color: percentage < 5
                ? const Color.fromARGB(110, 255, 184, 78)
                : percentage < 20
                    ? const Color.fromARGB(110, 217, 0, 255)
                    : percentage < 45
                        ? const Color.fromARGB(110, 60, 0, 255)
                        : percentage < 60
                            ? const Color.fromARGB(110, 43, 160, 1)
                            : const Color.fromARGB(110, 60, 255, 0),
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
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievementName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                '${percentage.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                '${DateFormat('yyyy-MM-dd hh').format(dateOfAch.toUnixTime())}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
