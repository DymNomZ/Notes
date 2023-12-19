import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'note.dart';
import 'notedata.dart';
import 'package:provider/provider.dart';

class editNotePage extends StatefulWidget {
  Note note;
  bool isNew;
  editNotePage({super.key, required this.note, required this.isNew});

  @override
  State<editNotePage> createState() => _editNotePageState();
}

class _editNotePageState extends State<editNotePage> {

  QuillController _controller = QuillController.basic();
  TextEditingController _noteTitle = TextEditingController();

  @override
  void initState(){
    super.initState();
    loadExistingNote();
    _noteTitle.addListener(() { });
  }

  @override
  void dispose() {
    _noteTitle.dispose();
    super.dispose();
  }

  void loadExistingNote(){
    final doc = Document()..insert(0, widget.note.text);
    setState(() {
      _controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
    });
  }

  void addNote(){
    Provider.of<NoteData>(context, listen: false).addNote(
      Note(
        id: Provider.of<NoteData>(context, listen: false).getNoteList().length, text: _controller.document.toPlainText(),
        title: _noteTitle.text
      )
      );
  }

  void updateNote(){
    Provider.of<NoteData>(context, listen: false).updateNote(widget.note, _controller.document.toPlainText());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: (widget.isNew) 
        ? TextField(
          controller: _noteTitle,
          decoration: new InputDecoration.collapsed(
            hintText: 'Note title',
          ),
        )
        : TextField(
          controller: _noteTitle = TextEditingController(text: widget.note.title),
        ),
        leading: IconButton(
          onPressed: (){
            if(widget.isNew && !_controller.document.isEmpty()){
              addNote();
            }
            else{
              updateNote();
            }
            Navigator.pop(context);
          }, 
          icon: const Icon(
            Icons.arrow_back
            )
          ),
      ),
      body: Column(
        children: [
          Row(
            children: [
                QuillSimpleToolbar(
                  configurations: QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    showAlignmentButtons: false,
                    showBackgroundColorButton: false,
                    showBoldButton: false,
                    showCenterAlignment: false,
                    showHeaderStyle: false,
                    showClearFormat: false,
                    showCodeBlock: false,
                    showColorButton: false,
                    showDirection: false,
                    showDividers: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showIndent: false,
                    showInlineCode: false,
                    showItalicButton: false,
                    showJustifyAlignment: false,
                    showLeftAlignment: false,
                    showLink: false,
                    showListBullets: false,
                    showListCheck: false,
                    showListNumbers: false,
                    showQuote: false,
                    showRightAlignment: false,
                    showSearchButton: false,
                    showSmallButton: false,
                    showStrikeThrough: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showUnderLineButton: false,
                    showUndo: true,
                    showRedo: true,
                    )
              )
            ],
          ),
          Expanded(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  child: QuillEditor(
                    configurations: QuillEditorConfigurations(
                      controller: _controller,
                      readOnly: false
                      ),
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                  ),
                )
              )
        ],
      ),
    );
  }
}