import 'package:isar/isar.dart';
part 'db_classes.g.dart';

@Collection()
class Account {
  Id id;

  String username;
  String recent;
  int gameCount;
  int achievementCount;
  double percentage;
  String avaUrl;
  List<Game> games;

  Account(this.id, this.username, this.recent,this.gameCount, this.achievementCount,
      this.percentage, this.avaUrl, this.games);
}

@embedded
class Game {
  int? appid;
  String? name;
  int? playtimeForever;
  String? imgIconUrl;
  double? percent;
  List<Achievement>? achievements;
}

@embedded
class Achievement {
  String? name;
  String? displayName;
  String? description;
  String? icon;
  String? icongray;
  bool achieved = false;
  float? percentage;
}
