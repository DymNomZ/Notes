import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'notedata.dart';
void main() async{

  await Hive.initFlutter("C:/Users/User/Desktop/storednotes-Jot!");
  await Hive.openBox('NotesDB');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteData(),
      builder: (context, child) => const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      )
    );
  }
}