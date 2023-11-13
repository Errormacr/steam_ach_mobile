import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:steam_ach_mobile/widgets/ahcievement_img.dart';
import 'API/db_methods.dart';

class AllAch extends StatefulWidget {
  const AllAch({Key? key}) : super(key: key);

  @override
  _AllAchState createState() => _AllAchState();
}

class _AllAchState extends State<AllAch> {
  String selectedSort = "Achieved time";
  String selectedFilter = "FilterAch";
  String selectDirection = "ASC";
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
                width: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
              maxCrossAxisExtent: 150, // максимальная ширина элемента
              crossAxisSpacing: 4, // расстояние между столбцами
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
