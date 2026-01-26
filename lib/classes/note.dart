import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject{

  @HiveField(0)
  String title;

  @HiveField(1)
  String richContentJson;

  @HiveField(2)
  DateTime modifiedTime;

  @HiveField(3)
  Color barColor;

  @HiveField(4)
  Color bodyColor;

  @HiveField(5)
  DateTime creationTime;

  @HiveField(6, defaultValue: 'Notes')
  String folder;

  @HiveField(7, defaultValue: -1)
  int orderIndex;

  Note({
    required this.title,
    required this.richContentJson,
    required this.modifiedTime,
    required this.barColor,
    required this.bodyColor,
    required this.creationTime,
    required this.folder,
    required this.orderIndex
  });

  Note get copy {
    final objectInstance = Note(
        title: title,
        richContentJson: richContentJson,
        modifiedTime: modifiedTime,
        barColor: barColor,
        bodyColor: bodyColor,
        creationTime: creationTime,
        folder: folder,
        orderIndex: orderIndex
    );
    return objectInstance;
  }

  @override
  String toString() => 'Note(title: $title, folder: $folder, orderIndex: $orderIndex)';
  
}