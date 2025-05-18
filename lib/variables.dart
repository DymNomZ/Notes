import 'dart:async';
import 'dart:ui';

List<String> exitText = ["Let's call it a day 😌", "Leaving already? 🤔", "That's a wrap! 💪", 
                          "Goodbye 👋", "Goodjob 🙌", "Work done ✅"];
String currentFolder = 'Notes';
StreamController<String> folderStream = StreamController.broadcast();

//settings vars
bool stayOnTop = true;
bool askBeforeDeleting = true;

Color dymnomz = const Color(0xFF0BFF00); // Easter Egg :p