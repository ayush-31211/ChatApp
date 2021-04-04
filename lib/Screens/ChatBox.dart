import 'dart:io';
import 'package:ChatApp/Screens/showBottom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Widget.dart';

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("My Bad "),
    content: Text("It's not done yet !"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class ChatBox extends StatefulWidget {
  final String userId;
  final String username;
  final String url;
  ChatBox(this.userId, this.username, this.url);

  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  bool istrue;

  TextEditingController chatmessage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatmessage = new TextEditingController();
    istrue = true;
  }

  void func(String filetype, String text) async {
    if (text.length > 0) {
      Timestamp _time = Timestamp.now();
      List<dynamic> chats;

      FirebaseFirestore.instance.collection('chat').add({
        "message": text,
        "userid": FirebaseAuth.instance.currentUser.uid,
        "timestamp": _time,
        "fileType": filetype
      }).then((value) async {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("friends")
            .doc(widget.userId);
        DocumentSnapshot ref = await docRef.get();

        print(ref.data());

        chats = ref.data()['chats'];
        chats.add({"id": value.id, "timestamp": _time});
        docRef.update({"chats": FieldValue.arrayUnion(chats)}).then(
            (valuei) async {
          DocumentReference docRef = FirebaseFirestore.instance
              .collection('user')
              .doc(widget.userId)
              .collection("friends")
              .doc(FirebaseAuth.instance.currentUser.uid);
          DocumentSnapshot ref = await docRef.get();
          print(ref.data());
          chats = ref.data()['chats'];
          chats.add({"id": value.id, "timestamp": _time});
          docRef.update({"chats": FieldValue.arrayUnion(chats)});
        });
      });
      chatmessage.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: .9,
          title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*?widget.url.length>0?CircleAvatar(child:Text(widget.username.substring(0,1),radius: 20,backgroundColor: Colors.green,):CircleAvatar(child: SizedBox(),backgroundImage:NetworkImage(widget.url),radius: 20,),*/

                widget.url.length > 0
                    ? CircleAvatar(
                        child: SizedBox(),
                        backgroundImage: NetworkImage(widget.url),
                        radius: 20,
                      )
                    : CircleAvatar(
                        child: Text(widget.username.substring(0, 1)),
                        radius: 20,
                        backgroundColor: Colors.green,
                      ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  widget.username.substring(0, 1).toUpperCase() +
                      widget.username.substring(1).toLowerCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: "Roboto"),
                )
              ]),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.green,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.videocam,
                color: Colors.green,
              ),
              onPressed: () {
                showAlertDialog(context);
                print(widget.username);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.green,
              ),
              onPressed: () {
                showAlertDialog(context);
              },
            ),

            /* DropdownButtonHideUnderline(
            child: DropdownButton(
         elevation: 8,
         icon:  Icon(Icons.more_vert,color: Colors.green,),

              underline: null, 
                items: [
                   DropdownMenuItem(
                      child: Text("Logout"),
                      value: "logout",
                    ),
                ],
                onChanged: (value)async {
                  if(value=="logout")
                  await FirebaseAuth.instance.signOut().then((value) => Navigator.pop(context));
                }),),
                SizedBox(width:5)*/
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * .7,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("user")
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .collection("friends")
                        .doc(widget.userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        print(snapshot.data['chats'].length);

                        if (snapshot.data['chats'].length != 0) {
                          List<dynamic> messageBubbles = snapshot.data['chats'];
                          messageBubbles.sort((a, b) =>
                              a['timestamp'].compareTo(b['timestamp']));
                          List<dynamic> sortedmessageBubbles =
                              List.from(messageBubbles.reversed);
                          return ListView.builder(
                              reverse: true,
                              itemCount: snapshot.data['chats'].length,
                              itemBuilder: (context, index) {
                                return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("chat")
                                      .doc(sortedmessageBubbles[index]['id'])
                                      .snapshots(),
                                  builder: (context, snapshoty) {
                                    if (snapshoty.hasData) {
                                      Timestamp t = snapshoty.data['timestamp'];
                                      DateTime d = t.toDate();
                                      print(d.hour); //

                                      return Bubble(
                                          snapshoty.data['message'],
                                          FirebaseAuth
                                                  .instance.currentUser.uid ==
                                              snapshoty.data['userid'],
                                          snapshoty.data['fileType'],
                                          "${d.hour.toString()}.${d.minute}");
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                              });
                        }
                        return Center(
                          child: Text(
                            "Start your Conversation",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto',
                                fontSize: 18),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15.0),
                height: 61,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35.0),
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 5,
                                color: Colors.grey)
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.keyboard_voice,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  showAlertDialog(context);
                                }),
                            Expanded(
                              child: TextField(
                                controller: chatmessage,
                                onChanged: (value) {
                                  if (chatmessage.text == null)
                                    setState(() {
                                      istrue = false;
                                    });
                                },
                                decoration: InputDecoration(
                                    hintText: "Type Something...",
                                    hintStyle:
                                        TextStyle(color: Colors.blueAccent),
                                    border: InputBorder.none),
                              ),
                            ),
                            IconButton(
                                icon:
                                    Icon(Icons.photo_camera, color: Colors.red),
                                onPressed: () async {
                                  var pickedFile = await ImagePicker()
                                      .getImage(source: ImageSource.camera);
                                  if (pickedFile != null) {
                                    File _image = File(pickedFile.path);
                                    var ref;
                                    ref = FirebaseStorage.instance
                                        .ref()
                                        .child(
                                            "${FirebaseAuth.instance.currentUser.uid}/images")
                                        .child("${DateTime.now()}.jpg");
                                    await ref.putFile(_image);
                                    var dowurl = await ref.getDownloadURL();
                                    print(dowurl.toString());
                                    String url = dowurl.toString();
                                    await func("images", url);
                                  } else {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content:
                                          Text("Please choose Pick a file"),
                                    ));
                                  }
                                }),
                            IconButton(
                              icon: Icon(Icons.attach_file,
                                  color: Colors.blueAccent),
                              onPressed: () async {
                                await showBottom(context, func);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          if (chatmessage.text.length != null) {
                            await func("text", chatmessage.text);
                            chatmessage.clear();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ]));
  }
}
