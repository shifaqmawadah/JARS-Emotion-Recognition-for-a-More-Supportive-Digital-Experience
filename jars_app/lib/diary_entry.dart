import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  String text;

  @HiveField(2)
  String emotion;

  @HiveField(3)
  String emoji;

  DiaryEntry({
    required this.date,
    required this.text,
    required this.emotion,
    required this.emoji,
  });
}
