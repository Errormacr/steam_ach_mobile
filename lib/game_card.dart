import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String gameImageUrl;
  final String gameName;
  final bool isCompleted;

  const GameCard({
    Key? key,
    required this.gameImageUrl,
    required this.gameName,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 50,
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
                height: 70,
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
             Align(
            alignment: Alignment.center,
            child: Image.network(
              gameImageUrl,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              gameName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
