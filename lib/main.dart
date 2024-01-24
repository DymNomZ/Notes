import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'splash.dart';
import 'package:window_size/window_size.dart';
void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  
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