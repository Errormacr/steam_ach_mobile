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
  String selectedFilter = 'Game Time';
  String selectNapr = "Descending"; // Default filter
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
    void sorting() {
      setState(() {
        switch (selectedFilter) {
          case 'Game Time':
            cards.sort((a, b) => selectNapr == 'Ascending'
                    ? a.playtime.compareTo(b.playtime)
                    : b.playtime.compareTo(a.playtime));
            break;
          case 'Achievement Percentage':
            cards.sort((a, b) {
              double ratioA = a.achievementCount != 0
                  ? a.gainedCount / a.achievementCount
                  : 0;
              double ratioB = b.achievementCount != 0
                  ? b.gainedCount / b.achievementCount
                  : 0;
                if (a.achievementCount == 0) {
                return 1;
              } else if (b.achievementCount == 0) {
                return -1;
              } else {
                return selectNapr == 'Ascending'
                    ? ratioA.compareTo(ratioB)
                    : ratioB.compareTo(ratioA);
              }
            });
            break;
          case 'Total Achievements':
            cards.sort((a, b) {
              if (a.achievementCount == 0) {
                return 1;
              } else if (b.achievementCount == 0) {
                return -1;
              } else {
                return selectNapr == 'Ascending'
                    ? a.achievementCount - b.achievementCount
                    : b.achievementCount - a.achievementCount;
              }
            });
            break;
          case 'Unachieved Achievements':
            cards.sort((a, b) {
              if (a.achievementCount == 0) {
                return 1;
              } else if (b.achievementCount == 0) {
                return -1;
              } else {
                return selectNapr == 'Ascending'
                    ? (a.achievementCount - a.gainedCount) -
                        (b.achievementCount - b.gainedCount)
                    : (b.achievementCount - b.gainedCount) -
                        (a.achievementCount - a.gainedCount);
              }
            });
            break;
          case 'Achieved Achievements':
            cards.sort((a, b) {
              if (a.achievementCount == 0) {
                return 1;
              } else if (b.achievementCount == 0) {
                return -1;
              } else {
                return selectNapr == 'Ascending'
                    ? a.gainedCount - b.gainedCount
                    : b.gainedCount - a.gainedCount;
              }
            });
            break;
          case 'Last Game Launch Time':
            if (selectNapr == 'Ascending') {
              cards.sort((a, b) => a.lastPlayTime - b.lastPlayTime);
            } else {
              cards.sort((a, b) => b.lastPlayTime - a.lastPlayTime);
            }
            break;
          default:
            break;
        }
      });
    }

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
                sorting();
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
            DropdownButton<String>(
              value: selectNapr,
              onChanged: (String? newValue) {
                setState(() {
                  selectNapr = newValue!;
                });
                sorting();
              },
              items: <String>[
                'Ascending',
                'Descending',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
