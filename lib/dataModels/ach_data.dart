class AchData {
  Playerstats playerstats;

  AchData({
    required this.playerstats,
  });

  factory AchData.fromJson(Map<String, dynamic> json) => AchData(
        playerstats: Playerstats.fromJson(json["playerstats"]),
      );

  Map<String, dynamic> toJson() => {
        "playerstats": playerstats.toJson(),
      };
}

class Playerstats {
  String steamId;
  String gameName;
  List<Achievement> achievements;
  bool success;

  Playerstats({
    required this.steamId,
    required this.gameName,
    required this.achievements,
    required this.success,
  });

  factory Playerstats.fromJson(Map<String, dynamic> json) => Playerstats(
        steamId: json["steamID"],
        gameName: json["gameName"],
        achievements: List<Achievement>.from(
            json["achievements"].map((x) => Achievement.fromJson(x))),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "steamID": steamId,
        "gameName": gameName,
        "achievements": List<dynamic>.from(achievements.map((x) => x.toJson())),
        "success": success,
      };
}

class Achievement {
  String apiname;
  int achieved;
  int unlocking;
  String name;
  String description;

  Achievement({
    required this.apiname,
    required this.achieved,
    required this.unlocking,
    required this.name,
    required this.description,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        apiname: json["apiname"],
        achieved: json["achieved"],
        unlocking: json["unlocktime"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "apiname": apiname,
        "achieved": achieved,
        "unlocktime": unlocking,
        "name": name,
        "description": description,
      };
}
