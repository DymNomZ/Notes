import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note{

  Note({required this.id, required this.text, this.title, required this.color});

  @HiveField(0)
  int id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String? title;

  @HiveField(3)
  Color color;

}