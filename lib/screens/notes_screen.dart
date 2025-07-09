import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';
import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    if (authProvider.user != null) {
      notesProvider.fetchNotes(authProvider.user!.uid);
    }
  }

  void _showNoteDialog({Note? note}) {
    final textController = TextEditingController(text: note?.text ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final notesProvider = Provider.of<NotesProvider>(context, listen: false);
              if (note == null) {
                await notesProvider.addNote(authProvider.user!.uid, text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added!')));
              } else {
                await notesProvider.updateNote(note.id, text, authProvider.user!.uid);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated!')));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out!')));
            },
          ),
        ],
      ),
      body: notesProvider.isLoading
    ? const Center(child: CircularProgressIndicator())
    : notesProvider.notes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Nothing here yet—tap ➕ to add a note.',
                  style: TextStyle(color: Color.fromARGB(255, 12, 12, 12)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
                  itemCount: notesProvider.notes.length,
                  itemBuilder: (context, index) {
                    final note = notesProvider.notes[index];
                    return ListTile(
                      title: Text(note.text),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showNoteDialog(note: note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await notesProvider.deleteNote(note.id, authProvider.user!.uid);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted!')));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}