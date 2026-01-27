import 'dart:typed_data';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:intl/intl.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/custom_image_options_menu.dart';
import 'package:notesclonedym/classes/hover_image_builder.dart';
import 'package:notesclonedym/classes/window.dart';
import 'package:notesclonedym/variables.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'buttons/buttons.dart';
import 'functions/functions.dart';
import 'classes/classes.dart';
import 'classes/note.dart';
import 'dart:async';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:flutter_quill_extensions/src/common/utils/element_utils/element_utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  Timer? _autosaveTimer;
  Timer? _debounce;

  Note? noteToSave;
  Note? _originalNoteForComparison;

  Color noteBarColor = Colors.yellow.shade50;
  Color noteBodyColor = Colors.yellow.shade50;

  List filteredNotes = [];
  quill.QuillController _titleController = quill.QuillController.basic();
  StreamSubscription? _titleSubscription;
  quill.QuillController _quillController = quill.QuillController.basic();
  StreamSubscription? _quillSubscription;

  bool isEditing = false;
  Window userWindow = Window(barColor: Colors.amber, bodyColor: Colors.white);
  String newTitle = '';
  String newContent = '';
  List filteredFolders = [];
  final TextEditingController _folderName = TextEditingController();
  String cf = 'Notes';
  bool isMoving = false;

  fillNoteList() {
    List<dynamic> notesForFolder =
        noteBox.values.where((note) => note.folder == cf).toList();

    bool needsMigration = notesForFolder.any((note) =>
        note.orderIndex == null ||
        note.orderIndex == -1);

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
    // Start listening to app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    _startAutosaveTimer();
  }

  @override
  void dispose() {
    // Stop listening to app lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    _titleSubscription?.cancel();
    _quillSubscription?.cancel();
    _autosaveTimer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // This method is called whenever the app's state changes.
    print('App lifecycle state changed to: $state');
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Save data when the app is about to be backgrounded or closed.
      print('App is pausing or detaching, triggering final save...');
      saveAllData();
    }
  }

  void _startAutosaveTimer() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) {
        saveAllData();
      },
    );
  }

  void _onNoteChanged() {

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 800), () {
      print('Debounce triggered!');
      saveAllData();
    });
  }

  Future<void> saveAllData() async {

  if (!isEditing || noteToSave == null || _originalNoteForComparison == null) {
      return;
    }

    print('Auto-saving data at ${DateTime.now()}...');

    final String titleJson = jsonEncode(_titleController.document.toDelta().toJson());
    final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    final Color currentBarColor = noteToSave!.barColor;
    final Color currentBodyColor = noteToSave!.bodyColor;

    bool hasChanges = _originalNoteForComparison!.title != titleJson ||
                        _originalNoteForComparison!.richContentJson != contentJson ||
                        _originalNoteForComparison!.barColor.value != currentBarColor.value ||
                        _originalNoteForComparison!.bodyColor.value != currentBodyColor.value;

    if (!hasChanges) {
      print('Auto-save skipped: No changes detected.');
      return;
    }
    
    noteToSave!.title = titleJson;
    noteToSave!.richContentJson = contentJson;
    noteToSave!.modifiedTime = DateTime.now();
    
    await noteToSave!.save(); 

    _originalNoteForComparison = noteToSave!.copy;
    
    print('Save complete for note: "${quillJsonToPlainText(noteToSave!.title)}"');

    fillNoteList();
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = noteBox.values
          .where((note) {
            final titlePlain = quillJsonToPlainText(note.title).toLowerCase();
            final contentPlain = quillJsonToPlainText(note.richContentJson).toLowerCase(); 
            final query = searchText.toLowerCase();

            return (titlePlain.contains(query) || contentPlain.contains(query)) && 
                  note.folder == cf;
          })
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
          ChoseColor(colorPart: ColorSelectionType.body.index, currentColor: userWindow.bodyColor),
    );
    if (result != null) {
      setState(() {
        userWindow.bodyColor = result;
        userWindow.save();
        checkWindowBox();
      });
    }
  }

  void onReorderFunc(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final Note item = filteredNotes.removeAt(oldIndex);
      filteredNotes.insert(newIndex, item);
      _updateNoteOrderInHive();
    });
  }

  Future<void> _onImageButtonPressed() async {
  final ImagePicker picker = ImagePicker();
  
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image == null) return;

  String imagesDirPath = "$basePath/Documents/StoredNotes!/Images";
  
  await Directory(imagesDirPath).create(recursive: true);

  File originalFile = File(image.path);
  String extension = p.extension(image.path).toLowerCase();
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String newFileName = "img_$timestamp$extension";
  String newPath = "$imagesDirPath/$newFileName";

  int fileSize = await originalFile.length();
  bool needsCompression = fileSize > 2 * 1024 * 1024; // 2MB

  if (needsCompression && (extension == '.jpg' || extension == '.jpeg' || extension == '.png')) {
    final cmd = img.Command()
      ..decodeImage(originalFile.readAsBytesSync())
      ..copyResize(width: 1920)
      ..encodeJpg(quality: 85)
      ..writeToFile(newPath);
    
    await cmd.executeThread();
  } else {
    await originalFile.copy(newPath);
  }

  final index = _quillController.selection.baseOffset;
  final length = _quillController.selection.extentOffset - index;
  
  _quillController.replaceText(index, length, quill.BlockEmbed.image(newPath), null);
  _quillController.moveCursorToPosition(index + 1);
}

  @override
  Widget build(BuildContext context) {

    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 700.0;
    final bool isGridView = screenWidth > breakpoint;
    final int currentAxisCount = isGridView ? screenWidth > 1100 ? screenWidth > 1600 ? 4 : 3 : 2 : 1;
    final double currentAspectRatio = isGridView ? 2.8 : 2.5;

    return Scaffold(
      backgroundColor: userWindow.bodyColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WindowTitle(
              dialog: tempNoteDialog,
              bodydialog: choseBodyColor,
              folderFunc: folderList,
              settingsFunc: settingsDialog),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
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
                child: !isGridView
                  ? ReorderableListView.builder(
                    itemCount: filteredNotes.length,
                    buildDefaultDragHandles: false,
                    onReorder: onReorderFunc,
                    itemBuilder: (context, index) {
                      Note currentNote = filteredNotes[index];
                      return buildNoteCard(currentNote, index, false);
                    },
                  )
                  : ReorderableGridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: currentAxisCount, childAspectRatio: currentAspectRatio),
                  itemCount: filteredNotes.length,
                  onReorder: onReorderFunc,
                  itemBuilder: (context, index) {
                    Note currentNote = filteredNotes[index];
                    return buildNoteCard(currentNote, index, true);
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

  Widget buildNoteCard(Note currentNote, int index, bool isGridView) {
  return Card(
      key: ValueKey(currentNote),
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      color: currentNote.barColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    setState(() => isEditing = true);
                    tempNoteDialog(currentNote);
                  },
                  title: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: '${quillJsonToPlainText(currentNote.title)} \n',
                        style: TextStyle(
                            color: cardDarkMode(currentNote),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.5),
                        children: [
                          TextSpan(
                            text: quillJsonToPlainText(currentNote.richContentJson),
                            style: TextStyle(
                                color: cardDarkMode(currentNote),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoveButton(
                    onPressed: () {
                      setState(() {
                        isMoving = true;
                        folderList(currentNote);
                      });
                    },
                    note: currentNote
                  ),
                  if (!isGridView) ...[
                    const SizedBox(height: 8),
                    ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Icon(
                          Icons.back_hand,
                          size: 20,
                          color: cardDarkMode(currentNote)
                        )
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  DeleteNoteButton(
                    onPressed: () async {
                      if (askBeforeDeleting) {
                        final result = await showDialog(
                          context: context,
                          builder: (_) =>
                              const ConfirmDelete(),
                        );
                        if (result != null && result) {
                          setState(() {
                            filteredNotes.remove(currentNote);
                            currentNote.delete();
                            noteToSave = null;
                          });
                        }
                      } else {
                        setState(() {
                          filteredNotes.remove(currentNote);
                          currentNote.delete();
                          noteToSave = null;
                        });
                      }
                    },
                    note: currentNote,
                  ),
                ],
              ),
            )
          ],
        ),
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

    final String titleText = _titleController.document.toPlainText().trim();
    final String contentText = _quillController.document.toPlainText().trim();

    if (titleText.isNotEmpty || contentText.isNotEmpty) {

      String titleJson = jsonEncode(_titleController.document.toDelta().toJson());
      String contentJson = jsonEncode(_quillController.document.toDelta().toJson());

      if (isEditing) {
        if (note?.title != titleJson || note?.richContentJson != contentJson) {
          setState(() {
            note?.title = titleJson;
            note?.richContentJson = contentJson;
            note?.modifiedTime = DateTime.now();
            note?.save();
            isEditing = false;
            fillNoteList();
          });
        }
        setState(() => isEditing = false);
        fillNoteList();
        noteToSave = note;
      } else {
        setState(() {
          List<Note> notesInFolder = noteBox.values
          .where((note) => note.folder == cf)
          .toList()
          .cast<Note>();

          for (var existingNote in notesInFolder) {
            existingNote.orderIndex++;
            existingNote.save();
          }

          final Note newNote = Note(
              title: titleJson,
              richContentJson: contentJson,
              modifiedTime: DateTime.now(),
              barColor: noteBarColor,
              bodyColor: noteBodyColor,
              creationTime: DateTime.now(),
              folder: cf,
              orderIndex: 0
          );

          noteBox.add(newNote);

          _titleController = quill.QuillController.basic();
          _quillController = quill.QuillController.basic();
          
          newTitle = '';
          newContent = '';
          isEditing = false;
          fillNoteList();
          noteToSave = newNote;
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
                                    // ReturnButton2(onPressed: () {
                                    //   if (isMoving) {
                                    //     setState(() => isMoving = false);
                                    //   }
                                    //   Navigator.pop(context);
                                    // }),
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
                                                              _folderName.clear();
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
                          child: LayoutBuilder(
                          builder: (context, constraints) {

                            final double dialogWidth = constraints.maxWidth;
                            const double breakpoint = 700.0;

                            final bool isGridView = dialogWidth > breakpoint;
                            final int currentAxisCount = isGridView ? dialogWidth > 1100 ? dialogWidth > 1600 ? 4 : 3 : 2 : 1;
                            final double currentAspectRatio = isGridView ? 2.8 : 2.5;
                            
                            if (isGridView) {
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: currentAxisCount,
                                  childAspectRatio: 4,
                                ),
                                itemCount: filteredFolders.length,
                                itemBuilder: (context, index) {
                                  String currFold = filteredFolders[index];
                                  return buildFolderCard(currFold, note); 
                                },
                              );
                            } else {
                              return ListView.builder(
                                itemCount: filteredFolders.length,
                                itemBuilder: (context, index) {
                                  String currFold = filteredFolders[index];
                                  return buildFolderCard(currFold, note);
                                },
                              );
                            }
                          },
                        ),
                      )
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

  Widget buildFolderCard(String currFold, Note? note) {
    return Card(
      key: ValueKey(currFold),
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
                      filteredFolders.remove(currFold);
                      folderBox.delete(currFold);
                      List temp = noteBox.values.toList();
                      for (int i = 0; i < temp.length; i++) {
                        if (temp[i].folder == currFold) {
                          Note tempNote = temp[i];
                          tempNote.delete();
                        }
                      }
                      fillFolderList();
                      if (cf == currFold) {
                        folderStream.sink.add('Notes');
                        Navigator.pop(context);
                      }
                    });
                  }
    }))));
  }

  Future<void> _onTextColorButtonPressed(quill.QuillController controller) async {
  final attributes = controller.getSelectionStyle().attributes;
  final colorAttribute = attributes[quill.Attribute.color.key];
  
  Color currentColor = Colors.black;
  if (colorAttribute != null) {
    currentColor = hexToColor(colorAttribute.value);
  }

  final Color? result = await showDialog(
    context: context,
    builder: (_) => ChoseColor(
      colorPart: ColorSelectionType.font.index,
      currentColor: currentColor,
    ),
  );

  if (result != null) {
    final String hex = colorToHex(result);
    controller.formatSelection(quill.ColorAttribute(hex));
  }
}

Future<String?> _processAndSaveImage(Uint8List imageBytes, String extension) async {
    String imagesDirPath = "$basePath/Documents/StoredNotes!/Images";
    await Directory(imagesDirPath).create(recursive: true);

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    int fileSize = imageBytes.lengthInBytes;
    bool needsCompression = fileSize > 2 * 1024 * 1024; // 2MB

    String newPath = "$imagesDirPath/img_$timestamp$extension";
    
    if (needsCompression) {
      print("Image is large ($fileSize bytes). Compressing...");
      // Decode image (CPU intensive)
      img.Image? decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        if (decodedImage.width > 1920) {
            decodedImage = img.copyResize(decodedImage, width: 1920);
        }
        
        newPath = "$imagesDirPath/img_$timestamp.jpg";
        File(newPath).writeAsBytesSync(img.encodeJpg(decodedImage, quality: 85));
        return newPath;
      }
    }

    File(newPath).writeAsBytesSync(imageBytes);
    return newPath;
  }

  tempNoteDialog([Note? note]) {

    final ValueNotifier<bool> isProcessingImageNotifier = ValueNotifier(false);
    noteBarColor = Colors.yellow.shade50;
    noteBodyColor = Colors.yellow.shade50;
    Color newNoteBarColor = dymnomz;
    Color newNoteBodyColor = dymnomz;

    Color contrastColor = noteBodyDarkMode(note, newNoteBodyColor);

    setState(() {
      isEditing = (note != null);
    });

    noteToSave = note;
    _originalNoteForComparison = note?.copy;

    final QuillClipboardConfig clipboardConfig = quill.QuillClipboardConfig(
      enableExternalRichPaste: true,
      onImagePaste: (imageBytes) async {
        isProcessingImageNotifier.value = true; // Turn spinner ON
        
        String? path = await _processAndSaveImage(imageBytes, ".png");
        
        isProcessingImageNotifier.value = false; // Turn spinner OFF
        return path;
      },
    );

    if (isEditing) {
      try {
        final doc = quill.Document.fromJson(jsonDecode(note!.title));
        _titleController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } on FormatException {
        final doc = quill.Document()..insert(0, note!.title);
        _titleController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
        note.title = jsonEncode(doc.toDelta().toJson());
        note.save(); 
      }
      try {
        final doc = quill.Document.fromJson(jsonDecode(note!.richContentJson));
        _quillController = quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
            config: quill.QuillControllerConfig(clipboardConfig: clipboardConfig),
        );
      } on FormatException {
        print('FormatException caught! Migrating old note content...');
        final doc = quill.Document()..insert(0, note.richContentJson);
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          config: quill.QuillControllerConfig(clipboardConfig: clipboardConfig),
        );
        
        // Immediately save this converted format back to the note
        note.richContentJson = jsonEncode(doc.toDelta().toJson());
        note.save(); 
      }
    } else {
      _titleController = quill.QuillController.basic();
      _quillController = quill.QuillController.basic(
        config: quill.QuillControllerConfig(clipboardConfig: clipboardConfig),
      );
      noteBarColor = Colors.yellow.shade50;
      noteBodyColor = Colors.yellow.shade50;
    }

    _titleSubscription?.cancel();
    _titleSubscription = _titleController.document.changes.listen((_) {
      _onNoteChanged();
    });
    _quillSubscription?.cancel(); 
    _quillSubscription = _quillController.document.changes.listen((_) {
      _onNoteChanged();
    });

    final FocusNode titleFocus = FocusNode();
    final FocusNode bodyFocus = FocusNode();

    final ValueNotifier<QuillController> activeControllerNotifier = ValueNotifier(_quillController);

    void updateActiveController() {
      if (titleFocus.hasFocus) {
        activeControllerNotifier.value = _titleController;
      } else if (bodyFocus.hasFocus) {
        activeControllerNotifier.value = _quillController;
      }
    }

    QuillSimpleToolbarConfig testconig = QuillSimpleToolbarConfig();

    titleFocus.addListener(updateActiveController);
    bodyFocus.addListener(updateActiveController);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {

            if(isEditing == false && _quillController.document.isEmpty()){
              _titleController = quill.QuillController.basic();
              _quillController = quill.QuillController.basic(
                config: quill.QuillControllerConfig(clipboardConfig: clipboardConfig),
              );
            }

            return Stack(
              children: [
                  Scaffold(
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
                                          if (isProcessingImageNotifier.value) return;
                                          _titleSubscription?.cancel();
                                          _quillSubscription?.cancel();
                                          _debounce?.cancel();
                                          noteFunc(noteBarColor, noteBodyColor, note);
                                          setState((){
                                            isEditing = false;
                                            _originalNoteForComparison = null;
                                        });
                                          fillNoteList();
                                          titleFocus.dispose(); 
                                          bodyFocus.dispose();
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
                                                    ? ChoseColor(
                                                        colorPart: ColorSelectionType.bar.index,
                                                        currentColor:
                                                            note!.barColor)
                                                    : ChoseColor(
                                                        colorPart: ColorSelectionType.bar.index,
                                                        currentColor: noteBarColor,
                                                      ));
                                            setState(() => newNoteBarColor =
                                                result ?? noteBarColor);
                                            if (result != null) {
                                              final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());
                                              final String titleJson = jsonEncode(_titleController.document.toDelta().toJson());
                                              if (isEditing) {
                                                setState(() {
                                                  note?.barColor = result;
                                                  note?.title = titleJson;
                                                  note?.richContentJson = contentJson;
                                                  note?.save();
                                                  noteToSave?.barColor = result;
                                                });
                                              } else {
                                                setState(() {
                                                  noteBarColor = result;
                                                  newTitle = titleJson;
                                                  newContent = contentJson;
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
                                                    ? ChoseColor(
                                                        colorPart: ColorSelectionType.body.index,
                                                        currentColor:
                                                            note!.bodyColor)
                                                    : ChoseColor(
                                                        colorPart: ColorSelectionType.body.index,
                                                        currentColor: noteBodyColor,
                                                      ));
                                            setState(() => newNoteBodyColor =
                                                result ?? noteBodyColor);
                                            if (result != null) {
                                              final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());
                                              final String titleJson = jsonEncode(_titleController.document.toDelta().toJson());
                                              if (isEditing) {
                                                setState(() {
                                                  note?.bodyColor = result;
                                                  note?.title = titleJson;
                                                  note?.richContentJson = contentJson;
                                                  note?.save();
                                                  noteToSave?.bodyColor = result;
                                                });
                                              } else {
                                                setState(() {
                                                  noteBodyColor = result;
                                                  newTitle = titleJson;
                                                  newContent = contentJson;
                                                });
                                              }
                                            }
                                          },
                                          darkModeType: 2,
                                          note: note,
                                          color: newNoteBarColor),
                                      ValueListenableBuilder<QuillController>(
                                        valueListenable: activeControllerNotifier,
                                        builder: (context, activeController, child) {
                                          return quill.QuillToolbarColorButton(
                                            controller: activeController, 
                                            isBackground: false,
                                            options: quill.QuillToolbarColorButtonOptions(
                                              iconTheme: quill.QuillIconTheme(
                                                iconButtonUnselectedData: quill.IconButtonData(
                                                  color: contrastColor,
                                                ),
                                              ),
                                              iconData: Icons.format_color_text_rounded,
                                              customOnPressedCallback: (controller, isBackground) {
                                                return _onTextColorButtonPressed(activeController);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: Attribute.ul,
                                        options: testconig.buttonOptions.listBullets,
                                        controller: _quillController,
                                        baseOptions: testconig.buttonOptions.base,
                                      ),
                                      IconButton(
                                        onPressed: _onImageButtonPressed,
                                        icon: Icon(
                                          Icons.image, 
                                          size: 20, 
                                          color: noteBarDarkMode(note, newNoteBarColor), 
                                        ),
                                      ),
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
                                              note, newNoteBarColor)),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: contrastColor,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold
                          ),
                          child: quill.QuillEditor(
                            controller: _titleController,
                            focusNode: titleFocus,
                            scrollController: ScrollController(),
                            config: quill.QuillEditorConfig(
                              autoFocus: false,
                              scrollable: false,
                              expands: false,
                              enableInteractiveSelection: true, 
                              paintCursorAboveText: true,
                              placeholder: "Enter a title",
                              showCursor: true,
                              scrollBottomInset: 0,
                              textSelectionThemeData: TextSelectionThemeData(
                                selectionColor: selectionColor,
                                selectionHandleColor: contrastColor.withAlpha(67),
                                cursorColor: contrastColor,
                              ),
                              onKeyPressed: (event, node) {
                                if (event.logicalKey == LogicalKeyboardKey.enter) {
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: contrastColor,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            letterSpacing: 0.5,
                            height: 1.5
                          ),
                          child: quill.QuillEditor(
                            controller: _quillController,
                            focusNode: bodyFocus,
                            scrollController: ScrollController(),
                            config: quill.QuillEditorConfig(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 15),
                              enableInteractiveSelection: true, 
                              paintCursorAboveText: true,
                              placeholder: "Type something here",
                              showCursor: true,
                              scrollBottomInset: 0,
                              autoFocus: true,
                              textSelectionThemeData: TextSelectionThemeData(
                                selectionColor: selectionColor,
                                selectionHandleColor: contrastColor.withAlpha(67),
                                cursorColor: contrastColor,
                              ),
                              embedBuilders: [
                                HoverableImageEmbedBuilder(
                                  config: QuillEditorImageEmbedConfig(
                                    onImageClicked: (imagePath) {
                                      final imageProvider = FileImage(File(imagePath));
                                      const imageSize = ElementSize(null, null);
                          
                                      showDialog(
                                        context: context,
                                        builder: (context) => CustomImageOptionsMenu(
                                          controller: _quillController,
                                          config: const QuillEditorImageEmbedConfig(),
                                          imageSource: imagePath,
                                          imageSize: imageSize,
                                          readOnly: false,
                                          imageProvider: imageProvider,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isProcessingImageNotifier,
                  builder: (context, isProcessing, child) {
                    if (!isProcessing) return const SizedBox.shrink();
                    return Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ]
            );
          });
        });
  }
}
