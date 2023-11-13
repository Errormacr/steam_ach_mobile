import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:GamersGlint/API/db_classes.dart' as classes;
import 'dart:convert';
import './db_methods.dart';
import '../dataModels/player_data.dart';
import '../dataModels/game_data.dart' as gm;
import '../dataModels/ach_data.dart' as ach_m;
import '../dataModels/ach_perc_data.dart' as perc_m;
import '../dataModels/ach_ico_data.dart' as icon_m;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

typedef GameDatarequest = ({gm.GameData gameDataSplit});

Future<http.Response> fetchData(String url) {
  return http.get(Uri.parse(url));
}

class readyIsol {
  readyIsol({
    required this.games,
    required this.achCount,
    required this.percents,
    required this.gameWithAch,
  });

  int achCount;
  int gameWithAch;
  List<classes.Game> games;
  double percents;
}

Future<readyIsol> getGameData(
    (
      List<gm.Game> splitedGame,
      String apiKey,
      int steamId,
      String lang
    ) data) async {
  int achCount = 0;
  double percents = 0;
  int gameWithAch = 0;
  List<int> updatetgame = [];
  List<classes.Game> games = [];
  await Future.forEach(data.$1, (game) async {
    final achievements = <classes.Achievement>[];
    final achUrl =
        "http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/?appid=${game.appid}&key=${data.$2}&steamid=${data.$3}&l=${data.$4}";
    final percUrl =
        "http://api.steampowered.com/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=${game.appid}&format=json";
    final icoUrl =
        "https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?appid=${game.appid}&key=${data.$2}&l=${data.$4}";

    final responsesAch = await Future.wait([
      http.get(Uri.parse(achUrl)),
      http.get(Uri.parse(percUrl)),
      http.get(Uri.parse(icoUrl)),
    ]);

    final achResp = responsesAch[0];
    final perResp = responsesAch[1];
    final icoResp = responsesAch[2];
    int totalAch = 0;
    Iterable<classes.Achievement> achievedAch = [];
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
          matchingItem =
              perc_m.Achievement.fromJson({"name": "", "percent": 1});
        }

        final matchingItem2 = icoRes.game.availableGameStats.achievements
            .firstWhere((element) => element.name == item.apiname);

        achievements.add(classes.Achievement()
          ..name = item.name
          ..displayName = matchingItem2.displayName
          ..description = matchingItem2.description
          ..icon = matchingItem2.icon
          ..icongray = matchingItem2.icongray
          ..achieved = item.achieved == 1 ? true : false
          ..percentage = matchingItem.percent
          ..dateOfAch = item.unlocktime);
      }
      totalAch = achievements.length;
     
      achievedAch = achievements.where((item) => item.achieved == true);
      if (achievedAch.isNotEmpty) {
        achCount += achievedAch.length;
        percents += achievedAch.length / totalAch;
        gameWithAch++;
      }
      updatetgame.add(game.appid);
    } else {
      updatetgame.add(game.appid);
    }

    games.add(classes.Game()
      ..appid = game.appid
      ..name = game.name
      ..playtimeForever = game.playtimeForever
      ..imgIconUrl = game.imgIconUrl
      ..percent = achievements.isEmpty ? 0 : achievedAch.length / totalAch
      ..lastPlayTime = game.rtimeLastPlayed
      ..achievements = achievements);
  });

  return readyIsol(
      games: games,
      achCount: achCount,
      percents: percents,
      gameWithAch: gameWithAch);
}

class Api {
  Api({required this.apiKey});

  final String apiKey;

  Future<classes.Account?> getUserData(int steamId, String lang) async {
    try {
      // const secureStorage = FlutterSecureStorage();
      // String? apiKey = await secureStorage.read(key: "apiKey");
      final url =
          'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=$apiKey&ste'
          'amids=$steamId';
      final gamesUrl =
          'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=$apiKey&stea'
          'mid=$steamId&format=json&include_played_free_games=true&include_appinfo=true';

      final responses = await Future.wait([
        compute(fetchData, url),
        compute(fetchData, gamesUrl),
      ]);
      final response = responses[0];
      final gameResponse = responses[1];
      double percents = 0;
      var gameWithAch = 0;
      if (response.statusCode == 200) {
        var achCount = 0;
        Methods db = Methods();
        gm.GameData gameData =
            gm.GameData.fromJson(jsonDecode(gameResponse.body));
        PlayerData userData = PlayerData.fromJson(jsonDecode(response.body));
        final avatarUrl = userData.response.players[0].avatarfull;
        final nickname = userData.response.players[0].personaname;
        final numGames = gameData.response.gameCount;
        List<classes.Game> games = <classes.Game>[];


        int splitter = numGames ~/ 6;
        List<gm.Game> game1 = gameData.response.games.sublist(0, splitter);
        List<gm.Game> game2 =
            gameData.response.games.sublist(splitter, splitter * 2);
        List<gm.Game> game3 =
            gameData.response.games.sublist(splitter * 2, splitter * 3);
        List<gm.Game> game4 =
            gameData.response.games.sublist(splitter * 3, splitter * 4);
        List<gm.Game> game5 =
            gameData.response.games.sublist(splitter * 4, splitter * 5);
        List<gm.Game> game6 =
            gameData.response.games.sublist(splitter * 5, numGames);
        var dataReady = await Future.wait([
          compute(getGameData, (game1, apiKey, steamId, lang)),
          compute(getGameData, (game2, apiKey, steamId, lang)),
          compute(getGameData, (game3, apiKey, steamId, lang)),
          compute(getGameData, (game4, apiKey, steamId, lang)),
          compute(getGameData, (game5, apiKey, steamId, lang)),
          compute(getGameData, (game6, apiKey, steamId, lang)),
        ]);
        for (int i = 0; i < 6; i++) {
          games += dataReady[i].games;
          achCount += dataReady[i].achCount;
          percents += dataReady[i].percents;
          gameWithAch += dataReady[i].gameWithAch;
        }
        final recentUrl =
            "http://api.steampowered.com/IPlayerService/GetRecentlyPlayedGames/v0001/?key=$apiKey&steamid=$steamId&format=json";
        final recentRes = await http.get(Uri.parse(recentUrl));
        final rec = jsonDecode(recentRes.body).toString();
        db.insertUpdateAcc(classes.Account(steamId, nickname, rec, numGames,
            achCount, percents / gameWithAch * 100, avatarUrl, games));
        return classes.Account(steamId, nickname, rec, numGames, achCount,
            percents / gameWithAch * 100, avatarUrl, games);
      } else {
        throw Exception('Failed to load Steam avatar');
      }
    } catch (e) {
      print(e);
    }
    return null; // compute
  }

  Future<bool> checkUpdate(int steamId) async {
    Methods db = Methods();
    classes.Account? user = await db.getUserById(steamId);
    const secureStorage = FlutterSecureStorage();
    String? apiKey = await secureStorage.read(key: "apiKey");
    if (apiKey == null) {
      return false;
    }
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
