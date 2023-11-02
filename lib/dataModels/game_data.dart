class GameData {
    Response response;

    GameData({
        required this.response,
    });

    factory GameData.fromJson(Map<String, dynamic> json) => GameData(
        response: Response.fromJson(json["response"]),
    );

    Map<String, dynamic> toJson() => {
        "response": response.toJson(),
    };
}

class Response {
    int gameCount;
    List<Game> games;

    Response({
        required this.gameCount,
        required this.games,
    });

    factory Response.fromJson(Map<String, dynamic> json) => Response(
        gameCount: json["game_count"],
        games: List<Game>.from(json["games"].map((x) => Game.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "game_count": gameCount,
        "games": List<dynamic>.from(games.map((x) => x.toJson())),
    };
}

class Game {
    int appid;
    String name;
    int playtimeForever;
    String imgIconUrl;
    bool? hasCommunityVisibleStats;
    int playtimeWindowsForever;
    int playtimeMacForever;
    int playtimeLinuxForever;
    int rtimeLastPlayed;
    int playtimeDisconnected;
    List<int>? contentDescriptorids;
    bool? hasLeaderboards;
    int? playtime2Weeks;

    Game({
        required this.appid,
        required this.name,
        required this.playtimeForever,
        required this.imgIconUrl,
        this.hasCommunityVisibleStats,
        required this.playtimeWindowsForever,
        required this.playtimeMacForever,
        required this.playtimeLinuxForever,
        required this.rtimeLastPlayed,
        required this.playtimeDisconnected,
        this.contentDescriptorids,
        this.hasLeaderboards,
        this.playtime2Weeks,
    });

    factory Game.fromJson(Map<String, dynamic> json) => Game(
        appid: json["appid"],
        name: json["name"],
        playtimeForever: json["playtime_forever"],
        imgIconUrl: json["img_icon_url"],
        hasCommunityVisibleStats: json["has_community_visible_stats"],
        playtimeWindowsForever: json["playtime_windows_forever"],
        playtimeMacForever: json["playtime_mac_forever"],
        playtimeLinuxForever: json["playtime_linux_forever"],
        rtimeLastPlayed: json["rtime_last_played"],
        playtimeDisconnected: json["playtime_disconnected"],
        contentDescriptorids: json["content_descriptorids"] == null ? [] : List<int>.from(json["content_descriptorids"]!.map((x) => x)),
        hasLeaderboards: json["has_leaderboards"],
        playtime2Weeks: json["playtime_2weeks"],
    );

    Map<String, dynamic> toJson() => {
        "appid": appid,
        "name": name,
        "playtime_forever": playtimeForever,
        "img_icon_url": imgIconUrl,
        "has_community_visible_stats": hasCommunityVisibleStats,
        "playtime_windows_forever": playtimeWindowsForever,
        "playtime_mac_forever": playtimeMacForever,
        "playtime_linux_forever": playtimeLinuxForever,
        "rtime_last_played": rtimeLastPlayed,
        "playtime_disconnected": playtimeDisconnected,
        "content_descriptorids": contentDescriptorids == null ? [] : List<dynamic>.from(contentDescriptorids!.map((x) => x)),
        "has_leaderboards": hasLeaderboards,
        "playtime_2weeks": playtime2Weeks,
    };
}
