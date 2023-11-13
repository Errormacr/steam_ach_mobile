import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:GamersGlint/game_ach_page.dart';

class GameCard extends StatelessWidget {
  final String gameImageUrl;
  final String gameName;
  final bool isCompleted;
  final int achievementCount;
  final int gainedCount;
  final int playtime;
  final int lastPlayTime;
  final int appid;

  const GameCard({
    Key? key,
    required this.gameImageUrl,
    required this.gameName,
    this.isCompleted = false,
    required this.achievementCount,
    required this.gainedCount,
    required this.playtime,
    required this.lastPlayTime,
    required this.appid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameAch(gameAppid: appid,)),
          );
        },
        child: Container(
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
                      border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 0)),
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
                child: CachedNetworkImage(
                  imageUrl: gameImageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/image/noimg.jpg'),
                  width: 150,
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
                    value: gainedCount /
                        achievementCount, // Assuming achievement count is out of 100
                    backgroundColor: Colors.grey,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              Positioned(
                bottom: 15,
                left: 0,
                child: Text(
                  gameName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
        ));
  }
}
