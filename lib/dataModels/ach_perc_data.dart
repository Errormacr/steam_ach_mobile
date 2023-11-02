class PercData {
    Achievementpercentages achievementpercentages;

    PercData({
        required this.achievementpercentages,
    });

    factory PercData.fromJson(Map<String, dynamic> json) => PercData(
        achievementpercentages: Achievementpercentages.fromJson(json["achievementpercentages"]),
    );

    Map<String, dynamic> toJson() => {
        "achievementpercentages": achievementpercentages.toJson(),
    };
}

class Achievementpercentages {
    List<Achievement> achievements;

    Achievementpercentages({
        required this.achievements,
    });

    factory Achievementpercentages.fromJson(Map<String, dynamic> json) => Achievementpercentages(
        achievements: List<Achievement>.from(json["achievements"].map((x) => Achievement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "achievements": List<dynamic>.from(achievements.map((x) => x.toJson())),
    };
}

class Achievement {
    String name;
    double percent;

    Achievement({
        required this.name,
        required this.percent,
    });

    factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        name: json["name"],
        percent: json["percent"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "percent": percent,
    };
}
