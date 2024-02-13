import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/note.dart';
import 'package:notesclonedym/classes/window.dart';
import 'splash.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  String path = '';
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    path = envVars['HOME']!;
  } else if (Platform.isLinux) {
    path = envVars['HOME']!;
  } else if (Platform.isWindows) {
    path = envVars['UserProfile']!;
  }
  path = path.replaceAll('\\', '/');
  path = "$path/Documents/StoredNotes!";

  await Hive.initFlutter(path);
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(WindowAdapter());
  noteBox = await Hive.openBox<Note>('noteBox');
  windowBox = await Hive.openBox<Window>('windowBox');
  
  runApp(const MyApp());
  doWhenWindowReady(() {
  const initialSize = Size(350, 350);
  appWindow.minSize = initialSize;
  appWindow.size = initialSize;
  appWindow.alignment = Alignment.center;
  appWindow.show();
});


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}