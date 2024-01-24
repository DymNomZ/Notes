import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:notesclonedym/buttons/buttons.dart';
import 'package:notesclonedym/edit.dart';
import 'package:notesclonedym/functions/functions.dart';

class WindowTitle extends StatefulWidget {

  const WindowTitle({super.key});

  @override
  State<WindowTitle> createState() => _WindowTitleState();
}

class _WindowTitleState extends State<WindowTitle> {

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Container(
            color: Colors.amber,
            child: Row(
              children: [
                Row(
                  children: [
                    AddNoteButton(onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const EditNote(),
                        ),
                      );
                    }),
                    ShowInfoButton(onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => const ShowInfo(),
                      );
                      return result;
                    }),
                    ChoseColorButton(onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => ChoseWindowColor(),
                      );
                      return result;
                    })
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: MoveWindow(
              child: Container(
                //to be made a class
                color: Colors.amber,
              ),
            ),
          ),
          Container(
            //to be made a class
            color: Colors.amber,
            child: Row(
              children: [
                Row(
                  children: [
                    MinimizeWindowButton(),
                    MaximizeWindowButton(),
                    CloseWindowButton(),
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

class EditWindowTitle extends StatefulWidget {
  const EditWindowTitle({super.key});

  @override
  State<EditWindowTitle> createState() => _EditWindowTitleState();
}

class _EditWindowTitleState extends State<EditWindowTitle> {
  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Container(
            color: Colors.amber,
            child: Row(
              children: [
                Row(
                  children: [
                    ReturnButton(onPressed: () => Navigator.pop(context)),
                    ChoseColorButton(onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => ChoseWindowColor(),
                      );
                      return result;
                    })
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: MoveWindow(
              child: Container(
                //to be made a class
                color: Colors.amber,
              ),
            ),
          ),
          Container(
            //to be made a class
            color: Colors.amber,
            child: Row(
              children: [
                Row(
                  children: [
                    MinimizeWindowButton(),
                    MaximizeWindowButton(),
                    CloseWindowButton(),
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
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 8),
        hintText: "Search",
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon:  Icon(
          Icons.search,
          color: Colors.grey,
          size: 20
        ),
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
