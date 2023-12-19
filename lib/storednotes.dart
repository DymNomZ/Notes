import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note.dart';
import 'package:flutter/material.dart';

class NotesDB{

  final _notesBox = Hive.box('NotesDB');

  List<Note> loadNotes(){
    List<Note> saveNotesFormatted = [];

    if(_notesBox.get("allnotes") != null){
      List<dynamic> savedNotesList = _notesBox.get("allnotes");
      for(int i = 0; i < savedNotesList.length; i++){
        Note indivNote = Note(
          id: savedNotesList[i][0], text: savedNotesList[i][0],
          title: savedNotesList[i][0], color: savedNotesList[i][0],
          );
        saveNotesFormatted.add(indivNote);
      }
    }

    return saveNotesFormatted;
  }

  void savedNotes(List<Note> allNotes){
    List<List<dynamic>> allNotesFormatted = [

    ];

    for(var note in allNotes){
      int id = note.id;
      String text = note.text;
      String? title = note.title;
      Color color = note.color;
      allNotesFormatted.add([id, text, title, color]);
    }

    _notesBox.put('all', allNotesFormatted);
  }

}