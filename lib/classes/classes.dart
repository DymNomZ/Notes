import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:notesclonedym/buttons/buttons.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/window.dart';
import 'package:notesclonedym/functions/functions.dart';
import 'package:notesclonedym/variables.dart';

class WindowTitle extends StatefulWidget {
  final VoidCallback dialog;
  final VoidCallback bodydialog;
  final VoidCallback gridFunction;
  final VoidCallback folderFunc;
  const WindowTitle({required this.dialog, required this.bodydialog, required this.gridFunction, 
  required this.folderFunc, super.key});

  @override
  State<WindowTitle> createState() => _WindowTitleState();
}

class _WindowTitleState extends State<WindowTitle> {
  Window userWindow = windowBox.get(0);

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Container(
            color: userWindow.barColor,
            child: Row(
              children: [
                Row(
                  children: [
                    AddNoteButton(onPressed: widget.dialog),
                    FolderButton(onPressed: widget.folderFunc),
                    ChoseColorButton(onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => ChoseWindowColor(colorPart: 1, currentColor: userWindow.barColor),
                      ); 
                      if(result != null) {
                        setState(() {
                          userWindow.barColor = result;
                          userWindow.save();
                        });
                      }
                    }, darkModeType: 1, color: DymNomZ),
                    ChoseColorButton(onPressed: widget.bodydialog, darkModeType: 1, color: DymNomZ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: MoveWindow(
              child: Container(
                //to be made a class
                color: userWindow.barColor,
              ),
            ),
          ),
          Container(
            //to be made a class
            color: userWindow.barColor,
            child: Row(
              children: [
                Row(
                  children: [
                    MinimizeWindowButton(colors: minMaxCloseDarkMode()),
                    MaximizeWindowButton(colors: minMaxCloseDarkMode(), onPressed: widget.gridFunction,),
                    CloseWindowButton(colors: minMaxCloseDarkMode()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  final void Function(String)? onChanged;
  const SearchField({super.key, this.onChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      style: TextStyle(fontSize: 14, color: windowBodyDarkMode()),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        hintText: "Search",
        hintStyle: TextStyle(color: windowBodyDarkMode()),
        prefixIcon:  Icon(
          Icons.search,
          color: windowBodyDarkMode(),
          size: 20
        ),
        fillColor: Colors.transparent,
        filled: true,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
