import 'package:flutter/material.dart';
import 'package:notesclonedym/storednotes.dart';
import 'note.dart';

class NoteData extends ChangeNotifier{

  final notesdb = NotesDB();

  List<Note> NoteList = [];

  void initializeNotes(){
    NoteList = notesdb.loadNotes();
  }

  List<Note> getNoteList() {
    return NoteList;
  }

  void addNote(Note note){
    NoteList.add(note);
    notifyListeners();
  }

  void updateNote(Note note, String text){
    for(int i = 0; i < NoteList.length; i++){
      if(NoteList[i].id == note.id) NoteList[i].text = text;
    }
    notifyListeners();
  }

  void deleteNote(Note note){
    NoteList.remove(note);
    notifyListeners();
  }
}