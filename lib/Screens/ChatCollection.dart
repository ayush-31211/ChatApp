import 'dart:math';

import 'package:ChatApp/Screens/ChatBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatCollection extends StatefulWidget {
  final String uid;
  final String username;

  ChatCollection(this.uid, this.username);

  @override
  _ChatCollectionState createState() => _ChatCollectionState();
}

class _ChatCollectionState extends State<ChatCollection> {
  Future<void> getref(dynamic snapshot) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("friends")
        .doc(snapshot.id);
    DocumentSnapshot ref = await docRef.get();
    if (ref.data() == null) {
      docRef.set({
        'chats': List<dynamic>(),
      });
    }
    DocumentReference docRefi = FirebaseFirestore.instance
        .collection('user')
        .doc(snapshot.id)
        .collection("friends")
        .doc(FirebaseAuth.instance.currentUser.uid);
    DocumentSnapshot refi = await docRefi.get();
    if (refi.data() == null) {
      await docRefi.set({
        'chats': List<dynamic>(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> color=[
    Colors.amber,Colors.indigo,Colors.orange,Colors.purpleAccent,Colors.teal
    ];
    return Scaffold(
      
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("user").snapshots(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              else if (snapshot.hasData) {
                print(snapshot.data.documents.length);
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (_, index) {
                      
                        if (snapshot.data.documents[index].id != widget.uid) {
                          getref(snapshot.data.documents[index]);

                          return Card(
                            elevation: 10,
                            key: UniqueKey(),
                            shadowColor: Colors.white10,
                            child: ListTile(
                              key: UniqueKey(),
                              contentPadding: const EdgeInsets.only(
                                  top: 8, left: 8, right: 5, bottom: 8),
                              leading: snapshot.data.documents[index]['url']
                                          .length ==
                                      0
                                  ? CircleAvatar(
                                      child: Text(snapshot
                                          .data.documents[index]["username"]
                                          .toString()
                                          .substring(0, 1)),
                                      radius: 25,backgroundColor: color[Random().nextInt(5)]
                                    )
                                  : CircleAvatar(
                                      child: SizedBox(),
                                      backgroundImage: NetworkImage(snapshot
                                          .data.documents[index]["url"]),
                                      radius: 25,backgroundColor: color[Random().nextInt(5)],
                                    ),
                              title: Text(
                                snapshot.data.documents[index]["username"],
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: "Roboto"),
                              ),
                              subtitle: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("user")
                                      .doc(widget.uid)
                                      .collection("friends")
                                      .doc(snapshot.data.documents[index].id)
                                      .snapshots(),
                                  builder: (context, snapshoty) {
                                    if (snapshoty.hasData) {
                                      List<dynamic> messageBubbles =
                                          snapshoty.data['chats'];

                                      if (messageBubbles.length > 0) {
                                        messageBubbles.sort((a, b) =>
                                            b['timestamp']
                                                .compareTo(a['timestamp']));
                                        print(messageBubbles);
                                        return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection("chat")
                                                .doc(messageBubbles[0]['id'])
                                                .snapshots(),
                                            builder: (context, snapshotyi) {
                                              if (snapshotyi.hasData) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    snapshotyi.data[
                                                                "fileType"] ==
                                                            "text"
                                                        ? Text(
                                                            snapshotyi
                                                                        .data[
                                                                            'message']
                                                                        .length <
                                                                    28
                                                                ? snapshotyi
                                                                        .data[
                                                                    'message']
                                                                : "${snapshotyi.data['message'].toString().substring(0, 19)}....",
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontFamily:
                                                                    "Roboto"),
                                                          )
                                                        : Text(
                                                            "${snapshotyi.data["fileType"]}"),
                                                    Text(
                                                      '${messageBubbles[0]["timestamp"].toDate().hour.toString()}:${messageBubbles[0]["timestamp"].toDate().minute}',
                                                      style: TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                                  ],
                                                );
                                              }
                                              return
                                                      Text("waiting ...");
                                            });
                                      }
                                      return Text(
                                          "start your conversation now .......",);
                                    }
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }),
                              onTap: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (_) => ChatBox(
                                            snapshot.data.documents[index].id,
                                            snapshot.data.documents[index]
                                                ["username"],
                                            snapshot.data.documents[index]
                                                ['url'])));
                              },
                            ),
                          );
                        }
                        return SizedBox();
                      });
                    }
              
              else if (!snapshot.hasData)
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ));
            }));
  }
}
