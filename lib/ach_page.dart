import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:GamersGlint/widgets/flip_of_achievement.dart';
import 'API/db_methods.dart';
import 'package:intl/intl.dart';
import 'package:unixtime/unixtime.dart';

class AllAch extends StatefulWidget {
  const AllAch({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AllAchState createState() => _AllAchState();
}

class _AllAchState extends State<AllAch> {
  String selectedSort = "Achieved time";
  String selectedFilter = "FilterAch";
  String selectDirection = "DESC";
  final ScrollController _scrollController = ScrollController();
  int visibleContainerIndex = 0;
  String nameSearchQuery = "";
  String gameSearchQuery = "";
  List<Achievement> achievements = [];
  List<Achievement> achievementsStorage = [];
  Methods db = Methods();
  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    secureStorage.read(key: "steamId").then((steamId) {
      db.getUserById(int.tryParse(steamId!)).then((user) {
        if (user != null) {
          List<Achievement> achImages = [];
          for (var game in user.games) {
            if (game.percent! > 0) {
              for (var ach in game.achievements!) {
                if (ach.achieved) {
                  int unlockTime = ach.dateOfAch!;
                  Achievement achImg = Achievement(
                    description: ach.description!,
                    gameName: game.name!,
                    imgUrl: ach.icon!,
                    achievementName: ach.displayName!,
                    percentage: ach.percentage!,
                    dateOfAch: unlockTime,
                    achieved: ach.achieved,
                  );
                  achImages.add(achImg);
                }
              }
            }
          }
          achImages.sort((a, b) {
            return b.dateOfAch - a.dateOfAch;
          });
          setState(() {
            achievements = achImages;
            achievementsStorage = achImages;
          });
        }
      });
    });
  }

  void replaceAchievements(List<Achievement> listAchievement) {
    setState(() {
      achievements = listAchievement;
    });
  }

  @override
  Widget build(BuildContext context) {
    void sorting() {
      setState(() {
        switch (selectedSort) {
          case 'Achieved time':
            achievements.sort((a, b) => selectDirection == 'ASC'
                ? a.dateOfAch.compareTo(b.dateOfAch)
                : b.dateOfAch.compareTo(a.dateOfAch));
            break;
          case 'Percent':
            achievements.sort((a, b) {
              return selectDirection == 'ASC'
                  ? a.percentage.compareTo(b.percentage)
                  : b.percentage.compareTo(a.percentage);
            });
            break;
          case 'Name':
            achievements.sort((a, b) {
              return selectDirection == 'ASC'
                  ? b.achievementName.compareTo(a.achievementName)
                  : a.achievementName.compareTo(b.achievementName);
            });
            break;
          case 'GameName':
            achievements.sort((a, b) {
              return selectDirection == 'ASC'
                  ? b.gameName.compareTo(a.gameName)
                  : a.gameName.compareTo(b.gameName);
            });
            break;
          default:
            break;
        }
      });
    }

    void filter() {
      switch (selectedFilter) {
        case 'FilterAch':
          replaceAchievements(achievementsStorage);
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
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                      ],
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      List<Achievement> filteredAchievements =
                          achievementsStorage
                              .where((ach) =>
                                  ach.percentage >= currentRange.start &&
                                  ach.percentage <= currentRange.end)
                              .toList();
                      replaceAchievements(filteredAchievements);
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
          double earliestAchievementDateInUnixEpoch = achievementsStorage
              .map((ach) => ach.dateOfAch)
              .reduce((a, b) => a < b ? a : b)
              .toDouble();
          int maxValue = achievementsStorage[0].dateOfAch;
          for (int i = 1; i < achievementsStorage.length; i++) {
            if (achievementsStorage[i].dateOfAch > maxValue) {
              maxValue = achievementsStorage[i].dateOfAch;
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
                      List<Achievement> filteredAchievements =
                          achievementsStorage
                              .where((ach) =>
                                  ach.dateOfAch >= currentDateRange.start &&
                                  ach.dateOfAch <= currentDateRange.end)
                              .toList();
                      replaceAchievements(filteredAchievements);
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 10,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                onChanged: (String value) {
                  setState(() {
                    nameSearchQuery = value;
                  });
                  replaceAchievements(achievementsStorage
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
            SizedBox(
              width: 150,
              child: TextField(
                onChanged: (String value) {
                  setState(() {
                    gameSearchQuery = value;
                  });
                  replaceAchievements(achievementsStorage
                      .where((ach) => ach.gameName
                          .toLowerCase()
                          .contains(gameSearchQuery.toLowerCase()))
                      .toList());
                },
                decoration: const InputDecoration(
                  labelText: 'Game name',
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
                'GameName',
                'Achieved time',
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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 170,
              maxCrossAxisExtent: 140,
              crossAxisSpacing: 10,
              mainAxisSpacing: 30,
            ),
            itemCount: achievements.length,
            itemBuilder: (BuildContext context, int index) {
              return achievements[index];
            },
          ),
        ))
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
