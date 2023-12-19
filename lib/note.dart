import 'package:flutter/material.dart';

class Note{
  int id;
  String text;
  String? title;
  Color color;

  Note({required this.id, required this.text, this.title, required this.color});
}