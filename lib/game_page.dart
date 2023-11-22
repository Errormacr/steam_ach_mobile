import 'package:flutter/material.dart';
import 'package:GamersGlint/API/db_methods.dart' as db_method;
import 'widgets/game_card.dart';
import "API/db_classes.dart" as classes;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String selectedFilter = 'Game Time';
  String selectDirection = "Descending"; // Default filter
  List<GameCard> cards = [];
  db_method.Methods db = db_method.Methods();

  @override
  void initState() {
    super.initState();
    
    const secureStorage = FlutterSecureStorage();
    secureStorage.read(key: "steamId").then((steamId) {
    db.getUserById(int.tryParse(steamId!)).then((user) {
      if (user != null) {
        List<classes.Game> games = user.games;
        games.sort((a, b) => b.lastPlayTime! - a.lastPlayTime!);
        List<GameCard> gameCards = [];
        for (var i = 0; i < games.length; i++) {
          String gameName = games[i].name!.trim();
          List<classes.Achievement> ach = games[i].achievements!;
          int achCount = ach.length;
          Iterable<classes.Achievement> achievedAch =
              ach.where((element) => element.achieved);
          int gainedCount = achievedAch.length;
          int? parsedAchCount = int.tryParse(achCount.toString());
          if (parsedAchCount == null) {
            gainedCount = 0;
            achCount = 0;
          }
          gameCards.add(GameCard(
            gameName: gameName,
            isCompleted: achCount == gainedCount && achCount != 0,
            achievementCount: achCount,
            gainedCount: gainedCount,
            playtime: games[i].playtimeForever!,
            lastPlayTime: games[i].lastPlayTime!,
            appid: games[i].appid!,
          ));
        }

        setState(() {
          cards = gameCards;
        });
      }
    }); // You can call the method here or in another appropriate lifecycle method
 }); }

  @override
  Widget build(BuildContext context) {
    void sorting() {
      setState(() {
        switch (selectedFilter) {
          case 'Game Time':
            cards.sort((a, b) => selectDirection == 'Ascending'
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
                return selectDirection == 'Ascending'
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
                return selectDirection == 'Ascending'
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
                return selectDirection == 'Ascending'
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
                return selectDirection == 'Ascending'
                    ? a.gainedCount - b.gainedCount
                    : b.gainedCount - a.gainedCount;
              }
            });
            break;
          case 'Last Game Launch Time':
            if (selectDirection == 'Ascending') {
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
            SizedBox(width: 40,child:  ElevatedButton(
              onPressed: () {
                setState(() {
                  selectDirection = selectDirection == "Ascending" ? "dec" : "Ascending";
                });
                sorting();
              },
               style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10,)
                      ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    selectDirection == "Ascending"
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 20,
                  ),
                ],
              ),
            )
         ,)
            ],
        ),
        Expanded(
          // Changed SingleChildScrollView to Expanded
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 230,
              maxCrossAxisExtent: 140, // максимальная ширина элемента
              crossAxisSpacing: 3, // расстояние между столбцами
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
