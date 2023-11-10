import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String gameImageUrl;
  final String gameName;
  final bool isCompleted;
  final int achievementCount;
  final int gainedCount;
  final int playtime;
  final int lastPlayTime;

  const GameCard({
    Key? key,
    required this.gameImageUrl,
    required this.gameName,
    this.isCompleted = false,
    required this.achievementCount,
    required this.gainedCount,
    required this.playtime,
    required this.lastPlayTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          if (isCompleted)
            Positioned.fill(
              left: 0,
              top: 0,
              child: Container(
                width: 190,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: const Color.fromARGB(255, 255, 255, 0)),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 230, 0),
                      Color.fromARGB(255, 246, 255, 0),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              gameImageUrl,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          if (achievementCount > 0)
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: gainedCount / achievementCount, // Assuming achievement count is out of 100
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            child: Text(
              gameName,
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              '$achievementCount',
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
           Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              '$gainedCount',
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ],
      ),
    );
  }
}
