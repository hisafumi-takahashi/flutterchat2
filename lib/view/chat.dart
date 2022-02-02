import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User? _user;
String roomID = '';

class Chat extends StatefulWidget {
  final String title = 'ChatRoom';

  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final messageTextController = TextEditingController();
  String? messageText;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map;
    roomID = arguments['RoomID'];

    return Scaffold(
        appBar: AppBar(
          title: Text('ルーム：'+arguments['RoomID']),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const MessageStream(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: messageTextController,
                          onChanged: (value) {
                            messageText = value;
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            hintText: 'Type your message ...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          messageTextController.clear();
                          _db.collection('rooms').doc(roomID).collection(
                              'messages').add({
                            'message': messageText,
                            'sender': _user!.email,
                            'time': FieldValue.serverTimestamp(),
                          });
                        },
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ])));
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder <List<MessageInfo>>(
      stream: _db
          .collection('rooms').doc(roomID).collection('messages')
          .orderBy('time', descending: true)
          .limit(50)
          .snapshots()
          .asyncMap((messages) => Future.wait([for (var message in messages.docs) generateMessageInfo(message)])),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        //final messages = snapshot.data!.docs;
        List<MessageLine> messageLines = [];
        //for (var message in messages) {
        snapshot.data!.forEach((element){
          final messageText = element.message;
          final messageSender = element.name;

          final messageLine = MessageLine(
            text: messageText,
            sender: messageSender,
            isMine: _user!.email == messageSender,
          );

          messageLines.add(messageLine);
        });
        return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 20.0),
              children: messageLines,
            ));
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMine;

  const MessageLine(
      {Key? key, required this.sender, required this.text, required this.isMine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    while(sender==''){}
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
            ),
          ),
          Material(
            borderRadius: isMine
                ? const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : const BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMine ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInfo {
  late String sender;
  late String name;
  late String message;
  late Timestamp time;

  MessageInfo(sender, name, message, time) {
    this.sender = sender;
    this.name = name;
    this.message = message;
    this.time = time;
  }
}

Stream<List<MessageInfo>> messagesStream(roomId) {
  return _db
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('time')
      .snapshots()
      .asyncMap((messages) => Future.wait([for (var message in messages.docs) generateMessageInfo(message)]));
}

Future<MessageInfo> generateMessageInfo(QueryDocumentSnapshot message) async {
  var name = await getUserData(message.get('sender'));
  return MessageInfo(message.get('sender'),name,message.get('message'),message.get('time'));
}

Future<String> getUserData(nowSender) async {
  var doc = await _db.collection('users').doc(nowSender).get();
  var name = await doc.get('name');
  return Future<String>.value(name);
}