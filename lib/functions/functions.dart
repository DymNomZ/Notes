import 'package:flutter/material.dart';
import 'package:notesclonedym/buttons/buttons.dart';
import 'package:notesclonedym/classes/note.dart';
import 'package:url_launcher/url_launcher.dart';

  _launchURL() async {
   final Uri url = Uri.parse('https://github.com/DymNomZ');
   if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
    }
}

    List<Note> sortToRecent() {
    List<Note> notes = sampleNotes;
    notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));

    return notes;
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
                  child: Text('☘ App Info ☘', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                  child: Text('A simple windows notes application :D!\n\n Visit my Github profile:', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),),
                ),
                InkWell(
                  onTap: () => _launchURL(),
                  child: const Text('https://github.com/DymNomZ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400, fontSize: 14),)),
              ],
            ),
          ),
        );
  }
}

class ChoseWindowColor extends StatefulWidget {
  Color color = ColorPad().retrieveSelectedColor;
  ChoseWindowColor({super.key});

  Color get retrieveSelectedColor {
    return color;
  }

  @override
  State<ChoseWindowColor> createState() => _ChoseWindowColorState();
}

class _ChoseWindowColorState extends State<ChoseWindowColor> {
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
                  child: Text('Select Colors', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
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
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Colors.white,
              ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Confirm Delete?', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                      )
                    ),
                    const ConfirmButton(),
                    const CancelButton(),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                      )
                    ),
                  ],
                ),
              ],
            ),
          )
    );
  }
}