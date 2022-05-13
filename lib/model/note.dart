import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String notes;
  @HiveField(2)
  final DateTime dateTime;
  @HiveField(3)
  final int color;
  @HiveField(4)
  final bool ispinned;
  @HiveField(5)
  final String noteID;

  Note({
    required this.title,
    required this.notes,
    required this.dateTime,
    required this.color,
    required this.ispinned,
    required this.noteID,
  });
}
