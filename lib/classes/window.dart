import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'window.g.dart';

@HiveType(typeId: 1)
class Window extends HiveObject{

  @HiveField(0)
  Color barColor;

  @HiveField(1)
  Color bodyColor;

  Window({
    required this.barColor,
    required this.bodyColor
  });
  
}