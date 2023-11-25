import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import "API/db_classes.dart" as classes;
import './API/api.dart';
import './API/db_methods.dart';
import './ach_page.dart';
import './game_page.dart';
import './settings_page.dart';
import './widgets/game_card.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация плагина

  runApp(const MyApp());
}

Future<void> fetchData(BuildContext context) async {
  const secureStorage = FlutterSecureStorage();
  String storedData = "";
  String steamId = "";
  try {
    storedData = (await secureStorage.read(key: "apiKey"))!;
    steamId = (await secureStorage.read(key: "steamId"))!;
  } catch (e) {
    print(e);
  }
  if (steamId.trim() == "" || storedData.trim() == "") {
    // ignore: use_build_context_synchronously
    final newData = await showDialog<String>(
      context: context,
      builder: (context) {
        String newApiKey = "";
        String newSteamId = "";
        return AlertDialog(
          title: const Text("Enter Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (storedData.trim() == "")
                TextField(
                  onChanged: (value) {
                    newApiKey = value;
                  },
                  decoration: const InputDecoration(labelText: 'Enter API Key'),
                ),
              if (steamId.trim() == "")
                TextField(
                  onChanged: (value) {
                    newSteamId = value;
                  },
                  decoration:
                      const InputDecoration(labelText: 'Enter Steam ID'),
                ),
            ],
          ),
          actions: <Widget>[
            FloatingActionButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FloatingActionButton(
              child: const Text("Save"),
              onPressed: () async {
                // Save the entered data in secure storage
                if (storedData.trim() == "") {
                  await secureStorage.write(key: "apiKey", value: newApiKey);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(newApiKey);
                }
                if (steamId.trim() == "") {
                  await secureStorage.write(key: "steamId", value: newSteamId);
                  Navigator.of(context).pop(newSteamId);
                }
              },
            ),
          ],
        );
      },
    );

    if (newData != null) {
      // Data has been saved, you can handle it here
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? avatarUrl;
  List<GameCard>? cards;
  int id = 0;
  String? nickname;
  int? numGames;
  double? percent;
  int achCount = 0;

  int _currentIndex = 0;

  @override
  initState() {
    super.initState();
    reinit();
  }

  Future<void> reinit() async {
    const secureStorage = FlutterSecureStorage();
    const String lang = "Russian";
    String apiKey = (await secureStorage.read(key: "apiKey"))!;
    String value = (await secureStorage.read(key: "steamId"))!;
    Api api = Api(apiKey: apiKey);
    int steamId = int.tryParse(value)!;
    api.checkUpdate(steamId).then((url) {
      if (!url) {
        api.getUserData(steamId, lang).then((ele) {
          classes.Account? user = ele;
          if (user != null) {
            print(user.gameCount);

            List<classes.Game> games = user.games;
            games.sort((a, b) => b.lastPlayTime! - a.lastPlayTime!);
            List<GameCard> gameCards = [];
            for (var i = 0; i < 6; i++) {
              List<classes.Achievement> ach = games[i].achievements!;
              int achCount = ach.length;
              Iterable<classes.Achievement> achi =
                  ach.where((element) => element.achieved);
              int gainedCount = achi.length;
              String gameName = games[i].name!.trim();
              gameCards.add(GameCard(
                gameName: gameName,
                isCompleted: gainedCount == achCount,
                achievementCount: achCount,
                gainedCount: gainedCount,
                playtime: games[i].playtimeForever!,
                lastPlayTime: games[i].lastPlayTime!,
                appid: games[i].appid!,
              ));
            }
            print(user.avaUrl);
            print(user.username);
            print(user.gameCount);
            print(user.percentage);
            print(user.achievementCount);
            print(steamId);
            print(gameCards);
            setState(() {
              avatarUrl = user.avaUrl;
              nickname = user.username;
              numGames = user.gameCount;
              percent = user.percentage;
              achCount = user.achievementCount;
              id = steamId;
              cards = gameCards;
            });
          }
        });
      } else {
        Methods db = Methods();
        db.getUserById(steamId).then((user) async {
          if (user != null) {
            List<classes.Game> games = user.games;
            games.sort((a, b) => b.lastPlayTime! - a.lastPlayTime!);
            List<GameCard> gameCards = [];
            for (var i = 0; i < 6; i++) {
              List<classes.Achievement> ach = games[i].achievements!;
              int achCount = ach.length;
              Iterable<classes.Achievement> achi =
                  ach.where((element) => element.achieved);
              int gainedCount = achi.length;
              String gameName = games[i].name!.trim();
              gameCards.add(GameCard(
                gameName: gameName,
                isCompleted: gainedCount == achCount,
                achievementCount: achCount,
                gainedCount: gainedCount,
                playtime: games[i].playtimeForever!,
                lastPlayTime: games[i].lastPlayTime!,
                appid: games[i].appid!,
              ));
            }

            setState(() {
              avatarUrl = user.avaUrl;
              nickname = user.username;
              numGames = user.gameCount;
              percent = user.percentage;
              achCount = user.achievementCount;
              id = steamId;
              cards = gameCards;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        nickname: nickname,
        avatarUrl: avatarUrl,
        numGames: numGames,
        percent: percent,
        id: id,
        recent: cards,
        achCount: achCount,
      ),
      const GamePage(),
      const AllAch(),
      const SettingsPage()
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        title: const Text('Steam Avatar'),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          if (index == 0) {
            reinit();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.grey, // Цвет выбранного элемента
        unselectedItemColor: Colors.white, //
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.auto_awesome_mosaic,
              color: Colors.black,
            ),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_motion, color: Colors.black),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
