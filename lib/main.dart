import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/note.dart';
import 'package:notesclonedym/classes/window.dart';
import 'package:notesclonedym/functions/functions.dart';
import 'package:notesclonedym/variables.dart';
import 'package:window_manager/window_manager.dart';
import 'splash.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    basePath = envVars['HOME']!;
  } else if (Platform.isLinux) {
    basePath = envVars['HOME']!;
  } else if (Platform.isWindows) {
    basePath = envVars['UserProfile']!;
  }
  basePath = basePath.replaceAll('\\', '/');
  String savePath = "$basePath/Documents/StoredNotes!";

  await Hive.initFlutter(savePath);
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(WindowAdapter());
  noteBox = await Hive.openBox<Note>('noteBox');
  windowBox = await Hive.openBox<Window>('windowBox');
  folderBox = await Hive.openBox<String>('folderBox');
  settingsBox = await Hive.openBox<bool>('settingsBox');

  stayOnTop = settingsBox.get('stayOnTop', defaultValue: stayOnTop);
  askBeforeDeleting =
      settingsBox.get('askBeforeDeleting', defaultValue: askBeforeDeleting);

  windowManager.setAlwaysOnTop(stayOnTop);
  cleanupOrphanedImages();

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splash(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: supportedLangs.map((langCode) => Locale(langCode)).toList(),
    );
  }
}
