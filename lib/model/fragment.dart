// To parse this JSON data, do
//
//     final fragment = fragmentFromJson(jsonString);

import 'dart:convert';

Fragment fragmentFromJson(String str) => Fragment.fromJson(json.decode(str));

String fragmentToJson(Fragment data) => json.encode(data.toJson());

class Fragment {
  Fragment({this.id, this.results, this.success});

  int? id;
  List<ResultFragment>? results;
  String? success;

  factory Fragment.fromJson(Map<String, dynamic> json) => Fragment(
      id: json["id"] == null ? null : json["id"],
      results: json["results"] == null
          ? null
          : List<ResultFragment>.from(
              json["results"].map((x) => ResultFragment.fromJson(x))),
      success: json["success"] == null ? null : json["success"]);

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "results": results == null
            ? null
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "success": success == null ? null : success
      };
}

class ResultFragment {
  ResultFragment({
    this.iso6391,
    this.iso31661,
    this.name,
    this.key,
    this.site,
    this.size,
    this.type,
    this.official,
    this.publishedAt,
    this.id,
  });

  String? iso6391;
  String? iso31661;
  String? name;
  String? key;
  String? site;
  int? size;
  String? type;
  bool? official;
  DateTime? publishedAt;
  String? id;

  factory ResultFragment.fromJson(Map<String, dynamic> json) => ResultFragment(
        iso6391: json["iso_639_1"] == null ? null : json["iso_639_1"],
        iso31661: json["iso_3166_1"] == null ? null : json["iso_3166_1"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
        site: json["site"] == null ? null : json["site"],
        size: json["size"] == null ? null : json["size"],
        type: json["type"] == null ? null : json["type"],
        official: json["official"] == null ? null : json["official"],
        publishedAt: json["published_at"] == null
            ? null
            : DateTime.parse(json["published_at"]),
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "iso_639_1": iso6391 == null ? null : iso6391,
        "iso_3166_1": iso31661 == null ? null : iso31661,
        "name": name == null ? null : name,
        "key": key == null ? null : key,
        "site": site == null ? null : site,
        "size": size == null ? null : size,
        "type": type == null ? null : type,
        "official": official == null ? null : official,
        "published_at":
            publishedAt == null ? null : publishedAt!.toIso8601String(),
        "id": id == null ? null : id,
      };
}
