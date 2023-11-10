import 'package:flutter/material.dart';
import 'package:steam_ach_mobile/API/db_methods.dart' as db_method;
import 'game_card.dart';
import "API/db_classes.dart" as classes;

class GamePage extends StatefulWidget {
  const GamePage({Key? key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String selectedFilter = 'Game Time'; // Default filter
  List<GameCard> cards = [];
  db_method.Methods db = db_method.Methods();

  @override
  void initState() {
    super.initState();
    db.getUserById(76561198126403886).then((user) {
      if (user != null) {
        List<classes.Game> games = user.games;
        games.sort((a, b) => b.lastPlayTime! - a.lastPlayTime!);
        List<GameCard> gameCards = [];
        for (var i = 0; i < games.length; i++) {
          // Changed gameCards.length to games.length
          String gameImageUrl =
              "https://steamcdn-a.akamaihd.net/steam/apps/${games[i].appid}/header.jpg";
          String gameName = games[i].name!.trim();
          List<classes.Achievement> ach = games[i].achievements!;
          int achCount = ach.length;
          Iterable<classes.Achievement> achi =
              ach.where((element) => element.achieved);
          int gainedCount = achi.length;
          int? parsedAchCount = int.tryParse(achCount.toString());
          if (parsedAchCount == null) {
            gainedCount = 0;
            achCount = 0;
          }
          print(parsedAchCount);
          gameCards.add(GameCard(
            gameImageUrl: gameImageUrl,
            gameName: gameName,
            isCompleted: achCount == gainedCount && achCount != 0,
            achievementCount: achCount,
            gainedCount: gainedCount,
            playtime: games[i].playtimeForever!,
            lastPlayTime: games[i].lastPlayTime!,
          ));
        }

        setState(() {
          cards = gameCards;
        });
      }
    }); // You can call the method here or in another appropriate lifecycle method
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFilter = newValue!;
                });
              },
              items: <String>[
                'Game Time',
                'Achievement Percentage',
                'Total Achievements',
                'Unachieved Achievements',
                'Achieved Achievements',
                'Last Game Launch Time',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add sorting logic based on selectedFilter
                // Example: Sort the game list based on the selected filter
                switch (selectedFilter) {
                  case 'Game Time':
                    setState(() {
                      cards.sort((a, b) => b.playtime - a.playtime);
                    });
                    break;
                  case 'Achievement Percentage':
                    setState(() {
                      cards.sort((a, b) {
                        double ratioA = a.gainedCount / a.achievementCount;
                        double ratioB = b.gainedCount / b.achievementCount;

                        if (ratioA < ratioB) {
                          return 1;
                        } else if (ratioA > ratioB) {
                          return -1;
                        } else if (a.achievementCount == 0 ||
                            b.achievementCount == 0) {
                          return 1;
                        } else {
                          return 0;
                        }
                      });
                    });
                    break;
                  case 'Total Achievements':
                    setState(() {
                      cards.sort(
                          (a, b) => b.achievementCount - a.achievementCount);
                    });
                    break;
                  case 'Unachieved Achievements':
                    setState(() {
                      cards.sort((a, b) =>
                          (b.achievementCount - b.gainedCount) -
                          (a.achievementCount - a.gainedCount));
                    });
                    break;
                  case 'Achieved Achievements':
                    setState(() {
                      cards.sort((a, b) => b.gainedCount - a.gainedCount);
                    });
                    break;
                  case 'Last Game Launch Time':
                    setState(() {
                      cards.sort((a, b) => b.lastPlayTime - a.lastPlayTime);
                    });
                    break;
                  default:
                    break;
                }
              },
              child: const Text('Apply Sort'),
            ),
          ],
        ),
        Expanded(
          // Changed SingleChildScrollView to Expanded
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 115,
              maxCrossAxisExtent: 200, // максимальная ширина элемента
              crossAxisSpacing: 4, // расстояние между столбцами
              mainAxisSpacing: 10, // расстояние между строками
            ),
            itemCount: cards.length, // количество элементов в гриде
            itemBuilder: (BuildContext context, int index) {
              return cards[index];
            },
          ),
        )
      ],
    );
  }
}
