import 'dart:io';
import 'dart:ui';

import 'package:ChatApp/Screens/UserScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AuthScreen extends StatefulWidget {

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool islogin;
  TextEditingController _username;
  TextEditingController _email;
  TextEditingController _password;
  String email;
  String password;
  String username;
  bool istrue;
  File _image;
  bool isval;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    islogin = false;
    email = '';
    username = '';
    password = '';
    isval = false;
    _image = null;
  }

  final _formkey = GlobalKey<FormState>();

  final auth = FirebaseAuth.instance;
  Future<void> submit(String email, String password, String username,
      bool isLogin, BuildContext ctx, File _image) async {
    UserCredential authresult;
    try {
      var dwnurl = "";

      if (isLogin == false) {
        authresult = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        if (_image != null) {
          var ref = FirebaseStorage.instance
              .ref()
              .child("${FirebaseAuth.instance.currentUser.uid}/images")
              .child("profile.jpg");
          await ref.putFile(_image);
          dwnurl = await ref.getDownloadURL();
        }

        FirebaseFirestore.instance
            .collection("user")
            .doc(authresult.user.uid)
            .set({
          "username": username,
          "email": email,
          "url": dwnurl,
         
        });
      } else {
        authresult = await auth.signInWithEmailAndPassword(
            email: email, password: password);
      }
      if (authresult.user.uid != null)
        Navigator.of(ctx)
            .push(MaterialPageRoute(
                builder: (bctx) =>
                    UserScreen(authresult.user.uid, username)))
            .then((value) async {
          setState(() {
            isval = !isval;
            
            _username.clear();
            _password.clear();
            _email.clear();
          });
        });
    } on PlatformException catch (err) {
      var message = 'An error occured';
      if (err.message != null) message = err.message;
      print(message);
    } catch (err) {
      print(err);

      setState(() {
        isval != isval;
        _username.clear();
        _password.clear();
        _email.clear();
      });
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(err.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    void _trysubmit() async {
      final isvalid = _formkey.currentState.validate();
      if (isvalid) {
        setState(() {
          _formkey.currentState.save();

          submit(email.trim(), password.trim(), username.trim(), islogin,
              context, _image);
        });
      }
    }

    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        elevation: 12,
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * .8,
            height: !islogin ? 510 : 325,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
            child: SingleChildScrollView(
              child: Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      if (!islogin)
                        Center(
                            child: CircleAvatar(
                          child: _image != null
                              ? SizedBox()
                              : Icon(Icons.add_a_photo),
                          radius: 35,
                          backgroundImage: _image != null
                              ? FileImage(_image)
                              : NetworkImage(
                                  "https://images.unsplash.com/photo-1599110364654-5572a272237f?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MzR8fHVzZXJ8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60"),
                        )),
                      if (!islogin)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .004,
                        ),
                      if (!islogin)
                        Center(
                          child: FlatButton(
                              child: Text(
                                "Add your Picture",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                var pickedFile = await ImagePicker()
                                    .getImage(source: ImageSource.camera);
                                if (pickedFile != null) {
                                  setState(() {
                                    _image = File(pickedFile.path);
                                  });
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("Please add your picture "),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ));
                                }
                              }),
                        ),
                      if (!islogin)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .006,
                        ),
                      TextFormField(
                          decoration:
                              InputDecoration(labelText: "Email Address"),
                          obscureText: false,
                          onChanged: (value) {
                            email = value;
                          },
                          controller: _email,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'this should not be empty';
                            return null;
                          }),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .016,
                      ),
                      if (islogin == false)
                        TextFormField(
                          decoration: InputDecoration(labelText: "Username"),
                          obscureText: false,
                          onChanged: (value) {
                            username = value;
                          },
                          controller: _username,
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .016,
                      ),
                      TextFormField(
                          decoration: InputDecoration(labelText: "Password"),
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          controller: _password,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'this should not be empty';
                            return null;
                          }),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .012,
                      ),
                      Center(
                          child: !isval
                              ? RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      isval = !isval;
                                    });
                                    _trysubmit();
                                  },
                                  child: Text(
                                    islogin == true ? "Log In" : "Sign Up",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.pink[300])
                              : CircularProgressIndicator()),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .006,
                      ),
                      Center(
                        child: FlatButton(
                          child: Text(
                            islogin == false
                                ? "I already have an account"
                                : "Create a new account",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            setState(() {
                              islogin = !islogin;
                              if (_email != null) _email.clear();
                              if (_password != null) _password.clear();
                              if (_username != null) _username.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  )),
            )));
  }
}
