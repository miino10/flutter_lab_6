import 'package:flutter/material.dart';

import 'package:flutter_lab_6/SQLite/sqlite.dart';
import 'package:flutter_lab_6/jsonModels/note_model.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({Key? key}) : super(key: key);

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final title = TextEditingController();
  final content = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create note"),
        actions: [
          IconButton(
            onPressed: () {
              //Add Note button
              //We should not allow empty data to the database
              if (formKey.currentState!.validate()) {
                db
                    .createNote(NoteModel(
                        noteTitle: title.text,
                        noteContent: content.text,
                        createdAt: DateTime.now().toIso8601String()))
                    .whenComplete(() {
                  //When this value is true
                  Navigator.of(context).pop(true);
                });
              }
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Form(
        //I forgot to specify key
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextFormField(
                controller: title,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Title is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),
              TextFormField(
                controller: content,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Content is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Content",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
