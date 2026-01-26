import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:notesclonedym/buttons/buttons.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/note.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:notesclonedym/variables.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path/path.dart' as p;

_launchURL() async {
  final Uri url = Uri.parse('https://github.com/DymNomZ');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

String quillJsonToPlainText(String jsonString) {
  try {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    final doc = Document.fromJson(jsonData);
    return doc.toPlainText().trim();
  } catch (e) {
    return jsonString;
  }
}

Future<void> cleanupOrphanedImages() async {
  final Set<String> validImagePaths = {};
  
  for (var note in noteBox.values) {
    try {
      final List<dynamic> ops = jsonDecode(note.richContentJson);
      for (var op in ops) {
        if (op['insert'] is Map && op['insert'].containsKey('image')) {
          String path = op['insert']['image'];
          validImagePaths.add(p.normalize(path));
        }
      }
    } catch (e) {}
  }

  String imagesDirPath = "$basePath/Documents/StoredNotes!/Images";
  final imgDir = Directory(imagesDirPath);

  if (!await imgDir.exists()) return;

  //  Delete orphans
  await for (var entity in imgDir.list()) {
    if (entity is File) {
      String normalizedPath = p.normalize(entity.path);
      if (!validImagePaths.contains(normalizedPath)) {
        print("Deleting orphaned image: $normalizedPath");
        try {
          await entity.delete();
        } catch (e) {
          print("Could not delete $normalizedPath: $e");
        }
      }
    }
    print("Image Cleanup Complete.");
  }
}

List sortToRecent() {
  List notes = noteBox.values.toList();
  notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));

  return notes;
}

Color windowBarDarkMode() {
  if (windowBox.get(0).barColor.computeLuminance() > 0.2) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

Color windowBodyDarkMode() {
  if (windowBox.get(0).bodyColor.computeLuminance() > 0.2) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

WindowButtonColors minMaxCloseDarkMode() {
  if (windowBox.get(0).barColor.computeLuminance() > 0.2) {
    return WindowButtonColors(iconNormal: Colors.black);
  } else {
    return WindowButtonColors(iconNormal: Colors.white);
  }
}

WindowButtonColors minMaxCloseDarkModeNote(Note? note, Color result) {
  if (note != null) {
    if (note.barColor.computeLuminance() > 0.2) {
      return WindowButtonColors(iconNormal: Colors.black);
    } else {
      return WindowButtonColors(iconNormal: Colors.white);
    }
  } else {
    if (result.computeLuminance() > 0.2) {
      return WindowButtonColors(iconNormal: Colors.black);
    } else {
      return WindowButtonColors(iconNormal: Colors.white);
    }
  }
}

Color cardDarkMode(Note note) {
  if (note.barColor.computeLuminance() > 0.2) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

Color noteBarDarkMode(Note? note, Color result) {
  if (note != null) {
    if (note.barColor.computeLuminance() > 0.2) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  } else {
    if (result.computeLuminance() > 0.2) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}

Color noteBodyDarkMode(Note? note, Color result) {
  if (note != null) {
    if (note.bodyColor.computeLuminance() > 0.2) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  } else {
    if (result.computeLuminance() > 0.2) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}

String getExitText() {
  return exitText[Random().nextInt(exitText.length)];
}

class ShowInfo extends StatefulWidget {
  const ShowInfo({super.key});

  @override
  State<ShowInfo> createState() => _ShowInfoState();
}

class _ShowInfoState extends State<ShowInfo> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 200.0,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '☘ App Info ☘',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10, 10, 0),
              child: Text(
                'A simple windows notes application :D!\n\n Visit my Github profile:',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            InkWell(
                onTap: () => _launchURL(),
                child: const Text(
                  'https://github.com/DymNomZ',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                )),
          ],
        ),
      ),
    );
  }
}

class AddFolderDialog extends StatefulWidget {
  final void Function() function;
  const AddFolderDialog({required this.function, super.key});

  @override
  State<AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends State<AddFolderDialog> {
  TextEditingController folderName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 150.0,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Add Folder',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                  controller: folderName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'New Folder',
                    hintStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConfirmButton(onPressed: () {
                  folderBox.put(folderName.text, folderName.text);
                  widget.function();
                  widget.function();
                  Navigator.pop(context);
                }),
                const CancelButton(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SettingsOptions extends StatefulWidget {
  const SettingsOptions({super.key});

  @override
  State<SettingsOptions> createState() => _SettingsOptionsState();
}

class _SettingsOptionsState extends State<SettingsOptions> {

  late bool _currentStayOnTop;
  late bool _currentAskBeforeDeleting;

  @override
  void initState() {
    super.initState();
    _currentStayOnTop = stayOnTop;
    _currentAskBeforeDeleting = askBeforeDeleting;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stay on top",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  Switch(
                      activeColor: dymnomz,
                      activeTrackColor: dymnomz,
                      thumbColor: WidgetStateProperty.all<Color>(Colors.white),
                      trackOutlineColor:
                          WidgetStateProperty.all<Color>(Colors.grey),
                      value: _currentStayOnTop ,
                      onChanged: (value) async {
                        setState(() {
                          _currentStayOnTop  = value;
                        });
                        stayOnTop = value;
                        await settingsBox.put('stayOnTop', value);
                        windowManager.setAlwaysOnTop(stayOnTop);
                      })
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ask before deleting",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  Switch(
                      activeColor: dymnomz,
                      activeTrackColor: dymnomz,
                      thumbColor: WidgetStateProperty.all<Color>(Colors.white),
                      trackOutlineColor:
                          WidgetStateProperty.all<Color>(Colors.grey),
                      value: _currentAskBeforeDeleting,
                      onChanged: (value) async {
                        setState(() {
                           _currentAskBeforeDeleting = value;
                        });
                        askBeforeDeleting = value;
                        await settingsBox.put('askBeforeDeleting', value);
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Converts a Color to a Hex string for Quill (e.g., "#FF0000")
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

// Converts a Hex string from Quill back to a Color
Color hexToColor(String? hexString) {
  if (hexString == null) return Colors.black; // Default to black if no color set
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class ChoseColor extends StatefulWidget {
  final int colorPart;
  final Color currentColor;
  const ChoseColor(
      {required this.colorPart, required this.currentColor, super.key});

  @override
  State<ChoseColor> createState() => _ChoseColorState();
}

class _ChoseColorState extends State<ChoseColor> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                (widget.colorPart == 1)
                    ? 'Select Bar Color'
                    : (widget.colorPart == 2)
                    ? 'Select Body Color'
                    : 'Select Font Color',
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
            ),
            Row(
              children: [
                ColorPad(color: Colors.red.shade400),
                ColorPad(color: Colors.orange.shade400),
                ColorPad(color: Colors.yellow.shade400),
                ColorPad(color: Colors.green.shade400),
                ColorPad(color: Colors.blue.shade400),
              ],
            ),
            Row(
              children: [
                ColorPad(color: Colors.purple.shade300),
                ColorPad(color: Colors.pink.shade200),
                ColorPad(color: Colors.brown.shade300),
                ColorPad(color: Colors.yellow.shade50),
                ColorPad(color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
                style: const ButtonStyle(
                    surfaceTintColor: MaterialStatePropertyAll(Colors.white)),
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (_) =>
                        ChooseHexColor(currentColor: widget.currentColor),
                  );
                  Navigator.pop(context, result);
                },
                child: const Text('Custom Color',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20)))
          ],
        ),
      ),
    );
  }
}

class ChooseHexColor extends StatefulWidget {
  Color currentColor;

  ChooseHexColor({required this.currentColor, super.key});

  @override
  State<ChooseHexColor> createState() => _ChooseHexColorState();
}

class _ChooseHexColorState extends State<ChooseHexColor> {
  @override
  Widget build(BuildContext context) {
    double appSize = MediaQuery.of(context).size.height;
    return Dialog(
      child: Container(
        width: 350,
        height: 560,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Visibility(
              visible: appSize < 565,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: SlidePicker(
                    indicatorBorderRadius:
                        const BorderRadius.all(Radius.circular(15.0)),
                    colorModel: ColorModel.hsv,
                    pickerColor: widget.currentColor,
                    enableAlpha: false,
                    showParams: true,
                    labelTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                    sliderTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                    onColorChanged: (selectedColor) {
                      setState(() {
                        widget.currentColor = selectedColor;
                      });
                    },
                  )),
            ),
            Visibility(
              visible: appSize >= 565,
              child: ColorPicker(
                  paletteType: PaletteType.hueWheel,
                  labelTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                  enableAlpha: false,
                  hexInputBar: true,
                  portraitOnly: true,
                  colorPickerWidth: 300,
                  pickerColor: widget.currentColor,
                  onColorChanged: (selectedColor) {
                    setState(() {
                      widget.currentColor = selectedColor;
                    });
                  }),
            ),
            Visibility(
                visible: appSize < 565,
                child: const Text('Increase screen size for more options!',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14))),
            const SizedBox(height: 10),
            ElevatedButton(
                style: const ButtonStyle(
                    surfaceTintColor: MaterialStatePropertyAll(Colors.white)),
                onPressed: () => Navigator.pop(context, widget.currentColor),
                child: const Text('Save',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20)))
          ],
        ),
      ),
    );
  }
}

class ConfirmDelete extends StatefulWidget {
  const ConfirmDelete({super.key});

  @override
  State<ConfirmDelete> createState() => _ConfirmDeleteState();
}

class _ConfirmDeleteState extends State<ConfirmDelete> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      height: 100,
      width: 200,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Confirm Delete?',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                color: Colors.white,
              )),
              const ConfirmButton(),
              const CancelButton(),
              Expanded(
                  child: Container(
                color: Colors.white,
              )),
            ],
          ),
        ],
      ),
    ));
  }
}
