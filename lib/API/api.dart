import 'package:http/http.dart' as http;
import 'package:steam_ach_mobile/API/db_classes.dart';
import 'package:steam_ach_mobile/notifications.dart';
import 'dart:convert';
import './db_methods.dart';
import '../dataModels/player_data.dart';
import '../dataModels/game_data.dart' as gm;
import '../dataModels/ach_data.dart' as ach_m;
import '../dataModels/ach_perc_data.dart' as perc_m;
import '../dataModels/ach_ico_data.dart' as icon_m;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class Api {
  Future<void> getUserData(int steamId, String lang) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final secureStorage = FlutterSecureStorage();
    String? apiKey = await secureStorage.read(key: "apiKey");
    final url =
        'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=$apiKey&ste'
        'amids=$steamId';
    final gamesUrl =
        'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=$apiKey&stea'
        'mid=$steamId&format=json&include_played_free_games=true&include_appinfo=true';

    final responses = await Future.wait([
      http.get(Uri.parse(url)),
      http.get(Uri.parse(gamesUrl)),
    ]);
    final response = responses[0];
    final gameResponse = responses[1];
    var achCount = 0;
    double percents = 0;
    var gameWithAch = 0;
    if (response.statusCode == 200) {
      Methods db = Methods();
      gm.GameData gameData =
          gm.GameData.fromJson(jsonDecode(gameResponse.body));
      PlayerData userData = PlayerData.fromJson(jsonDecode(response.body));
      final avatarUrl = userData.response.players[0].avatarfull;
      final nickname = userData.response.players[0].personaname;
      final numGames = gameData.response.gameCount;
      final List<Game> games = <Game>[];
      await Future.forEach(gameData.response.games, (game) async {
        final achievements = <Achievement>[];
        final achUrl =
            "http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/?appid=${game.appid}&key=$apiKey&steamid=$steamId&l=$lang";
        final percUrl =
            "http://api.steampowered.com/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=${game.appid}&format=json";
        final icoUrl =
            "https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?appid=${game.appid}&key=$apiKey&l=$lang";

        final responsesAch = await Future.wait([
          http.get(Uri.parse(achUrl)),
          http.get(Uri.parse(percUrl)),
          http.get(Uri.parse(icoUrl)),
        ]);

        final achResp = responsesAch[0];
        final perResp = responsesAch[1];
        final icoResp = responsesAch[2];
        int totalAch = 0;
        var achievedAch;
        if (jsonDecode(achResp.body).toString() !=
                "{playerstats: {error: Requested app has no stats, success: false}}" &&
            jsonDecode(achResp.body).toString().contains("achievements")) {
          final achRes = ach_m.AchData.fromJson(jsonDecode(achResp.body));
          final percRes = perc_m.PercData.fromJson(jsonDecode(perResp.body));
          final icoRes = icon_m.IconData.fromJson(jsonDecode(icoResp.body));

          for (var item in achRes.playerstats.achievements) {
            perc_m.Achievement matchingItem;
            try {
              matchingItem = percRes.achievementpercentages.achievements
                  .firstWhere((element) => element.name == item.apiname);
            } catch (e) {
              matchingItem = perc_m.Achievement.fromJson({"name":"","percent":1});
              print(e);
            }

            final matchingItem2 = icoRes.game.availableGameStats.achievements
                .firstWhere((element) => element.name == item.apiname);

            achievements.add(Achievement()
              ..name = item.name
              ..displayName = matchingItem2.displayName
              ..description = matchingItem2.description
              ..icon = matchingItem2.icon
              ..icongray = matchingItem2.icongray
              ..achieved = item.achieved == 1 ? true : false
              ..percentage = matchingItem.percent);
          }
          totalAch = achievements.length;
          if (totalAch > 0) {
            achCount += totalAch;
          }
          achievedAch = achievements.where((item) => item.achieved == true);
          if (achievedAch.isNotEmpty) {
            percents += achievedAch.length / totalAch;
            gameWithAch++;
          }
          flutterLocalNotificationsPlugin.show(
            0,
            game.name,
            "gained: ${achievedAch.length}, total: $totalAch",
            platformChannelSpecifics,
            payload: 'item x',
          );
        }

        games.add(Game()
          ..appid = game.appid
          ..name = game.name
          ..playtimeForever = game.playtimeForever
          ..imgIconUrl = game.imgIconUrl
          ..percent = achievements.isEmpty ? 0 : achievedAch.length / totalAch
          ..achievements = achievements);
      });

      final recentUrl =
          "http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=$apiKey&steamid=$steamId&format=json";
      final recentRes = await http.get(Uri.parse(recentUrl));
      final rec = jsonDecode(recentRes.body).toString();
      db.insertUpdateAcc(Account(steamId, nickname, rec, numGames, achCount,
          percents / gameWithAch * 100, avatarUrl, games));
    } else {
      throw Exception('Failed to load Steam avatar');
    }
  }

  Future<bool> checkUpdate(int steamId) async {
    Methods db = Methods();
    Account? user = await db.getUserById(steamId);
    final secureStorage = FlutterSecureStorage();
    String? apiKey = await secureStorage.read(key: "apiKey");
    if (user != null) {
      final recentUrl =
          "http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=$apiKey&steamid=$steamId&format=json";
      final recentRes = await http.get(Uri.parse(recentUrl));
      final rec = jsonDecode(recentRes.body).toString();

      List<String> parts1 = rec.split(RegExp(r'[,:{}]'));
      List<String> parts = user.recent.split(RegExp(r'[,:{}]'));

      List<String> playtimeForeverValues1 = [];

      for (var i = 0; i < parts1.length; i++) {
        if (parts1[i].trim() == 'playtime_forever') {
          playtimeForeverValues1.add(parts1[i + 1].trim());
        }
      }
      List<String> playtimeForeverValues = [];

      for (var i = 0; i < parts.length; i++) {
        if (parts[i].trim() == 'playtime_forever') {
          playtimeForeverValues.add(parts[i + 1].trim());
        }
      }
      if (playtimeForeverValues1.length == playtimeForeverValues.length) {
        for (var i = 0; i < playtimeForeverValues.length; i++) {
          if (playtimeForeverValues[i] != playtimeForeverValues1[i]) {
            return false;
          }
        }
        return true;
      }
    }
    return false;
  }
}
