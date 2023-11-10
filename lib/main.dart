import 'package:flutter/material.dart';
import 'package:steam_ach_mobile/ach_page.dart';
import 'package:steam_ach_mobile/widgets/game_card.dart';
import 'package:steam_ach_mobile/game_page.dart';
import 'package:steam_ach_mobile/settings_page.dart';
import './API/api.dart';
import '/API/db_methods.dart';
import "API/db_classes.dart" as classes;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_page.dart';
import 'widgets/notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация плагина
  flutterLocalNotificationsPlugin
      .initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(),
    ),
  )
      .then((_) {
    runApp(const MyApp());
  });
}

Future<void> fetchData(BuildContext context) async {
  const secureStorage = FlutterSecureStorage();
  final storedData = await secureStorage.read(key: "apiKey");
  final steamId = await secureStorage.read(key: "steamId");
  if (storedData == null ||
      steamId == null ||
      steamId.trim() == "" ||
      storedData.trim() == "") {
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
              if (storedData == null || storedData.trim() == "")
                TextField(
                  onChanged: (value) {
                    newApiKey = value;
                  },
                  decoration: const InputDecoration(labelText: 'Enter API Key'),
                ),
              if (steamId == null || steamId.trim() == "")
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
                if (storedData == null || storedData.trim() == "") {
                  await secureStorage.write(key: "apiKey", value: newApiKey);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(newApiKey);
                }
                if (steamId == null || steamId.trim() == "") {
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
  String? nickname;
  int? numGames;
  double? percent;
  int _currentIndex = 0;
  int id = 0;
  List<GameCard>? cards;
  void reinit() {
    const secureStorage = FlutterSecureStorage();
    secureStorage.read(key: "apiKey").then((apiKey) {
      Api api = Api(apiKey: apiKey!);
      fetchData(context).then((some) {
        secureStorage.read(key: "steamId").then((value) {
          int steamId = int.tryParse(value!)!;
          api.checkUpdate(steamId).then((url) {
            if (url) {
              api.getUserData(steamId, "Russian").then((ele) async {
                classes.Account? user = ele;
                if (user != null) {
                  List<classes.Game> games = user.games;
                  games.sort((a, b) => b.lastPlayTime! - a.lastPlayTime!);
                  List<GameCard> gameCards = [];
                  for (var i = 0; i < 6; i++) {
                    String gameImageUrl =
                        "https://steamcdn-a.akamaihd.net/steam/apps/${games[i].appid}/header.jpg";
                    List<classes.Achievement> ach = games[i].achievements!;
                    int achCount = ach.length;
                    Iterable<classes.Achievement> achi =
                        ach.where((element) => element.achieved);
                    int gainedCount = achi.length;
                    String gameName = games[i].name!.trim();
                    gameCards.add(GameCard(
                      gameImageUrl: gameImageUrl,
                      gameName: gameName,
                      isCompleted: gainedCount == achCount,
                      achievementCount: achCount,
                      gainedCount: gainedCount,
                      playtime: games[i].playtimeForever!,
                      lastPlayTime: games[i].lastPlayTime!,
                    ));
                  }

                  setState(() {
                    avatarUrl = user.avaUrl;
                    nickname = user.username;
                    numGames = user.gameCount;
                    percent = user.percentage;
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
                    String gameImageUrl =
                        "https://steamcdn-a.akamaihd.net/steam/apps/${games[i].appid}/header.jpg";
                    String gameName = games[i].name!.trim();
                    List<classes.Achievement> ach = games[i].achievements!;
                    int achCount = ach.length;
                    Iterable<classes.Achievement> achi =
                        ach.where((element) => element.achieved);
                    int gainedCount = achi.length;
                    gameCards.add(GameCard(
                      gameImageUrl: gameImageUrl,
                      gameName: gameName,
                      isCompleted: achCount == gainedCount,
                      achievementCount: achCount,
                      gainedCount: gainedCount,
                      playtime: games[i].playtimeForever!,
                      lastPlayTime: games[i].lastPlayTime!,
                    ));
                  }

                  setState(() {
                    avatarUrl = user.avaUrl;
                    nickname = user.username;
                    numGames = user.gameCount;
                    percent = user.percentage;
                    id = steamId;
                    cards = gameCards;
                  });
                }
              });
            }
          });
        });
      });
    });
  }

  @override
  initState() {
    super.initState();
    reinit();
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
      ),
      const GamePage(),
      const AllAch(),
      const SettingsPage()
    ];

    return Scaffold(
      appBar: AppBar(
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
            label: 'games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_motion, color: Colors.black),
            label: '',
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
