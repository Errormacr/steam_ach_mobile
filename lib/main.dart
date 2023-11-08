import 'package:flutter/material.dart';
import 'package:steam_ach_mobile/ach_page.dart';
import 'package:steam_ach_mobile/game_card.dart';
import 'package:steam_ach_mobile/game_page.dart';
import 'package:steam_ach_mobile/settings_page.dart';
import './API/api.dart';
import '/API/db_methods.dart';
import "API/db_classes.dart" as classes;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_page.dart';
import 'notifications.dart';
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

  if (storedData == null) {
    // ignore: use_build_context_synchronously
    final newData = await showDialog<String>(
      context: context,
      builder: (context) {
        String newData = "";
        return AlertDialog(
          title: const Text("Enter Data"),
          content: TextField(
            onChanged: (value) {
              newData = value;
            },
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
                await secureStorage.write(key: "apiKey", value: newData);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(newData);
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

  @override
  initState() {
    super.initState();
    Api api = Api();
    fetchData(context);
    int steamId = 76561198126403886;
    api.checkUpdate(steamId).then((url) {
      if (!url) {
        api.getUserData(steamId, "Russian").then((ele) async {
          Methods db = Methods();
          classes.Account? user = await db.getUserById(steamId);
          if (user != null) {
            List<GameCard> cards = [];
            List<String> parts = user.recent.split(RegExp(r'[,:{}]'));
            var games = user.games;
            for (var i = 0; i < parts.length; i++) {
              if (parts[i].trim() == 'appid') {
                var game = games.firstWhere(
                    (game) => game.appid == int.parse(parts[i + 1].trim()));
                bool completed = game.percent == 100.0;
                cards.add(GameCard(
                    gameImageUrl:
                        "https://steamcdn-a.akamaihd.net/steam/apps/${parts[i + 1].trim()}/capsule_sm_120.jpg",
                    gameName: parts[i + 3],
                    isCompleted: completed));
              }
            }
            setState(() {
              avatarUrl = user.avaUrl;
              nickname = user.username;
              numGames = user.gameCount;
              percent = user.percentage;
              id = steamId;
              cards = cards;
            });
          }
        });
      } else {
        Methods db = Methods();
        db.getUserById(steamId).then((user) async {
          if (user != null) {
            List<GameCard> cards0 = [];
            List<String> parts = user.recent.split(RegExp(r'[,:{}]'));
            var games = user.games;
            for (var i = 0; i < parts.length; i++) {
              if (parts[i].trim() == 'appid') {
                var game = games.firstWhere(
                    (game) => game.appid == int.parse(parts[i + 1].trim()));
                bool completed = game.percent == 100.0;
                cards0.add(GameCard(
                    gameImageUrl:
                        "https://steamcdn-a.akamaihd.net/steam/apps/${parts[i + 1].trim()}/capsule_sm_120.jpg",
                    gameName: parts[i + 3],
                    isCompleted: completed));
              }
            }
            setState(() {
              avatarUrl = user.avaUrl;
              nickname = user.username;
              numGames = user.gameCount;
              percent = user.percentage;
              id = steamId;
              cards = cards0;
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
