// To parse this JSON data, do
//
//     final reply = replyFromJson(jsonString);

import 'dart:convert';

Reply replyFromJson(String str) => Reply.fromJson(json.decode(str));

String replyToJson(Reply data) => json.encode(data.toJson());

class Reply {
  Reply({
    required this.reply,
    required this.vote,
    this.userId,
  });

  String reply;
  int vote;
  String? userId;

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        reply: json["reply"] == null ? "" : json["reply"],
        vote: json["vote"] == null ? 0 : (json["vote"] as num).toInt(),
        userId: json["userID"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "reply": reply,
        "vote": vote,
        if (userId != null) "userID": userId,
      };
}
