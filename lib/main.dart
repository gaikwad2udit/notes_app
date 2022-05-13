import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_format/date_format.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/firebase_services/firebase_services.dart';
import 'package:notes_app/model/note.dart';
import 'package:notes_app/provider/notes_manager.dart';
import 'package:notes_app/screen1/auth_screen.dart';
import 'package:notes_app/screen2/mainscreen.dart';
import 'package:notes_app/widgets/Loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appdocdir = await getApplicationDocumentsDirectory();
  Hive.init(appdocdir.path);
  Hive.registerAdapter(NoteAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return NotesManager();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return FirebaseService();
          },
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              primarySwatch: Colors.cyan,
              textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context)
                  .textTheme
                  .apply(bodyColor: Color.fromARGB(255, 0, 0, 0)))),
          home: FutureBuilder(
            future: Future.microtask(() async {
              await Hive.openBox('pinnedNotes');
              await Hive.openBox('unpinnedNotes');
            }),
            builder: (context, snapshot) {
              print("reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('error');
                }

                return StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data == null) {
                          //return Auth_screen();

                          return Auth_screen();
                        }
                        //fetch data before showing mainscreen

                        return FutureBuilder(
                            future: Provider.of<FirebaseService>(context,
                                    listen: false)
                                .fetchAllNotes(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return MainScreen();
                              }
                              return ScreenLoader();
                            });
                      } else {
                        return GFLoader(
                          type: GFLoaderType.ios,
                          size: MediaQuery.of(context).size.width * .13,
                        );
                      }
                    });
              }
              return const GFLoader(
                type: GFLoaderType.ios,
              );
            },
          )),
    );
  }
}
