class PlayerData {
    Response response;

    PlayerData({
        required this.response,
    });

    factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
        response: Response.fromJson(json["response"]),
    );

    Map<String, dynamic> toJson() => {
        "response": response.toJson(),
    };
}

class Response {
    List<Player> players;

    Response({
        required this.players,
    });

    factory Response.fromJson(Map<String, dynamic> json) => Response(
        players: List<Player>.from(json["players"].map((x) => Player.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "players": List<dynamic>.from(players.map((x) => x.toJson())),
    };
}

class Player {
    String steamid;
    int communityvisibilitystate;
    int profilestate;
    String personaname;
    int commentpermission;
    String profileurl;
    String avatar;
    String avatarmedium;
    String avatarfull;
    String avatarhash;
    int lastlogoff;
    int? personastate;
    String primaryclanid;
    int timecreated;
    int? personastateflags;
    String? loccountrycode;

    Player({
        required this.steamid,
        required this.communityvisibilitystate,
        required this.profilestate,
        required this.personaname,
        required this.commentpermission,
        required this.profileurl,
        required this.avatar,
        required this.avatarmedium,
        required this.avatarfull,
        required this.avatarhash,
        required this.lastlogoff,
        this.personastate,
        required this.primaryclanid,
        required this.timecreated,
        this.personastateflags,
        this.loccountrycode,
    });

    factory Player.fromJson(Map<String, dynamic> json) => Player(
        steamid: json["steamid"],
        communityvisibilitystate: json["communityvisibilitystate"],
        profilestate: json["profilestate"],
        personaname: json["personaname"],
        commentpermission: json["commentpermission"],
        profileurl: json["profileurl"],
        avatar: json["avatar"],
        avatarmedium: json["avatarmedium"],
        avatarfull: json["avatarfull"],
        avatarhash: json["avatarhash"],
        lastlogoff: json["lastlogoff"],
        personastate: json["personastate"],
        primaryclanid: json["primaryclanid"],
        timecreated: json["timecreated"],
        personastateflags: json["personastateflags"],
        loccountrycode: json["loccountrycode"],
    );

    Map<String, dynamic> toJson() => {
        "steamid": steamid,
        "communityvisibilitystate": communityvisibilitystate,
        "profilestate": profilestate,
        "personaname": personaname,
        "commentpermission": commentpermission,
        "profileurl": profileurl,
        "avatar": avatar,
        "avatarmedium": avatarmedium,
        "avatarfull": avatarfull,
        "avatarhash": avatarhash,
        "lastlogoff": lastlogoff,
        "personastate": personastate,
        "primaryclanid": primaryclanid,
        "timecreated": timecreated,
        "personastateflags": personastateflags,
        "loccountrycode": loccountrycode,
    };
}