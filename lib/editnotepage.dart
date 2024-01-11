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
        id: UniqueKey().hashCode, text: _controller.document.toPlainText(),
        title: _noteTitle.text, color: widget.note.color
      )
      );
  }

  void updateNote(){
    Provider.of<NoteData>(context, listen: false).updateNote(
      widget.note, _controller.document.toPlainText(),
      _noteTitle.text, widget.note.color
    );
  }

  void selectColors(){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 200.0,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Colors.white,
              ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Select Colors', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.red.shade400;
                          });
                        },
                        child: Container(
                          color: Colors.red.shade400,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.orange.shade400;
                          });
                        },
                        child: Container(
                          color: Colors.orange.shade400,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.yellow.shade400;
                          });
                        },
                        child: Container(
                          color: Colors.yellow.shade400,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.green.shade400;
                          });
                        },
                        child: Container(
                          color: Colors.green.shade400,
                          height: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.blue.shade400;
                          });
                        },
                        child: Container(
                          color: Colors.blue.shade400,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.purple.shade300;
                          });
                        },
                        child: Container(
                          color: Colors.purple.shade300,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.pink.shade200;
                          });
                        },
                        child: Container(
                          color: Colors.pink.shade200,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.brown.shade300;
                          });
                        },
                        child: Container(
                          color: Colors.brown.shade300,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.yellow.shade50;
                          });
                        },
                        child: Container(
                          color: Colors.yellow.shade50,
                          height: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.note.color = Colors.grey.shade400;
                          });
                        },
                        child: Container(
                          color: Colors.grey.shade400,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.note.color,
        title: (widget.isNew)
        ? TextField(
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          controller: _noteTitle,
          decoration: new InputDecoration.collapsed(
            hintText: 'Note title',
          ),
          onChanged: (value) => {
             widget.note.title = _noteTitle.text
         },
        )
        : TextField(
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          controller: _noteTitle = TextEditingController(text: widget.note.title),
          decoration: const InputDecoration.collapsed(
            hintText: '',
          ),
          onChanged: (value) => {
             widget.note.title = _noteTitle.text
          },
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
          actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
            iconSize: 30,
            onPressed: (){
              selectColors();
            },
            icon: const Icon(
              Icons.palette
              )
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: QuillSimpleToolbar(
                      configurations: QuillSimpleToolbarConfigurations(
                        toolbarIconAlignment: WrapAlignment.start,
                        controller: _controller,
                        showAlignmentButtons: false,
                        showBackgroundColorButton: false,
                        showBoldButton: true,
                        showCenterAlignment: false,
                        showHeaderStyle: false,
                        showClearFormat: false,
                        showCodeBlock: false,
                        showColorButton: false,
                        showDirection: false,
                        showDividers: false,
                        showFontFamily: false,
                        showFontSize: true,
                        showIndent: false,
                        showInlineCode: false,
                        showItalicButton: true,
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
                        showSubscript: true,
                        showSuperscript: true,
                        showUnderLineButton: false,
                        showUndo: true,
                        showRedo: true,
                        )
                                  ),
                  ),
                ),
            ],
          ),
          Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(25),
                  child: QuillEditor(
                    configurations: QuillEditorConfigurations(
                      controller: _controller,
                      readOnly: false,
                      placeholder: 'Type here...'
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