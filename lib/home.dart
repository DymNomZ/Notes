import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notedata.dart';
import 'note.dart';
import 'editnotepage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState(){
    super.initState();
    Provider.of<NoteData>(context, listen: false).initializeNotes();
  }

  void createNewNote(){
    Note newNote = Note(id: Provider.of<NoteData>(context, listen: false).getNoteList().length, text: '');
    goToNotePage(newNote, true);
  }

  void goToNotePage(Note note, bool isNew){
    Navigator.push(context, MaterialPageRoute(builder: (context) => editNotePage(note: note, isNew: isNew)));
  }

  void deleteNote(Note note){
    Provider.of<NoteData>(context, listen: false).getNoteList().remove(note);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(
      builder: (context, value, child) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notes', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => createNewNote(),
          icon: const Icon(
            Icons.add
          )
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
            onPressed: (){
              print('lol');
            },
            icon: const Icon(
              Icons.more_horiz
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
            onPressed: (){
              print('lol');
            },
            icon: const Icon(
              Icons.close
              )
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
           (value.getNoteList().isEmpty) 
           ? Padding(
             padding: const EdgeInsets.all(30.0),
             child: Center(
               child: Text('Start writting!', 
               style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade500)
               ),
             ),
           )
           : CupertinoListSection.insetGrouped(
            children: List.generate(
              value.getNoteList().length, 
              (index) => CupertinoListTile(
                title: Text(value.getNoteList()[index].title!),
                onTap: () => goToNotePage(value.getNoteList()[index], false),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      deleteNote(value.getNoteList()[index]); 
                    });
                  },
                  icon: const Icon(Icons.delete_forever)
                ),
              )),
           )
        ],
      ),
    )
    );
  }
}