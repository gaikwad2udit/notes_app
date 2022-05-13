import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter/services.dart' show rootBundle;

class Auth_screen extends StatefulWidget {
  //const Login_page({ Key? key }) : super(key: key);
  static const Routename = "authscreen";

  @override
  State<Auth_screen> createState() => _Auth_screenState();
}

class _Auth_screenState extends State<Auth_screen> {
  bool iskeyboardopen = false;

  showdialogforprivacy(String value) async {
    String result = '';

    if (value == 'privacy') {
      result = await rootBundle.loadString('assets/privacy_policy.txt');
    } else {
      result = await rootBundle.loadString('assets/terms_condition.txt');
    }
    // log(result);

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content:
                SingleChildScrollView(child: Container(child: Text(result))),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //  var keyboardVisibilityController = KeyboardVisibilityController();
    // Query

    // Subscribe
    // var keyboardSubscription =
    //     keyboardVisibilityController.onChange.listen((bool visible) {
    //   if (visible) {
    //     setState(() {
    //       iskeyboardopen = true;
    //     });
    //   } else {
    //     setState(() {
    //       iskeyboardopen = false;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color.fromARGB(255, 200, 143, 162),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   colorFilter: ColorFilter.mode(
                  //       Colors.black.withOpacity(0.5), BlendMode.srcOver),
                  //   fit: BoxFit.cover,
                  //   image: image
                  // ),
                  ),
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: auth_card(),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * .33,
              top: MediaQuery.of(context).size.height * .13,
              child: Column(
                children: [
                  Text(
                    "Notes",
                    style: TextStyle(
                        color: Color.fromARGB(255, 68, 67, 67),
                        fontSize: MediaQuery.of(context).size.width * .08),
                  ),
                  Text(
                    "Take notes with ease",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: MediaQuery.of(context).size.width * .035),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class auth_card extends StatefulWidget {
  //const auth_card({ Key? key }) : super(key: key);

  @override
  _auth_cardState createState() => _auth_cardState();
}

class _auth_cardState extends State<auth_card> {
  var auth = true;
  var _key = GlobalKey<FormState>();
  var confirmpassword;

  var username = "";
  var Password = '';
  var email = '';
  final authuser = FirebaseAuth.instance;
  bool isloading = false;

  void formsubittofirebsae() async {
    int i = 0;
    try {
      if (auth) {
        setState(() {
          isloading = true;
        });
        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            isloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'check your Network connection',
              style: TextStyle(color: Color.fromARGB(255, 3, 3, 3)),
            ),
            backgroundColor: Colors.yellow,
          ));
          return;
        });

        try {
          await authuser.signInWithEmailAndPassword(
              email: email, password: Password);
        } on FirebaseAuthException catch (e) {
          setState(() {
            isloading = false;
          });
          i++;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              e.message.toString(),
              style: TextStyle(color: Color.fromARGB(255, 3, 3, 3)),
            ),
            backgroundColor: Colors.yellow,
          ));
        }
      } else {
        setState(() {
          isloading = true;
        });

        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            isloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'check your Network connection',
              style: TextStyle(color: Color.fromARGB(255, 3, 3, 3)),
            ),
            backgroundColor: Colors.yellow,
          ));
          return;
        });

        try {
          await authuser
              .createUserWithEmailAndPassword(email: email, password: Password)
              .whenComplete(() {
            FirebaseFirestore.instance
                .collection('usersdata')
                .add({'email': email, 'username': username});
          });
        } on FirebaseAuthException catch (e) {
          setState(() {
            isloading = false;
          });
          i++;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: Colors.red,
          ));
        }

        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            isloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'check your Network connection',
              style: TextStyle(color: Color.fromARGB(255, 3, 3, 3)),
            ),
            backgroundColor: Colors.yellow,
          ));
          return;
        });
      }
    } on PlatformException catch (error) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("error occured ")));
    } catch (error) {}
  }

  void anonsignin() async {
    int i = 0;
    //server timpstamp in seconds precision will get bubby on traffic needs milisecond or nanosecond precision
    setState(() {
      isloading = true;
    });

    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        isloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'check your Network connection',
          style: TextStyle(color: Color.fromARGB(255, 3, 3, 3)),
        ),
        backgroundColor: Colors.yellow,
      ));
      return;
    });

    try {
      authuser.signInAnonymously().whenComplete(() async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'user': FirebaseAuth.instance.currentUser!.uid,
          'time': FieldValue.serverTimestamp()
        });
      });
    } on FirebaseAuthException catch (e) {
      i++;
      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error occured')));
    }

    //.catchError(onError)

    setState(() {
      isloading = true;
    });
  }

//raised buttons swapping based on auth value
  List<Widget> showbuttons() {
    //List<RaisedButton> data;
    if (auth) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            onPressed: () {
              if (!_key.currentState!.validate()) {
                return;
              }
              _key.currentState!.save();
              formsubittofirebsae();
              setState(() {});
            },
            color: Colors.indigoAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Text(
              "  Log In  ",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            onPressed: () {
              _key.currentState!.reset();

              setState(() {
                auth = false;
              });
            },
            color: Colors.indigoAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Text(
              "  Sign Up  ",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: RaisedButton(
            onPressed: () {
              if (!_key.currentState!.validate()) {
                return;
              }
              _key.currentState!.save();
              formsubittofirebsae();

              setState(() {});
            },
            color: Colors.indigoAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Text(
              "  sign up  ",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            _key.currentState!.reset();

            setState(() {
              auth = true;
            });
          },
          color: Colors.indigoAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Text(
            "  login  ",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void showdialogforconnectivity() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('connection'),
          content: Text('no internet connection'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;

    return Opacity(
      opacity: 0.7,
      child: Stack(
        children: [
          Card(
            margin: EdgeInsets.only(top: 150, left: 20, right: 20),
            elevation: 10.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      if (!auth)
                        TextFormField(
                          key: ValueKey("Username"),
                          decoration: InputDecoration(labelText: "Username"),
                          //autovalidate: true,
                          validator: (value) {
                            if (value!.isEmpty || value.length <= 3) {
                              return "username must be greater than 4 characters";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            username = newValue!;
                          },
                        ),
                      TextFormField(
                        key: ValueKey("Email"),
                        decoration: InputDecoration(labelText: "Email"),
                        //autovalidate: true,
                        validator: (value) {
                          if (value!.isEmpty || value.length <= 3) {
                            return "enter valid email";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          email = newValue!;
                        },
                      ),
                      TextFormField(
                        onSaved: (newValue) {
                          Password = newValue!;
                        },
                        //autovalidate: true,
                        validator: (value) {
                          if (value!.length < 6 || value.contains(' ')) {
                            return "must be greator than 6 characters ";
                          }
                          confirmpassword = value;
                          return null;
                        },
                        obscureText: true,
                        key: ValueKey("password"),
                        decoration: InputDecoration(labelText: "password"),
                      ),
                      SizedBox(
                        height: 9,
                      ),
                      if (!auth)
                        TextFormField(
                          validator: (value) {
                            if (value != confirmpassword) {
                              return "password do not match";
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Re enter password",
                              labelStyle: TextStyle(color: Colors.blue)),
                        ),
                      ...showbuttons(),
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: ElevatedButton(
                      //       style: ButtonStyle(
                      //           backgroundColor:
                      //               MaterialStateProperty.all<Color>(
                      //                   Colors.white)),
                      //       onPressed: () {
                      //         anonsignin();
                      //       },
                      //       child: Text(
                      //         "Enter Anonymously",
                      //         style: TextStyle(color: Colors.black),
                      //       )),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isloading)
            Center(
              child: GFLoader(
                type: GFLoaderType.ios,
                duration: Duration(microseconds: 10000),
              ),
            )
        ],
      ),
    );
  }
}
