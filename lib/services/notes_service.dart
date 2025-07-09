import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesService {
  final _notesCollection = FirebaseFirestore.instance.collection('notes');

  Future<List<Note>> fetchNotes(String uid) async {
    final snapshot = await _notesCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs.map((doc) => Note.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> addNote(String uid, String text) async {
    await _notesCollection.add({'uid': uid, 'text': text});
  }

  Future<void> updateNote(String id, String text) async {
    await _notesCollection.doc(id).update({'text': text});
  }

  Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }
} 