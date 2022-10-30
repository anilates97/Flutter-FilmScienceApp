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
  });

  String reply;
  int vote;

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        reply: json["reply"] == null ? null : json["reply"],
        vote: json["vote"] == null ? null : json["vote"],
      );

  Map<String, dynamic> toJson() => {
        "reply": reply == null ? null : reply,
        "vote": vote == null ? null : vote,
      };
}
