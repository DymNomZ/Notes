import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note.dart';

class NotesDB{

  final _notesBox = Hive.box('NotesDB');

  List<Note> loadNotes(){
    List<Note> saveNotesFormatted = [];

    if(_notesBox.get("allnotes") != null){
      List<dynamic> savedNotesList = _notesBox.get("allnotes");
      for(int i = 0; i < savedNotesList.length; i++){
        Note indivNote = Note(id: savedNotesList[i][0], text: savedNotesList[i][0]);
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
      allNotesFormatted.add([id, text]);
    }

    _notesBox.put('all', allNotesFormatted);
  }

}