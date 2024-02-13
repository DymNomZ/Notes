import 'package:flutter/material.dart';
import 'package:notesclonedym/classes/note.dart';

import 'classes/classes.dart';

class EditNote extends StatefulWidget {
  const EditNote({super.key});

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //const EditWindowTitle(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ListView(
              children: [
                TextField(
                  cursorColor: Colors.black,
                  controller: _titleController,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 20)),
                ),
                TextField(
                  cursorColor: Colors.black,
                  controller: _contentController,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type something here',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}