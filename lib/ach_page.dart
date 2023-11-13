import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:GamersGlint/widgets/ahcievement_img.dart';
import 'API/db_methods.dart';
import 'package:intl/intl.dart';
import 'package:unixtime/unixtime.dart';

class AllAch extends StatefulWidget {
  const AllAch({Key? key}) : super(key: key);

  @override
  _AllAchState createState() => _AllAchState();
}

class _AllAchState extends State<AllAch> {
  String selectedSort = "Achieved time";
  String selectedFilter = "FilterAch";
  String selectDirection = "DESC";
  String nameSearchQuery = "";
  String gameSearchQuery = "";
  List<Achievement> achs = [];
  List<Achievement> achsStorage = [];
  Methods db = Methods();
  @override
  void initState() {
    super.initState();
    const secureStorage = FlutterSecureStorage();
    secureStorage.read(key: "steamId").then((steamId) {
      db.getUserById(int.tryParse(steamId!)).then((user) {
        if (user != null) {
          List<Achievement> achImgs = [];
          for (var game in user.games) {
            if (game.percent! > 0) {
              for (var ach in game.achievements!) {
                if (ach.achieved) {
                  int unlocktime = ach.dateOfAch!;
                  Achievement achImg = Achievement(
                    gameName: game.name!,
                    imgUrl: ach.icon!,
                    achievementName: ach.displayName!,
                    percentage: ach.percentage!,
                    dateOfAch: unlocktime,
                    achieved: ach.achieved,
                  );
                  achImgs.add(achImg);
                }
              }
            }
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

  void replaceAchs(List<Achievement> listAchievement) {
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
          case 'GameName':
            achs.sort((a, b) {
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
          replaceAchs(achsStorage);
          break;
        case 'percents':
          RangeValues currentRange = RangeValues(0, 100);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select percentage range'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return RangeSlider(
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
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Обработка выбора диапазона процентов
                      // Например, фильтрация списка achs по выбранному диапазону
                      List<Achievement> filteredAchs = achsStorage
                          .where((ach) =>
                              ach.percentage >= currentRange.start &&
                              ach.percentage <= currentRange.end)
                          .toList();
                      replaceAchs(filteredAchs);
                      Navigator.of(context).pop();
                    },
                    child: Text('Apply'),
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
                                currentDateRange.start.toInt().toUnixTime()
                              ),
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
                      List<Achievement> filteredAchs = achsStorage
                          .where((ach) =>
                              ach.dateOfAch >= currentDateRange.start &&
                              ach.dateOfAch <= currentDateRange.end)
                          .toList();
                      replaceAchs(filteredAchs);
                      Navigator.of(context).pop();
                    },
                    child: Text('Apply'),
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
            SizedBox(
              width: 150,
              child: TextField(
                onChanged: (String value) {
                  setState(() {
                    gameSearchQuery = value;
                  });
                  replaceAchs(achsStorage
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
                        padding: const EdgeInsets.symmetric(horizontal: 10,)
                      ),
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
          // Changed SingleChildScrollView to Expanded
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 170,
              maxCrossAxisExtent: 140, // максимальная ширина элемента
              crossAxisSpacing: 10, // расстояние между столбцами
              mainAxisSpacing: 30, // расстояние между строками
            ),
            itemCount: achs.length, // количество элементов в гриде
            itemBuilder: (BuildContext context, int index) {
              return achs[index];
            },
          ),
        )
      ],
    );
  }
}
