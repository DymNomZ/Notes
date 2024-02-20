import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/window.dart';
import 'buttons/buttons.dart';
import 'functions/functions.dart';
import 'classes/classes.dart';
import 'classes/note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List filteredNotes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool isEditing = false;
  Window userWindow = (windowBox.isNotEmpty) ? windowBox.getAt(0) : Window(barColor: Colors.amber, bodyColor: Colors.white);
  String newTitle = '';
  String newContent = '';
  int axisCount = 1;
  double aspectRatio = 2.8;

  fillNoteList(){
    setState(() {
      filteredNotes = noteBox.values.toList();
    });
  }

  @override
  void initState(){
    super.initState();
    fillNoteList();
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = noteBox.values
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void choseBodyColor() async {
    final result = await showDialog(
      context: context,
      builder: (_) => ChoseWindowColor(colorPart: 2, currentColor: userWindow.bodyColor),
    ); 
    if(result != null) {
      if(windowBox.isEmpty){
        setState(() {
          userWindow.bodyColor = result;
          windowBox.add(userWindow);
        });
      }
      else{
        setState(() {
          userWindow.bodyColor = result;
          userWindow.save();
        });
      }
    }
  }

  void changeGridValues(){
    if(axisCount == 1 && aspectRatio == 2.8) {
      setState(() {
        axisCount = 4;
        aspectRatio = 3.1;
        appWindow.maximizeOrRestore();
      });
    }
    else {
      setState(() {
        axisCount = 1;
        aspectRatio = 2.8;
        appWindow.maximizeOrRestore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userWindow.bodyColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WindowTitle(dialog: tempNoteDialog, bodydialog: choseBodyColor, gridFunction: changeGridValues),
          SearchField(onChanged: onSearchTextChanged),
          (noteBox.isNotEmpty)
          ? Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                crossAxisCount: axisCount,
                childAspectRatio: aspectRatio
              ),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                Note currentNote = filteredNotes[index];
                return Card(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  color: currentNote.barColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      onTap: () {
                        setState(() => isEditing = true);
                        tempNoteDialog(currentNote);
                        },
                      title: RichText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: '${currentNote.title} \n',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.5),
                            children: [
                              TextSpan(
                                text: currentNote.content,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    height: 1.5),
                              )
                            ]),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(currentNote.modifiedTime)}\nCreated on: ${DateFormat('EEE MMM d, yyyy h:mm a').format(currentNote.creationTime)}',
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade800),
                        ),
                      ),
                      trailing: DeleteNoteButton(onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => const ConfirmDelete(),
                      );
                      if (result != null && result) {
                        setState(() {
                          filteredNotes.remove(currentNote);
                          currentNote.delete();
                        });
                      }
                    })
                )));
              }
            )
          )
          : const Padding(
             padding: EdgeInsets.all(30.0),
             child: Center(
               child: Text('Create a note', 
               style: TextStyle(fontWeight: FontWeight.w400, 
               color: Colors.black)
               ),
             ),
           ),
        ],
      ),
    );
  }

  tempNoteDialog([Note? note]){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        Color noteBarColor = Colors.yellow.shade50;
        Color noteBodyColor = Colors.yellow.shade50;
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: (isEditing) ? note?.bodyColor : noteBodyColor,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WindowTitleBarBox(
                    child: Row(
                      children: [
                        Container(
                          color: (isEditing) ? note?.barColor : noteBarColor,
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  ReturnButton(onPressed: () {
                                    if(_titleController.text.isNotEmpty || _contentController.text.isNotEmpty) {
                                      if(isEditing) {
                                        if(note?.title != _titleController.text || note?.content != _contentController.text) {
                                          setState(() {
                                            note?.title = _titleController.text;
                                            note?.content = _contentController.text;
                                            note?.modifiedTime = DateTime.now();
                                            note?.save();
                                            fillNoteList();
                                            isEditing = false;
                                          });
                                        }
                                      }
                                      else {
                                        setState(() {
                                          final Note note = Note(
                                            title: _titleController.text,
                                            content: _contentController.text,
                                            modifiedTime: DateTime.now(),
                                            barColor: noteBarColor,
                                            bodyColor: noteBodyColor,
                                            creationTime: DateTime.now(),
                                          );
                                          noteBox.add(note);
                                          fillNoteList();
                                          newTitle = '';
                                          newContent = '';
                                        });
                                      }
                                    }
                                      Navigator.pop(context);
                                    }
                                  ),
                                  ChoseColorButton(onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (_) => ChoseWindowColor(colorPart: 1, currentColor: note!.barColor),
                                    );
                                    if(result != null) {
                                      if(isEditing) {
                                        setState(() {
                                          note?.barColor = result;
                                          note?.title = _titleController.text;
                                          note?.content = _contentController.text;
                                        });
                                      }
                                      else {
                                        setState(() {
                                          noteBarColor = result;
                                          newTitle = _titleController.text;
                                          newContent = _contentController.text;
                                        });
                                      }
                                    }
                                  }),
                                  ChoseColorButton(onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (_) => ChoseWindowColor(colorPart: 2, currentColor: note!.bodyColor),
                                    );
                                    if(result != null) {
                                      if(isEditing) {
                                        setState(() {
                                          note?.bodyColor = result;
                                          note?.title = _titleController.text;
                                          note?.content = _contentController.text;
                                        });
                                      }
                                      else {
                                        setState(() {
                                          noteBodyColor = result;
                                          newTitle = _titleController.text;
                                          newContent = _contentController.text;
                                        });
                                      }
                                    }
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
                              color: (isEditing) ? note?.barColor : noteBarColor,
                            ),
                          ),
                        ),
                        Container(
                          //to be made a class
                          color: (isEditing) ? note?.barColor : noteBarColor,
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
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListView(
                      children: [
                        TextField(
                          cursorColor: Colors.black,
                          controller: _titleController = TextEditingController(text: note?.title ?? newTitle),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Title',
                              hintStyle: TextStyle(color: Colors.black, fontSize: 20)),
                        ),
                        TextField(
                          cursorColor: Colors.black,
                          controller: _contentController = TextEditingController(text: note?.content ?? newContent),
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                          maxLines: null,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type something here',
                              hintStyle: TextStyle(color: Colors.black, fontSize: 15)),
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            );
          }
        );
      }
    );
  }
}