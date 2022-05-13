import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/model/note.dart';

class FirebaseService with ChangeNotifier {
  void addTofirestore(Note note) {
    FirebaseFirestore.instance
        .collection('Notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Notes')
        .doc(note.noteID)
        .set({
      'title': note.title,
      'notes': note.notes,
      'color': note.color,
      'ispinned': note.ispinned,
      'noteId': note.noteID,
      'dateTime': Timestamp.fromDate(note.dateTime),
    });
  }

  void removeFromFirestore(Note note) {
    FirebaseFirestore.instance
        .collection('Notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Notes')
        .doc(note.noteID)
        .delete()
        .then((value) {});
  }

  Future<void> fetchAllNotes() async {
    var res = await FirebaseFirestore.instance
        .collection('Notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Notes')
        .get();

    if (res.docs.isNotEmpty) {
      res.docs.forEach((element) async {
        Timestamp temp = element.data()['dateTime'];
        var date = DateTime.parse(temp.toDate().toString());
        Note note = Note(
            title: element.data()['title'],
            notes: element.data()['notes'],
            dateTime: date,
            color: element.data()['color'],
            ispinned: element.data()['ispinned'],
            noteID: element.data()['noteId']);

        if (element.data()['ispinned']) {
          await Hive.box('pinnedNotes').put(note.noteID, note);
        } else {
          await Hive.box('unpinnedNotes').put(note.noteID, note);
        }
      });
    }
  }
}
