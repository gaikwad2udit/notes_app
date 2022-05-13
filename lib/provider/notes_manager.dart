import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/firebase_services/firebase_services.dart';
import 'package:notes_app/model/note.dart';
import 'package:provider/provider.dart';

class NotesManager with ChangeNotifier {
  Future<void> moveTopinned(Note note, BuildContext context) async {
    await Hive.box('unpinnedNotes').delete(note.noteID);

    await Hive.box('pinnedNotes').put(note.noteID, note);

    Provider.of<FirebaseService>(context, listen: false).addTofirestore(note);
    // notifyListeners();
  }

  Future<void> moveTounpinned(Note note, BuildContext context) async {
    await Hive.box('pinnedNotes').delete(note.noteID);

    await Hive.box('unpinnedNotes').put(note.noteID, note);

    Provider.of<FirebaseService>(context, listen: false).addTofirestore(note);
    // notifyListeners();
  }

  String checkDatime(DateTime dateToCheck) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return 'Today';
    } else if (aDate == yesterday) {
      return 'Yesterday';
    } else if (aDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return 'other';
    }
  }
}
