import 'dart:ui';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:notes_app/firebase_services/firebase_services.dart';
import 'package:notes_app/model/note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/provider/notes_manager.dart';
import 'package:notes_app/screen3/editor_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _totalnotes = 5;
  List<Note> _pinnedNotes = [];
  List<Note> _unPinnedNotes = [];
  var _scrollController = ScrollController();

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 200, 143, 162),
      appBar: AppBar(
        // iconTheme: IconThemeData(
        //   opacity: 1,
        //   color: Colors.pink, //change your color here
        // ),
        elevation: 0,
        leading: Icon(
          LineIcons.evernote,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        actions: [
          PopupMenuButton(
            icon: GFAvatar(
              shape: GFAvatarShape.circle,
              size: 50,
              backgroundImage: AssetImage('assets/user2.jpg'),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    onTap: () async {},
                    child: Row(
                      children: [
                        Icon(LineIcons.user, color: Colors.red),
                        Text(
                            ' ${FirebaseAuth.instance.currentUser!.email.toString()}'),
                      ],
                    )),
                PopupMenuItem(
                    onTap: () async {
                      await Hive.deleteFromDisk();
                      await Hive.openBox('pinnedNotes');
                      await Hive.openBox('unpinnedNotes');
                      FirebaseAuth.instance.signOut();
                    },
                    child: Row(
                      children: [
                        Icon(LineIcons.alternateSignOut, color: Colors.red),
                        Text('  Logout'),
                      ],
                    )),
              ];
            },
          ),
        ],
        backgroundColor: Color.fromARGB(255, 200, 143, 162),
        title: Text(
          "Notes",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: Hive.box('pinnedNotes').listenable(),
            builder: (context, value, child) {
              return Column(
                children: [
                  if (Hive.box('pinnedNotes').length > 0)
                    Text(
                      "Pinned",
                      style: TextStyle(color: Colors.black),
                    ),
                  if (Hive.box('pinnedNotes').length > 0)
                    GridView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: Hive.box('pinnedNotes').length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 5 / 4,
                        //  crossAxisSpacing: 10,
                        // mainAxisSpacing: 10,
                      ),
                      itemBuilder: (_, index) {
                        var note = Hive.box('pinnedNotes').getAt(index) as Note;

                        Color notecolor = Color(note.color);
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return EditorScreen(
                                      note: note,
                                    );
                                  },
                                )).then((value) {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                    color: notecolor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            note.title,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  child: FaIcon(FontAwesomeIcons
                                                      .thumbtack),
                                                  onTap: () async {
                                                    Note newnote = Note(
                                                        title: note.title,
                                                        notes: note.notes,
                                                        dateTime: note.dateTime,
                                                        color: note.color,
                                                        ispinned: false,
                                                        noteID: note.noteID);
                                                    await Provider.of<
                                                                NotesManager>(
                                                            context,
                                                            listen: false)
                                                        .moveTounpinned(
                                                            newnote, context);
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                child: FaIcon(
                                                    FontAwesomeIcons.trash),
                                                onTap: () async {
                                                  await Hive.box('pinnedNotes')
                                                      .deleteAt(index);
                                                  Provider.of<FirebaseService>(
                                                          context,
                                                          listen: false)
                                                      .removeFromFirestore(
                                                          note);
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      note.notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: OutlinedButton(
                                          onPressed: null,
                                          child: Builder(builder: (context) {
                                            String result =
                                                Provider.of<NotesManager>(
                                                        context,
                                                        listen: false)
                                                    .checkDatime(note.dateTime);
                                            return result != 'other'
                                                ? Text(
                                                    '${result} ${formatDate(note.dateTime, [
                                                          hh,
                                                          ':',
                                                          nn,
                                                          am
                                                        ])}',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 72, 72, 72)),
                                                  )
                                                : Text(
                                                    ' ${formatDate(note.dateTime, [
                                                          DD,
                                                          ' ',
                                                          hh,
                                                          ':',
                                                          nn,
                                                          am
                                                        ])}',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 72, 72, 72)),
                                                  );
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            side: BorderSide(
                                                width: 2.0,
                                                color: Color.fromARGB(
                                                    255, 72, 72, 72)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      },
                    ),
                ],
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box('unpinnedNotes').listenable(),
            builder: (context, value, child) {
              // print(_pinnedNotes.length);
              return Column(
                children: [
                  if (Hive.box('unpinnedNotes').length > 0)
                    Text(
                      "Upcomming",
                      style: TextStyle(color: Colors.black),
                    ),
                  GridView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: Hive.box('unpinnedNotes').length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      //  crossAxisSpacing: 10,
                      // mainAxisSpacing: 10,
                    ),
                    itemBuilder: (_, index) {
                      var note = Hive.box('unpinnedNotes').getAt(index) as Note;
                      print(note.ispinned);
                      Color notecolor = Color(note.color);
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return EditorScreen(
                                    note: note,
                                  );
                                },
                              )).then((value) {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  color: notecolor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          note.title,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: InkWell(
                                                child:
                                                    Icon(LineIcons.thumbtack),
                                                onTap: () async {
                                                  Note newnote = Note(
                                                      title: note.title,
                                                      notes: note.notes,
                                                      dateTime: note.dateTime,
                                                      color: note.color,
                                                      ispinned: true,
                                                      noteID: note.noteID);
                                                  await Provider.of<
                                                              NotesManager>(
                                                          context,
                                                          listen: false)
                                                      .moveTopinned(
                                                          newnote, context);
                                                },
                                              ),
                                            ),
                                            InkWell(
                                              child: FaIcon(
                                                  FontAwesomeIcons.trash),
                                              onTap: () async {
                                                await Hive.box('unpinnedNotes')
                                                    .deleteAt(index);
                                                Provider.of<FirebaseService>(
                                                        context,
                                                        listen: false)
                                                    .removeFromFirestore(note);
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    note.notes,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  OutlinedButton(
                                    child: Builder(builder: (context) {
                                      String result = Provider.of<NotesManager>(
                                              context,
                                              listen: false)
                                          .checkDatime(note.dateTime);
                                      return result != 'other'
                                          ? Text(
                                              '${result} ${formatDate(note.dateTime, [
                                                    h,
                                                    ':',
                                                    nn,
                                                    am
                                                  ])}',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 72, 72, 72)),
                                            )
                                          : Text(
                                              ' ${formatDate(note.dateTime, [
                                                    DD,
                                                    ' ',
                                                    h,
                                                    ':',
                                                    nn,
                                                    am
                                                  ])}',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 72, 72, 72)),
                                            );
                                    }),
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                          width: 2.0, color: Colors.blue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ));
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.pinkAccent,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                Note tempNote = Note(
                    title: '',
                    notes: '',
                    dateTime: DateTime.now(),
                    color: 0,
                    ispinned: false,
                    noteID: '');
                return EditorScreen(
                  note: tempNote,
                );
              },
            )).then((value) {
              // setState(() {
              //   _totalnotes = 5;
              // });
            });
          },
          label: Text(
            'New',
            style: TextStyle(color: Colors.white),
          ),
          icon: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          )),
    );
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  // }
}
