import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gamers_glint/API/db_classes.dart';
import 'package:gamers_glint/widgets/flip_of_achievement.dart' as ach_img_lib;
import 'API/db_methods.dart';
import 'package:intl/intl.dart';
import 'package:unixtime/unixtime.dart';

class GameAch extends StatefulWidget {
  final int gameAppid;

  const GameAch({Key? key, required this.gameAppid}) : super(key: key);

  @override
  State<GameAch> createState() {
    return _GameAchState();
  }
}

class _GameAchState extends State<GameAch> {
  String selectedSort = "Achieved time";
  String selectedFilter = "FilterAch";
  String selectDirection = "DESC";
  String nameSearchQuery = "";
  String gameSearchQuery = "";
  String gameName = "";
  List<ach_img_lib.Achievement> achs = [];
  List<ach_img_lib.Achievement> achsStorage = [];
  Methods db = Methods();
  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    secureStorage.read(key: "steamId").then((steamId) {
      db.getUserById(int.tryParse(steamId!)).then((user) {
        if (user != null) {
          List<ach_img_lib.Achievement> achImgs = [];
          Game game =
              user.games.firstWhere((game) => game.appid == widget.gameAppid);
          gameName = game.name!;
          for (var ach in game.achievements!) {
            int unlocktime = ach.dateOfAch!;
            ach_img_lib.Achievement achImg = ach_img_lib.Achievement(
              description: ach.description ?? "",
              gameName: game.name!,
              imgUrl: ach.achieved ? ach.icon! : ach.icongray!,
              achievementName: ach.displayName!,
              percentage: ach.percentage!,
              dateOfAch: unlocktime,
              achieved: ach.achieved,
            );
            achImgs.add(achImg);
          }

          achImgs.sort((a, b) {
            return b.dateOfAch - a.dateOfAch;
          });
          setState(() {
            achs = achImgs;
            achsStorage = achImgs;
          });
        }
      });
    });
  }

  void replaceAchs(List<ach_img_lib.Achievement> listAchievement) {
    setState(() {
      achs = listAchievement;
    });
  }

  @override
  Widget build(BuildContext context) {
    void sorting() {
      setState(() {
        switch (selectedSort) {
          case 'Achieved time':
            achs.sort((a, b) => selectDirection == 'ASC'
                ? a.dateOfAch.compareTo(b.dateOfAch)
                : b.dateOfAch.compareTo(a.dateOfAch));
            break;
          case 'Percent':
            achs.sort((a, b) {
              return selectDirection == 'ASC'
                  ? a.percentage.compareTo(b.percentage)
                  : b.percentage.compareTo(a.percentage);
            });
            break;
          case 'Name':
            achs.sort((a, b) {
              return selectDirection == 'ASC'
                  ? b.achievementName.compareTo(a.achievementName)
                  : a.achievementName.compareTo(b.achievementName);
            });
            break;
          case 'achieved':
            achs.sort((a, b) {
              if (selectDirection == "ASC") {
                return b.achieved == a.achieved
                    ? 0
                    : b.achieved
                        ? -1
                        : 1;
              } else {
                return a.achieved == b.achieved
                    ? 0
                    : a.achieved
                        ? -1
                        : 1;
              }
            });
          default:
            break;
        }
      });
    }

    void filter() {
      switch (selectedFilter) {
        case 'FilterAch':
          replaceAchs(achsStorage);
          break;
        case "achieved":
          replaceAchs(
              achsStorage.where((element) => element.achieved).toList());
          break;
        case "nonAchieved":
          replaceAchs(
              achsStorage.where((element) => !element.achieved).toList());
          break;
        case 'percents':
          RangeValues currentRange = const RangeValues(0, 100);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select percentage range'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(mainAxisSize: MainAxisSize.min, children: [
                      RangeSlider(
                        values: currentRange,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        labels: RangeLabels(
                          currentRange.start.round().toString(),
                          currentRange.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            currentRange = values;
                          });
                        },
                      )
                    ]);
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Обработка выбора диапазона процентов
                      // Например, фильтрация списка achs по выбранному диапазону
                      List<ach_img_lib.Achievement> filteredAchs = achsStorage
                          .where((ach) =>
                              ach.percentage >= currentRange.start &&
                              ach.percentage <= currentRange.end)
                          .toList();
                      replaceAchs(filteredAchs);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              );
            },
          );
          break;
        case "data":
          double earliestAchievementDateInUnixEpoch = achsStorage
              .map((ach) => ach.dateOfAch)
              .reduce((a, b) => a < b ? a : b)
              .toDouble();
          int maxValue = achsStorage[0].dateOfAch;
          for (int i = 1; i < achsStorage.length; i++) {
            if (achsStorage[i].dateOfAch > maxValue) {
              maxValue = achsStorage[i].dateOfAch;
            }
          }

          double latestAchievementDateInUnixEpoch = maxValue.toDouble();

          RangeValues currentDateRange = RangeValues(
            earliestAchievementDateInUnixEpoch,
            latestAchievementDateInUnixEpoch,
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select date range'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RangeSlider(
                          values: currentDateRange,
                          min: earliestAchievementDateInUnixEpoch,
                          max: latestAchievementDateInUnixEpoch,
                          onChanged: (RangeValues values) {
                            setState(() {
                              currentDateRange = values;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd').format(
                                  currentDateRange.start.toInt().toUnixTime()),
                            ),
                            Text(DateFormat('yyyy-MM-dd').format(
                              currentDateRange.end.toInt().toUnixTime(),
                            )),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Обработка выбора диапазона дат
                      // Например, фильтрация списка achs по выбранному диапазону дат
                      List<ach_img_lib.Achievement> filteredAchs = achsStorage
                          .where((ach) =>
                              ach.dateOfAch >= currentDateRange.start &&
                              ach.dateOfAch <= currentDateRange.end)
                          .toList();
                      replaceAchs(filteredAchs);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              );
            },
          );
          break;
        default:
          break;
      }
      sorting();
    }

    return Scaffold(
        appBar: AppBar(title: Text(gameName)),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 10,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: (String value) {
                      setState(() {
                        nameSearchQuery = value;
                      });
                      replaceAchs(achsStorage
                          .where((ach) => ach.achievementName
                              .toLowerCase()
                              .contains(nameSearchQuery.toLowerCase()))
                          .toList());
                    },
                    decoration: const InputDecoration(
                      labelText: 'Ach name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                    filter();
                  },
                  items: <String>[
                    "FilterAch",
                    'percents',
                    'data',
                    "achieved",
                    "nonAchieved"
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: selectedSort,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSort = newValue!;
                    });
                    sorting();
                  },
                  items: <String>[
                    'Name',
                    'Percent',
                    'Achieved time',
                    "achieved"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(
                    width: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectDirection =
                              selectDirection == "ASC" ? "DESC" : "ASC";
                        });
                        sorting();
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            selectDirection == "ASC"
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                          ),
                        ],
                      ),
                    ))
              ],
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child:
                  // Changed SingleChildScrollView to Expanded
                  GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 170,
                  maxCrossAxisExtent: 130,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 30,
                ),
                itemCount: achs.length,
                itemBuilder: (BuildContext context, int index) {
                  return achs[index];
                },
              ),
            ))
          ],
        ));
  }
}
