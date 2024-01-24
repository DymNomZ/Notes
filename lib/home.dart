import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<Note> filteredNotes = [];

  @override
  void initState(){
    super.initState();
    filteredNotes = sortToRecent();
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      sampleNotes.remove(note);
      filteredNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const WindowTitle(),
          SearchField(onChanged: onSearchTextChanged),
          (sampleNotes.isNotEmpty)
          ? Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 30),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  color: Colors.lightBlue.shade200,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      onTap: () async {
                        /*final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EditScreen(note: filteredNotes[index]),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            int originalIndex =
                                sampleNotes.indexOf(filteredNotes[index]);
                
                            sampleNotes[originalIndex] = Note(
                                id: sampleNotes[originalIndex].id,
                                title: result[0],
                                content: result[1],
                                modifiedTime: DateTime.now());
                                
                            filteredNotes[index] = Note(
                                id: filteredNotes[index].id,
                                title: result[0],
                                content: result[1],
                                modifiedTime: DateTime.now());
                          });
                        }*/
                      },
                      title: RichText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: '${filteredNotes[index].title} \n',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.5),
                            children: [
                              TextSpan(
                                text: filteredNotes[index].content,
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
                          'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}',
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
                        deleteNote(index);
                      }
                    })
                )));
              }
            )
          )
          : Padding(
             padding: const EdgeInsets.all(30.0),
             child: Center(
               child: Text('Create a note', 
               style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade500)
               ),
             ),
           ),
        ],
      ),
    );
  }
}