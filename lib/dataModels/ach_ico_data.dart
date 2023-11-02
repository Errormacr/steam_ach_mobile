class IconData {
  Game game;

  IconData({
    required this.game,
  });

  factory IconData.fromJson(Map<String, dynamic> json) => IconData(
        game: Game.fromJson(json["game"]),
      );

  Map<String, dynamic> toJson() => {
        "game": game.toJson(),
      };
}

class Game {
  String gameVersion;
  AvailableGameStats availableGameStats;
  static const String gameNameIfnull = "not available";
  Game({
    required this.gameVersion,
    required this.availableGameStats,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        gameVersion: json["gameVersion"],
        availableGameStats:
            AvailableGameStats.fromJson(json["availableGameStats"]),
      );

  Map<String, dynamic> toJson() => {
        "gameVersion": gameVersion,
        "availableGameStats": availableGameStats.toJson(),
      };
}

class AvailableGameStats {
  List<Achievement> achievements;
  List<Stat>? stats;

  AvailableGameStats({
    required this.achievements,
  });

  factory AvailableGameStats.fromJson(Map<String, dynamic> json) =>
      AvailableGameStats(
        achievements: List<Achievement>.from(
            json["achievements"].map((x) => Achievement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "achievements": List<dynamic>.from(achievements.map((x) => x.toJson())),
      };
}

class Achievement {
  String name;
  int defaultvalue;
  String displayName;
  int hidden;
  String? description;
  String icon;
  String icongray;

  Achievement({
    required this.name,
    required this.defaultvalue,
    required this.displayName,
    required this.hidden,
    required this.description,
    required this.icon,
    required this.icongray,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        name: json["name"],
        defaultvalue: json["defaultvalue"],
        displayName: json["displayName"],
        hidden: json["hidden"],
        description: json["description"],
        icon: json["icon"],
        icongray: json["icongray"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "defaultvalue": defaultvalue,
        "displayName": displayName,
        "hidden": hidden,
        "description": description,
        "icon": icon,
        "icongray": icongray,
      };
}

class Stat {
  String name;
  int defaultvalue;
  String displayName;

  Stat({
    required this.name,
    required this.defaultvalue,
    required this.displayName,
  });

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        name: json["name"],
        defaultvalue: json["defaultvalue"],
        displayName: json["displayName"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "defaultvalue": defaultvalue,
        "displayName": displayName,
      };
}
