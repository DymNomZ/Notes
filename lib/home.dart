import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notedata.dart';
import 'note.dart';
import 'editnotepage.dart';
import 'package:url_launcher/url_launcher.dart';

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
    Note newNote = Note(id: Provider.of<NoteData>(context, listen: false).getNoteList().length, text: '', color: Colors.yellow.shade50);
    goToNotePage(newNote, true);
  }

  void goToNotePage(Note note, bool isNew){
    Navigator.push(context, MaterialPageRoute(builder: (context) => editNotePage(note: note, isNew: isNew)));
  }

  void deleteNote(Note note){
    Provider.of<NoteData>(context, listen: false).deleteNote(note);
  }

  _launchURL() async {
   final Uri url = Uri.parse('https://github.com/DymNomZ');
   if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
    }
}

  void showInfo(){
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
                  child: Text('☘ App Info ☘', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                  child: Text('Just a simple windows sticky notes-type clone! :D!\n\n Visit my Github profile:', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),),
                ),
                InkWell(
                  onTap: () => _launchURL(),
                  child: const Text('https://github.com/DymNomZ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400, fontSize: 14),)),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(
      builder: (context, value, child) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade50,
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
              showInfo();
            },
            icon: const Icon(
              Icons.more_horiz
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
                leading: Container(
                  width: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value.getNoteList()[index].color
                  ),
                ),
                title: Text(value.getNoteList()[index].title!, style: const TextStyle(fontWeight: FontWeight.w400),),
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