import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject{

  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime modifiedTime;

  @HiveField(3)
  Color barColor;

  @HiveField(4)
  Color bodyColor;

  Note({
    required this.title,
    required this.content,
    required this.modifiedTime,
    required this.barColor,
    required this.bodyColor
  });
  
}