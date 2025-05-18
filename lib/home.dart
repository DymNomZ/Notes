import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/window.dart';
import 'package:notesclonedym/variables.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
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
  Window userWindow = Window(barColor: Colors.amber, bodyColor: Colors.white);
  String newTitle = '';
  String newContent = '';
  int axisCount = 1;
  double aspectRatio = 2.5;
  List filteredFolders = [];
  final TextEditingController _folderName = TextEditingController();
  String cf = 'Notes';
  bool isMoving = false;

  fillNoteList() {
    List<dynamic> notesForFolder =
        noteBox.values.where((note) => note.folder == cf).toList();

    bool needsMigration = notesForFolder.any((note) =>
        note.orderIndex == null ||
        note.orderIndex == -1); // Assuming -1 is default from HiveField

    if (needsMigration) {
      notesForFolder.sort((a, b) => a.creationTime.compareTo(b.creationTime));
      for (int i = 0; i < notesForFolder.length; i++) {
        if (notesForFolder[i].orderIndex == null ||
            notesForFolder[i].orderIndex == -1 ||
            notesForFolder[i].orderIndex != i) {
          notesForFolder[i].orderIndex = i;
          notesForFolder[i].save();
        }
      }
    }

    notesForFolder.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    setState(() {
      filteredNotes = notesForFolder;
    });
  }

  Future<void> _updateNoteOrderInHive() async {
    for (int i = 0; i < filteredNotes.length; i++) {
      final note = filteredNotes[i];
      if (note.orderIndex != i) {
        note.orderIndex = i;
        await note.save();
      }
    }
    // fillNoteList();
  }

  fillFolderList() {
    setState(() {
      filteredFolders = folderBox.values.toList();
    });
  }

  checkWindowBox() {
    if (windowBox.isNotEmpty) {
      setState(() {
        userWindow = windowBox.get(0);
      });
    } else {
      setState(() {
        windowBox.put(0, userWindow);
      });
    }
  }

  checkFolderBox() {
    if (folderBox.isEmpty) {
      setState(() {
        folderBox.put(0, 'Notes');
      });
    }
  }

  @override
  void initState() {
    folderStream.stream.listen((data) {
      setState(() {
        cf = data;
        fillNoteList();
      });
    });
    super.initState();
    checkFolderBox();
    fillNoteList();
    checkWindowBox();
    fillFolderList();
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = noteBox.values
          .where((note) =>
              (note.content.toLowerCase().contains(searchText.toLowerCase()) ||
                  note.title
                      .toLowerCase()
                      .contains(searchText.toLowerCase())) &&
              note.folder == cf)
          .toList();
    });
  }

  void settingsDialog() async {
    final result = await showDialog(
      context: context,
      builder: (_) => SettingsOptions(),
    );
  }

  void choseBodyColor() async {
    checkWindowBox();
    final result = await showDialog(
      context: context,
      builder: (_) =>
          ChoseWindowColor(colorPart: 2, currentColor: userWindow.bodyColor),
    );
    if (result != null) {
      setState(() {
        userWindow.bodyColor = result;
        userWindow.save();
        checkWindowBox();
      });
    }
  }

  void changeGridValues() {
    if (axisCount == 1 && aspectRatio == 2.5) {
      setState(() {
        axisCount = 4;
        aspectRatio = 2.8;
      });
    } else {
      setState(() {
        axisCount = 1;
        aspectRatio = 2.5;
      });
    }
    appWindow.maximizeOrRestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userWindow.bodyColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WindowTitle(
              dialog: tempNoteDialog,
              bodydialog: choseBodyColor,
              gridFunction: changeGridValues,
              folderFunc: folderList,
              settingsFunc: settingsDialog),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(cf,
                        style: TextStyle(
                            color: windowBodyDarkMode(),
                            fontWeight: FontWeight.bold,
                            fontSize: 20))),
              ),
              Expanded(child: SearchField(onChanged: onSearchTextChanged)),
            ],
          ),
          (noteBox.isNotEmpty)
              ? Expanded(
                  child: ReorderableGridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: axisCount, childAspectRatio: aspectRatio),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    Note currentNote = filteredNotes[index];
                    return Card(
                        key: ValueKey(currentNote),
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        color: currentNote.barColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
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
                                          style: TextStyle(
                                              color: cardDarkMode(currentNote),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              height: 1.5),
                                          children: [
                                            TextSpan(
                                              text: currentNote.content,
                                              style: TextStyle(
                                                  color:
                                                      cardDarkMode(currentNote),
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
                                            color: cardDarkMode(currentNote)),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 13.0),
                                  child: Column(
                                    children: [
                                      DeleteNoteButton(
                                        onPressed: () async {
                                          //if turned on in settings
                                          if (askBeforeDeleting) {
                                            final result = await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  const ConfirmDelete(),
                                            );
                                            if (result != null && result) {
                                              setState(() {
                                                filteredNotes
                                                    .remove(currentNote);
                                                currentNote.delete();
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              filteredNotes.remove(currentNote);
                                              currentNote.delete();
                                            });
                                          }
                                        },
                                        note: currentNote,
                                      ),
                                      MoveButton(
                                          onPressed: () {
                                            setState(() {
                                              isMoving = true;
                                              folderList(currentNote);
                                            });
                                          },
                                          note: currentNote),
                                    ],
                                  ),
                                )
                              ],
                            )));
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }

                      final Note item = filteredNotes.removeAt(oldIndex);
                      filteredNotes.insert(newIndex, item);
                      _updateNoteOrderInHive();
                    });
                  },
                ))
              : Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: Text('Create a note',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: windowBodyDarkMode())),
                  ),
                ),
        ],
      ),
    );
  }

  exitFunc(Color barColor, Color bodyColor, [Note? note]) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              height: 200.0,
              width: 300.0,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      getExitText(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                    child: Text(
                      'You are closing the app\nDo you wish to save?',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: ConfirmButton(onPressed: () {
                          noteFunc(barColor, bodyColor, note);
                          appWindow.close();
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: CancelButton(onPressed: () {
                          appWindow.close();
                        }),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  noteFunc(Color noteBarColor, Color noteBodyColor, [Note? note]) {
    List<dynamic> notesInFolder =
        noteBox.values.where((note) => note.folder == cf).toList();
    int nextOrderIndex = notesInFolder.length;

    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      if (isEditing) {
        if (note?.title != _titleController.text ||
            note?.content != _contentController.text) {
          setState(() {
            note?.title = _titleController.text;
            note?.content = _contentController.text;
            note?.modifiedTime = DateTime.now();
            note?.save();
            isEditing = false;
            fillNoteList();
          });
        }
        setState(() => isEditing = false);
        fillNoteList();
      } else {
        setState(() {
          final Note note = Note(
              title: _titleController.text,
              content: _contentController.text,
              modifiedTime: DateTime.now(),
              barColor: noteBarColor,
              bodyColor: noteBodyColor,
              creationTime: DateTime.now(),
              folder: cf,
              orderIndex: nextOrderIndex);
          noteBox.add(note);
          newTitle = '';
          newContent = '';
          setState(() => isEditing = false);
          fillNoteList();
        });
      }
    }
  }

  folderList([Note? note]) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Scaffold(
                backgroundColor: userWindow.bodyColor,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WindowTitleBarBox(
                      child: Row(
                        children: [
                          Container(
                            color: userWindow.barColor,
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    ReturnButton2(onPressed: () {
                                      if (isMoving) {
                                        setState(() => isMoving = false);
                                      }
                                      Navigator.pop(context);
                                    }),
                                    AddNoteButton(onPressed: () async {
                                      if (isMoving == false) {
                                        final result = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: Container(
                                                  height: 150.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15.0)),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.all(
                                                            10.0),
                                                        child: Text(
                                                          'Add Folder',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    10.0),
                                                        child: TextField(
                                                            controller:
                                                                _folderName,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                            maxLines: 1,
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              hintText:
                                                                  'New Folder',
                                                              hintStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            )),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ConfirmButton(
                                                              onPressed: () {
                                                            setState(() {
                                                              folderBox.put(
                                                                  _folderName
                                                                      .text,
                                                                  _folderName
                                                                      .text);
                                                              fillFolderList();
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                          const CancelButton(),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                        return result;
                                      }
                                    }),
                                    ShowInfoButton(onPressed: () async {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (_) => const ShowInfo(),
                                      );
                                      return result;
                                    }),
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
                                    MinimizeWindowButton(
                                        colors: minMaxCloseDarkMode()),
                                    MaximizeWindowButton(
                                        colors: minMaxCloseDarkMode(),
                                        onPressed: () {
                                          changeGridValues();
                                          setState(() {});
                                        }),
                                    CloseWindowButton(
                                        colors: minMaxCloseDarkMode()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text((isMoving) ? 'Move to?' : 'Folders',
                              style: TextStyle(
                                  color: windowBodyDarkMode(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20))),
                    ),
                    (folderBox.isNotEmpty)
                        ? Expanded(
                            child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: axisCount,
                                    childAspectRatio: 4),
                            itemCount: filteredFolders.length,
                            itemBuilder: (context, index) {
                              String currFold = filteredFolders[index];
                              return Card(
                                  key: ValueKey(index),
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  color: windowBodyDarkMode() == Colors.black
                                      ? Colors.yellow.shade50
                                      : Colors.grey.shade900,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ListTile(
                                          onTap: () {
                                            if (isMoving) {
                                              setState(() {
                                                note?.folder = currFold;
                                                note?.save();
                                                fillNoteList();
                                                isMoving = false;
                                              });
                                            } else {
                                              setState(() {
                                                folderStream.sink.add(currFold);
                                                fillNoteList();
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                          leading: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Icon(
                                              Icons.folder_open_sharp,
                                              size: 20,
                                              color: windowBodyDarkMode(),
                                            ),
                                          ),
                                          title: RichText(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                text: '$currFold \n',
                                                style: TextStyle(
                                                    color: windowBodyDarkMode(),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    height: 1.4),
                                              )),
                                          trailing: (currFold == 'Notes')
                                              ? null
                                              : DeleteFolderButton(
                                                  onPressed: () async {
                                                  final result =
                                                      await showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        const ConfirmDelete(),
                                                  );
                                                  if (result != null &&
                                                      result) {
                                                    setState(() {
                                                      filteredFolders
                                                          .remove(currFold);
                                                      folderBox
                                                          .delete(currFold);
                                                      List temp = noteBox.values
                                                          .toList();
                                                      for (int i = 0;
                                                          i < temp.length;
                                                          i++) {
                                                        if (temp[i].folder ==
                                                            currFold) {
                                                          Note tempNote =
                                                              temp[i];
                                                          tempNote.delete();
                                                        }
                                                      }
                                                      fillFolderList();
                                                      if (cf == currFold) {
                                                        folderStream.sink
                                                            .add('Notes');
                                                        Navigator.pop(context);
                                                      }
                                                    });
                                                  }
                                                }))));
                            },
                          ))
                        : Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Text('Create a folder',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: windowBodyDarkMode())),
                            ),
                          ),
                  ],
                ));
          });
        });
  }

  tempNoteDialog([Note? note]) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Color noteBarColor = Colors.yellow.shade50;
          Color noteBodyColor = Colors.yellow.shade50;
          Color newNoteBarColor = dymnomz;
          Color newNoteBodyColor = dymnomz;
          return StatefulBuilder(builder: (context, setState) {
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
                                  ReturnButton(
                                    onPressed: () {
                                      noteFunc(
                                          noteBarColor, noteBodyColor, note);
                                      setState(() => isEditing = false);
                                      fillNoteList();
                                      Navigator.pop(context);
                                    },
                                    note: note,
                                    color: newNoteBarColor,
                                  ),
                                  ChoseColorButton(
                                      onPressed: () async {
                                        final result = await showDialog(
                                            context: context,
                                            builder: (_) => (isEditing)
                                                ? ChoseWindowColor(
                                                    colorPart: 1,
                                                    currentColor:
                                                        note!.barColor)
                                                : ChoseWindowColor(
                                                    colorPart: 1,
                                                    currentColor: noteBarColor,
                                                  ));
                                        setState(() => newNoteBarColor =
                                            result ?? noteBarColor);
                                        if (result != null) {
                                          if (isEditing) {
                                            setState(() {
                                              note?.barColor = result;
                                              note?.title =
                                                  _titleController.text;
                                              note?.content =
                                                  _contentController.text;
                                              note?.save();
                                            });
                                          } else {
                                            setState(() {
                                              noteBarColor = result;
                                              newTitle = _titleController.text;
                                              newContent =
                                                  _contentController.text;
                                            });
                                          }
                                        }
                                      },
                                      darkModeType: 2,
                                      note: note,
                                      color: newNoteBarColor),
                                  ChoseColorButton(
                                      onPressed: () async {
                                        final result = await showDialog(
                                            context: context,
                                            builder: (_) => (isEditing)
                                                ? ChoseWindowColor(
                                                    colorPart: 2,
                                                    currentColor:
                                                        note!.bodyColor)
                                                : ChoseWindowColor(
                                                    colorPart: 2,
                                                    currentColor: noteBodyColor,
                                                  ));
                                        setState(() => newNoteBodyColor =
                                            result ?? noteBodyColor);
                                        if (result != null) {
                                          if (isEditing) {
                                            setState(() {
                                              note?.bodyColor = result;
                                              note?.title =
                                                  _titleController.text;
                                              note?.content =
                                                  _contentController.text;
                                              note?.save();
                                            });
                                          } else {
                                            setState(() {
                                              noteBodyColor = result;
                                              newTitle = _titleController.text;
                                              newContent =
                                                  _contentController.text;
                                            });
                                          }
                                        }
                                      },
                                      darkModeType: 2,
                                      note: note,
                                      color: newNoteBarColor)
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: MoveWindow(
                            child: Container(
                              //to be made a class
                              color:
                                  (isEditing) ? note?.barColor : noteBarColor,
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
                                  MinimizeWindowButton(
                                      colors: minMaxCloseDarkModeNote(
                                          note, newNoteBarColor)),
                                  MaximizeWindowButton(
                                      colors: minMaxCloseDarkModeNote(
                                          note, newNoteBarColor),
                                      onPressed: changeGridValues),
                                  CloseWindowButton(
                                      colors: minMaxCloseDarkModeNote(
                                          note, newNoteBarColor),
                                      onPressed: () => exitFunc(
                                          noteBarColor, noteBodyColor, note)),
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
                          cursorColor: noteBodyDarkMode(note, newNoteBodyColor),
                          controller: _titleController = TextEditingController(
                              text: note?.title ?? newTitle),
                          style: TextStyle(
                              color: noteBodyDarkMode(note, newNoteBodyColor),
                              fontSize: 20),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Title',
                              hintStyle: TextStyle(
                                  color:
                                      noteBodyDarkMode(note, newNoteBodyColor),
                                  fontSize: 20)),
                        ),
                        TextField(
                          cursorColor: noteBodyDarkMode(note, newNoteBodyColor),
                          controller: _contentController =
                              TextEditingController(
                                  text: note?.content ?? newContent),
                          style: TextStyle(
                              color: noteBodyDarkMode(note, newNoteBodyColor),
                              fontSize: 15),
                          maxLines: null,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type something here',
                              hintStyle: TextStyle(
                                  color:
                                      noteBodyDarkMode(note, newNoteBodyColor),
                                  fontSize: 15)),
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            );
          });
        });
  }
}
