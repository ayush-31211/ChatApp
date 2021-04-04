import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

showBottom(BuildContext ctx, Function func) async {
  await showModalBottomSheet(
      elevation: 0,
      backgroundColor: Colors.yellow.withOpacity(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      context: ctx,
      builder: (btcx) {
        return TypeSelector(func);
      });
}

class TypeSelector extends StatefulWidget {
  Function func;
  TypeSelector(this.func);
  @override
  _TypeSelectorState createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  List<Map<String, dynamic>> icons = [
    {
      "icon": Icons.image,
      "text": "Image",
    },
    {
      "icon": Icons.video_call_outlined,
      "text": "Video",
    }
  ];

  Future getImage(int i) async {
    var pickedFile;
    if (i == 0)
      pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    else
      pickedFile = await ImagePicker().getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      File _image = File(pickedFile.path);

      var ref;
      if (i == 0)
        ref = FirebaseStorage.instance
            .ref()
            .child("${FirebaseAuth.instance.currentUser.uid}/images")
            .child("${DateTime.now()}.jpg");
      else
        ref = FirebaseStorage.instance
            .ref()
            .child("${FirebaseAuth.instance.currentUser.uid}/videos")
            .child("${DateTime.now()}.mp4");
      await ref.putFile(_image);

      var dowurl = await ref.getDownloadURL();
      print(dowurl.toString());
      String url = dowurl.toString();

      if (i == 0)
        widget.func("images", url);
      else
        widget.func("videos", url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Please choose Pick a file",
          style: TextStyle(fontFamily: "Roboto"),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(6),
        height: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 3 / 2,
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: icons.length,
            itemBuilder: (_, i) {
              return InkWell(
                onTap: () {
                  getImage(i);
                },
                child: Container(
                  child: Column(
                    children: [
                      CircleAvatar(
                        child: Icon(icons[i]["icon"]),
                      ),
                      Text(icons[i]["text"])
                    ],
                  ),
                ),
              );
            }));
  }
}
