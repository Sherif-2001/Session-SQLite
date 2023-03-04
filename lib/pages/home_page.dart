import 'package:flutter/material.dart';
import 'package:sqlite_demo/models/note.dart';
import 'package:sqlite_demo/services/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Note>? _notes = [];

  void _refreshNotes() async {
    final data = await SQLHelper.getAllNotes();
    setState(() {
      _notes = data;
    });
  }

  Future _addItem() async {
    await SQLHelper.insertNote(Note(
        title: _titleController.text,
        description: _descriptionController.text));
    _refreshNotes();
  }

  Future _updateItem(int id) async {
    await SQLHelper.updateNote(Note(
        id: id,
        title: _titleController.text,
        description: _descriptionController.text));
    _refreshNotes();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully deleted a note")));
    _refreshNotes();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final selectedNote = _notes!.firstWhere((element) => element.id == id);
      _titleController.text = selectedNote.title;
      _descriptionController.text = selectedNote.description!;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: "Description"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    id == null ? await _addItem() : await _updateItem(id);
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(id == null ? "Create New" : "Update"))
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  @override
  void dispose() {
    SQLHelper.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text("Notes in SQLite"), centerTitle: true),
      body: _notes != null
          ? ListView.builder(
              itemCount: _notes!.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_notes![index].title),
                  subtitle: Text(_notes![index].description ?? ""),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showForm(_notes![index].id),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () =>
                              _deleteItem(_notes![index].id ?? index),
                          icon: const Icon(Icons.delete),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(
              child: Text("Notes database is empty"),
            ),
    );
  }
}
