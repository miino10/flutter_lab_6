import 'package:flutter/material.dart';
import 'package:flutter_lab_6/jsonModels/note_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lab_6/SQLite/sqlite.dart';
import 'package:flutter_lab_6/Views/create_note.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late DatabaseHelper handler;
  late Future<List<NoteModel>> notes;
  final db = DatabaseHelper();
  final title = TextEditingController();
  final content = TextEditingController();
  final keyword = TextEditingController();

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.getNotes();
    handler.initDB().whenComplete(() {
      notes = getAllNotes();
    });
    super.initState();
  }

  Future<List<NoteModel>> getAllNotes() {
    return handler.getNotes();
  }

  Future<List<NoteModel>> searchNote() {
    return handler.searchNotes(keyword.text);
  }

  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNote()),
          ).then((value) {
            if (value != null && value) {
              _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: keyword,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    notes = searchNote();
                  });
                } else {
                  setState(() {
                    notes = getAllNotes();
                  });
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.search),
                hintText: "Search",
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NoteModel>>(
              future: notes,
              builder: (BuildContext context,
                  AsyncSnapshot<List<NoteModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data"));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  final items = snapshot.data ?? <NoteModel>[];
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        subtitle: Text(DateFormat("yMd").format(
                          DateTime.parse(items[index].createdAt),
                        )),
                        title: Text(items[index].noteTitle),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Note"),
                                  content: const Text(
                                    "Are you sure you want to delete this note?",
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        db
                                            .deleteNote(items[index].noteId!)
                                            .whenComplete(() {
                                          _refresh();
                                          Navigator.of(context).pop(true);
                                        });
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        onTap: () {
                          title.text = items[index].noteTitle;
                          content.text = items[index].noteContent;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                actions: [
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          if (title.text.isEmpty ||
                                              content.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Title and content cannot be empty"),
                                              ),
                                            );
                                          } else {
                                            db
                                                .updateNote(
                                                    title.text,
                                                    content.text,
                                                    items[index].noteId)
                                                .whenComplete(() {
                                              _refresh();
                                              Navigator.pop(context);
                                            });
                                          }
                                        },
                                        child: const Text("Update"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  ),
                                ],
                                title: const Text("Update note"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: title,
                                      decoration: const InputDecoration(
                                        labelText: "Title",
                                      ),
                                    ),
                                    TextFormField(
                                      controller: content,
                                      decoration: const InputDecoration(
                                        labelText: "Content",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
