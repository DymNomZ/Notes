import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notesclonedym/color.g.dart';
import 'package:notesclonedym/note.dart';
import 'package:notesclonedym/splash.dart';
import 'package:provider/provider.dart';
import 'notedata.dart';
import 'package:window_size/window_size.dart';
void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Notes!');
    setWindowMinSize(const Size(400, 300));
  }

  await Hive.initFlutter("C:/Users/User/Documents/storednotes-Notes!");
  Hive.registerAdapter(lolAdapter());
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox('notesDB');

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
      home: Splash(),
      )
    );
  }
}