
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';



class Bubble extends StatelessWidget {
  Bubble(this.message, this.isMe,this.fileType,this.date);

  final String message;
  final String fileType;
  final String date;
  
  final  isMe;

  @override
  Widget build(BuildContext context) {
    final bg = !isMe ? Colors.white : Colors.greenAccent.shade100;
    final align = !isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    
    final radius = isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3),
          constraints: BoxConstraints(minWidth:.5, maxWidth: MediaQuery.of(context).size.width*.6),
          padding:  fileType=="text"?const EdgeInsets.only(left:6.0,right: 1.0,top: 6,bottom: 6):const EdgeInsets.all(0),
          decoration: BoxDecoration(
            boxShadow: [
              fileType=="text"?BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12)):BoxShadow(
                    blurRadius: 0,
                     spreadRadius: 0,
                  )
            ],
            color: fileType=="text"?bg:Colors.white,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: fileType=="text"?EdgeInsets.only(right: 48.0):EdgeInsets.only(right:1),
                child: fileType=="text" ? Text(message,softWrap: true,style: TextStyle(
                    fontFamily: "Roboto",
                  ),)
                :Container( 
                width:MediaQuery.of(context).size.width*.6,
                height:MediaQuery.of(context).size.height*.32,
                child: Stack(fit: StackFit.loose,
                overflow: Overflow.clip,
                alignment: Alignment.center,
                children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                 width: double.infinity,
                 height: double.infinity,
                  child: ClipRRect(borderRadius: radius,
                    child: FadeInImage.memoryNetwork(placeholder:kTransparentImage , image: message,fit: BoxFit.fill,)))

                ],
                ),
                )
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(date,
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 10.0,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600
                        )),
                    SizedBox(width: 3.0),
                    
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}


