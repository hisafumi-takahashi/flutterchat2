import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterchat2/logic/generate_message_info.dart';
import 'package:flutterchat2/model/message_info.dart';
import 'package:flutterchat2/view/line.dart';

class MessageStream extends StatelessWidget {
  String roomID = '';

  MessageStream({Key? key, roomID}) : super(key: key){
    this.roomID = roomID;
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final _user = _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _db
          .collection('rooms')
          .doc(roomID)
          .collection('messages')
          .orderBy('time', descending: true)
          .limit(50)
          .snapshots()
          .asyncMap((messages) => Future.wait([
                for (var message in messages.docs) generateMessageInfo(message)
              ])),
      builder: (context, AsyncSnapshot<List<BaseMessageInfo>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        //final messages = snapshot.data!.docs;
        List<StatelessWidget> Lines = [];
        //for (var message in messages) {
        snapshot.data!.forEach((element) {
          if (element is TextMessageInfo) {
            final messageText = element.message;
            final messageSender = element.sender;

            final messageLine = MessageLine(
              text: messageText,
              name: element.name,
              isMine: _user!.email == messageSender,
            );
            Lines.add(messageLine);
          } else if (element is ImageMessageInfo) {
            final image = element.image;
            final messageSender = element.sender;

            final messageLine = ImageLine(
              image: image,
              name: element.name,
              isMine: _user!.email == messageSender,
            );
            Lines.add(messageLine);
          }
        });
        return Expanded(
            child: ListView(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: Lines,
        ));
      },
    );
  }
}
