import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:notesclonedym/classes/boxes.dart';
import 'package:notesclonedym/classes/custom_image_options_menu.dart';
import 'package:notesclonedym/classes/hover_image_builder.dart';
import 'package:notesclonedym/classes/note.dart';
import 'package:notesclonedym/functions/functions.dart';
import 'package:notesclonedym/variables.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_quill_extensions/src/common/utils/element_utils/element_utils.dart';
import 'buttons/buttons.dart';
import 'classes/classes.dart';

class NoteWindow extends StatefulWidget {
  final int noteKey; // The Hive key of the note to display
  
  const NoteWindow({Key? key, required this.noteKey}) : super(key: key);

  @override
  State<NoteWindow> createState() => _NoteWindowState();
}

class _NoteWindowState extends State<NoteWindow> {
  Note? note;
  Note? _originalNoteForComparison;
  
  quill.QuillController _titleController = quill.QuillController.basic();
  quill.QuillController _quillController = quill.QuillController.basic();
  
  Color noteBarColor = Colors.yellow.shade50;
  Color noteBodyColor = Colors.yellow.shade50;
  
  final ValueNotifier<bool> isProcessingImageNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() {
    // Load note from Hive using the key
    final loadedNote = noteBox.get(widget.noteKey) as Note?;
    
    if (loadedNote != null) {
      setState(() {
        note = loadedNote;
        _originalNoteForComparison = loadedNote.copy;
        noteBarColor = loadedNote.barColor;
        noteBodyColor = loadedNote.bodyColor;
        _initializeControllers();
      });
    }
  }

  void _initializeControllers() {
    if (note == null) return;

    final quill.QuillClipboardConfig clipboardConfig = quill.QuillClipboardConfig(
      enableExternalRichPaste: true,
      onImagePaste: (imageBytes) async {
        isProcessingImageNotifier.value = true;
        String? path = await _processAndSaveImage(imageBytes, ".png");
        isProcessingImageNotifier.value = false;
        return path;
      },
    );

    // Initialize title controller
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
    }

    // Initialize content controller
    try {
      final doc = quill.Document.fromJson(jsonDecode(note!.richContentJson));
      _quillController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        config: quill.QuillControllerConfig(clipboardConfig: clipboardConfig),
      );
    } on FormatException {
      final doc = quill.Document()..insert(0, note!.richContentJson);
      _quillController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        config: quill.QuillControllerConfig(clipboardConfig: clipboardConfig),
      );
    }
  }

  Future<String?> _processAndSaveImage(Uint8List imageBytes, String extension) async {
    String imagesDirPath = "$basePath/Documents/StoredNotes!/Images";
    await Directory(imagesDirPath).create(recursive: true);

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    int fileSize = imageBytes.lengthInBytes;
    bool needsCompression = fileSize > 2 * 1024 * 1024;
    String newPath = "$imagesDirPath/img_$timestamp$extension";
    
    if (needsCompression) {
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
    bool needsCompression = fileSize > 2 * 1024 * 1024;

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

  void _saveNote() {
    if (note == null) return;

    final String titleJson = jsonEncode(_titleController.document.toDelta().toJson());
    final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    note!.title = titleJson;
    note!.richContentJson = contentJson;
    note!.modifiedTime = DateTime.now();
    note!.barColor = noteBarColor;
    note!.bodyColor = noteBodyColor;
    note!.save();

    _originalNoteForComparison = note!.copy;
  }

  @override
  Widget build(BuildContext context) {
    if (note == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Color contrastColor = noteBodyDarkMode(note, noteBodyColor);
    final FocusNode titleFocus = FocusNode();
    final FocusNode bodyFocus = FocusNode();
    final ValueNotifier<quill.QuillController> activeControllerNotifier = 
        ValueNotifier(_quillController);

    void updateActiveController() {
      if (titleFocus.hasFocus) {
        activeControllerNotifier.value = _titleController;
      } else if (bodyFocus.hasFocus) {
        activeControllerNotifier.value = _quillController;
      }
    }

    titleFocus.addListener(updateActiveController);
    bodyFocus.addListener(updateActiveController);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: noteBodyColor,
          body: Column(
            children: [
              WindowTitleBarBox(
                child: Row(
                  children: [
                    Container(
                      color: noteBarColor,
                      child: Row(
                        children: [
                          // Close button - saves and closes window
                          IconButton(
                            onPressed: () {
                              _saveNote();
                              appWindow.close();
                            },
                            icon: Icon(Icons.close, color: noteBarDarkMode(note, noteBarColor)),
                          ),
                          // Color buttons
                          ChoseColorButton(
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (_) => ChoseColor(
                                  colorPart: ColorSelectionType.bar.index,
                                  currentColor: note!.barColor,
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  noteBarColor = result;
                                  note!.barColor = result;
                                });
                              }
                            },
                            darkModeType: 2,
                            note: note,
                            color: noteBarColor,
                          ),
                          ChoseColorButton(
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (_) => ChoseColor(
                                  colorPart: ColorSelectionType.body.index,
                                  currentColor: note!.bodyColor,
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  noteBodyColor = result;
                                  note!.bodyColor = result;
                                });
                              }
                            },
                            darkModeType: 2,
                            note: note,
                            color: noteBarColor,
                          ),
                          ValueListenableBuilder<quill.QuillController>(
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
                            attribute: quill.Attribute.ul,
                            options: quill.QuillToolbarToggleStyleButtonOptions(
                              iconTheme: quill.QuillIconTheme(
                                iconButtonUnselectedData: quill.IconButtonData(
                                  color: contrastColor,
                                ),
                              ),
                            ),
                            controller: _quillController,
                          ),
                          IconButton(
                            onPressed: _onImageButtonPressed,
                            icon: Icon(
                              Icons.image,
                              size: 20,
                              color: noteBarDarkMode(note, noteBarColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: MoveWindow(
                        child: Container(color: noteBarColor),
                      ),
                    ),
                    Container(
                      color: noteBarColor,
                      child: Row(
                        children: [
                          MinimizeWindowButton(
                            colors: minMaxCloseDarkModeNote(note, noteBarColor),
                          ),
                          MaximizeWindowButton(
                            colors: minMaxCloseDarkModeNote(note, noteBarColor),
                          ),
                          CloseWindowButton(
                            colors: minMaxCloseDarkModeNote(note, noteBarColor),
                            onPressed: () {
                              _saveNote();
                              appWindow.close();
                            },
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
                    fontWeight: FontWeight.bold,
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
                    height: 1.5,
                  ),
                  child: quill.QuillEditor(
                    controller: _quillController,
                    focusNode: bodyFocus,
                    scrollController: ScrollController(),
                    config: quill.QuillEditorConfig(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      enableInteractiveSelection: true,
                      paintCursorAboveText: true,
                      placeholder: "Type something here",
                      showCursor: true,
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
              ),
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
      ],
    );
  }

  @override
  void dispose() {
    _saveNote();
    super.dispose();
  }
}