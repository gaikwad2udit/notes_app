import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:notes_app/firebase_services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:notes_app/constant.dart';
import 'package:notes_app/model/note.dart';
import 'package:notes_app/provider/notes_manager.dart';
import 'package:notes_app/screen2/mainscreen.dart';

class EditorScreen extends StatefulWidget {
  EditorScreen({
    Key? key,
    required this.note,
  }) : super(key: key);
  final Note note;
  // final String title;
  // final String notes;
  // final String noteID;
  // final int colorValue;
  // final bool ispinned;
  // final DateTime? datetime;
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  int _counter = 0;

  var _titlecontroller = TextEditingController();
  var _notesController = TextEditingController();
  int navigationValue = 0;
  bool _ispinned = false;
  late Color _pagecolor;
  List<bool> _selectedColor = [
    false,
    false,
    false,
    false,
    false,
  ];
  late Note _updatedNotes;
  List<Color> _colors = [
    Colors.white,
    Color.fromARGB(255, 156, 165, 214),
    Color.fromARGB(255, 208, 106, 186),
    Color.fromARGB(255, 104, 183, 184),
    Color.fromARGB(255, 184, 104, 104),
  ];
  void setColors() {
    _selectedColor = [
      false,
      false,
      false,
      false,
      false,
    ];
  }

  void _checkColor(int colorvalue) {
    //print(colorvalue);

    if (colorvalue == white.value) {
      _selectedColor[0] = true;
    }
    if (colorvalue == lightindigo.value) {
      _selectedColor[1] = true;
    }
    if (colorvalue == lightpink.value) {
      _selectedColor[2] = true;
    }
    if (colorvalue == lightgreen.value) {
      _selectedColor[3] = true;
    }
    if (colorvalue == lightbrown.value) {
      _selectedColor[4] = true;
    }
  }

  bool _isNewNote() {
    if (widget.note.title.isEmpty && widget.note.notes.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _titlecontroller.text = widget.note.title;
    _notesController.text = widget.note.notes;
    _ispinned = widget.note.ispinned;

    _pagecolor =
        widget.note.color == 0 ? Colors.white : Color(widget.note.color);

    _checkColor(widget.note.color);
  }

  void _showActionStatus() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("pinned "),
      backgroundColor: Colors.white.withOpacity(.3),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  void confirmDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("When to remind ? "),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: Container(
              width: 260.0,
              height: 120.0,
              decoration: BoxDecoration(

                  //shape: BoxShape.rectangle,
                  //color: const Color(0xFFFFFF),
                  //borderRadius: BorderRadius.all(Radius.circular(60.0)),

                  ),
              child: datetimePicker(),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: Size(100, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // <-- Radius
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Save',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // <-- Radius
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> addNotesToHiveBox() async {
    if (widget.note.noteID.isEmpty) {
      var id = Uuid().v4();
      Note newNote = Note(
          noteID: id,
          title: _titlecontroller.text,
          notes: _notesController.text,
          dateTime: DateTime.now(),
          color: _pagecolor.value,
          ispinned: _ispinned);
      print(newNote.ispinned);
      newNote.ispinned
          ? await Hive.box('pinnedNotes').put(id, newNote)
          : await Hive.box('unpinnedNotes').put(id, newNote);
      Provider.of<FirebaseService>(context, listen: false)
          .addTofirestore(newNote);
    } else {
      Note newNote = Note(
          noteID: widget.note.noteID,
          title: _titlecontroller.text,
          notes: _notesController.text,
          dateTime: widget.note.dateTime,
          color: _pagecolor.value,
          ispinned: _ispinned);

      if (widget.note.ispinned != _ispinned) {
        _ispinned
            ? await Provider.of<NotesManager>(context, listen: false)
                .moveTopinned(newNote, context)
            : await Provider.of<NotesManager>(context, listen: false)
                .moveTounpinned(newNote, context);
      } else {
        newNote.ispinned
            ? await Hive.box('pinnedNotes').put(widget.note.noteID, newNote)
            : await Hive.box('unpinnedNotes').put(widget.note.noteID, newNote);
        Provider.of<FirebaseService>(context, listen: false)
            .addTofirestore(newNote);
      }
    }
  }

  //start writting from here

  Future<bool> _onwillpop() async {
    if (_notesController.text.isEmpty && _titlecontroller.text.isEmpty) {
      return true;
    }
    await addNotesToHiveBox();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onwillpop,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _pagecolor,
          //title: Text('title'),
          actions: [
            IconButton(
                icon: _ispinned
                    ? FaIcon(FontAwesomeIcons.thumbtack)
                    : Icon(LineIcons.thumbtack),
                onPressed: () {
                  setState(() {
                    _ispinned ? _ispinned = false : _ispinned = true;
                  });
                }),
            IconButton(icon: FaIcon(FontAwesomeIcons.bell), onPressed: () {}),
          ],
        ),
        body: Container(
          color: _pagecolor,
          child: Column(
            children: [
              //Quill.QuillToolbar.basic(controller: _controller),
              TextField(
                controller: _titlecontroller,
                //  showCursor: _titlecontroller.text.length > 1 ? true : false,
                style: TextStyle(fontSize: 35),
                decoration: InputDecoration.collapsed(
                    hintText: 'Title', hintStyle: TextStyle(fontSize: 20)),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                    child: TextField(
                  controller: _notesController,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  //s textInputAction: TextInputAction.,
                  decoration: InputDecoration.collapsed(hintText: 'Notes'),
                )),
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.2),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 30,
                        width: 65,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              setColors();
                              _selectedColor[index] = true;
                              _pagecolor = _colors[index];
                            });
                          },
                          child: Container(
                            child: Center(
                              child: _selectedColor[index]
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                            decoration: BoxDecoration(
                                color: _colors[index],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          onPressed: () async {
            //confirmDialog();
            if (_titlecontroller.text.isEmpty &&
                _notesController.text.isEmpty) {
            } else {
              await addNotesToHiveBox();
            }

            Navigator.pop(context, true);
          },
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class datetimePicker extends StatelessWidget {
  const datetimePicker({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      initialValue: '',
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      dateLabelText: 'Date and time',
      onChanged: (val) => print(val),
      validator: (val) {
        return null;
      },
      onSaved: (val) => print(val),
    );
  }
}
