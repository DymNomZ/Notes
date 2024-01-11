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
    notesdb.notesBox.put(note.id, note);
    notifyListeners();
  }

  void updateNote(Note note, String text, String title, Color color){
    for(int i = 0; i < NoteList.length; i++){
      if(NoteList[i].id == note.id) {
        NoteList[i].text = text;
        NoteList[i].title = title;
        NoteList[i].color = color;
        notesdb.notesBox.putAt(i, NoteList[i]);
      }
    notifyListeners();
    }
  }

  void deleteNote(Note note){
    for(int i = 0; i < NoteList.length; i++){
      if(NoteList[i].id == note.id) {
        notesdb.notesBox.delete(note.id);
      }
      notifyListeners();
    }
    NoteList.remove(note);
    notifyListeners();
  }
}