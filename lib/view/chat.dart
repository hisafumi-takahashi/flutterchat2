import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final storage = firebase_storage.FirebaseStorage.instance;
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
  String messageText='';

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
                            hintText: 'メッセージを入力...',
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
                          '送信',
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
    return StreamBuilder <List<BaseMessageInfo>>(
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
        List<StatelessWidget> Lines = [];
        //for (var message in messages) {
        snapshot.data!.forEach((element){
          if(element is TextMessageInfo){
            final messageText = element.message;
            final messageSender = element.sender;

            final messageLine = MessageLine(
              text: messageText,
              name: element.name,
              isMine: _user!.email == messageSender,
            );
            Lines.add(messageLine);
          }else if(element is ImageMessageInfo){
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 20.0),
              children: Lines,
            ));
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  final String name;
  final String text;
  final bool isMine;

  const MessageLine(
      {Key? key, required this.name, required this.text, required this.isMine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    while(name==''){}
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
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

class ImageLine extends StatelessWidget {
  final String name;
  final Image image;
  final bool isMine;

  const ImageLine(
      {Key? key, required this.name, required this.image, required this.isMine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    while(name==''){}
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
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
              child: Row(
                children: [
                  image,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BaseMessageInfo {
  late String sender;
  late String name;
  late Timestamp time;

  BaseMessageInfo(sender, name, time) {
    this.sender = sender;
    this.name = name;
    this.time = time;
  }
}

class TextMessageInfo extends BaseMessageInfo{
  late String message='';

  TextMessageInfo(sender, name, message, time) : super(sender,name,time);
}

class ImageMessageInfo extends BaseMessageInfo{
  late Image image;

  ImageMessageInfo(sender, name, image, time) :super(sender,name,time);
}

Stream<List<BaseMessageInfo>> messagesStream(roomId) {
  return _db
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('time')
      .snapshots()
      .asyncMap((messages) => Future.wait([for (var message in messages.docs) generateMessageInfo(message)]));
}

Future<BaseMessageInfo> generateMessageInfo(QueryDocumentSnapshot message) async {
  var doc = await _db.collection('users').doc(message.get('sender')).get();
  var name = await doc.get('name');
  var isImage=false;

  if(doc.data()?.containsKey('isImage') ?? false){
    isImage = await doc.get('isImage');
  }

  if(isImage){
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('images/1111/KZfDwzUJQ472TpsQjfJ9.jpeg');
    final String url = await ref.getDownloadURL();
    final image = new Image(image: new CachedNetworkImageProvider(url));
    return ImageMessageInfo(message.get('sender'),name,image,message.get('time'));
  }else{
    return TextMessageInfo(message.get('sender'),name,message.get('message'),message.get('time'));
  }

}

Future<String> getUserData(nowSender) async {
  var doc = await _db.collection('users').doc(nowSender).get();
  var name = await doc.get('name');
  return Future<String>.value(name);
}