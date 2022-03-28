import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _db = FirebaseFirestore.instance;

String createRandomIDString() {
  var rand = Random();
  int num = (rand.nextDouble() * 10000).toInt();
  return num.toString().padLeft(4, "0");
}

Future<void> _createRoomWithNewRoomID() async {

}

class RoomID extends StatefulWidget {
  const RoomID({Key? key}) : super(key: key);

  @override
  RoomIDState createState() => RoomIDState();
}

class RoomIDState extends State<RoomID> {
  // 入力されたルームID
  String newRoomID = "";

  // 登録に関する情報を表示
  String infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              Text(infoText),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                maxLines: 1,
                // テキスト入力のラベルを設定
                decoration: const InputDecoration(labelText: "ルームID"),
                onChanged: (String value) {
                  setState(() {
                    newRoomID = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newRoomID.length != 4) {
                    setState(() {
                      infoText = "4桁入力してください";
                    });
                  } else {
                    setState(() {
                      infoText = "";
                    });

                    final snap = await _db
                        .collection('rooms')
                        .doc(newRoomID)
                        .get();

                    if (snap.exists) {
                      Navigator.pushNamed(context, 'chat',
                          arguments: {'RoomID': newRoomID});
                    } else {
                      setState(() {
                        infoText = "ルームが存在しません";
                      });
                    }
                  }
                },
                child: const Text("ルームに入る"),
              ),
              const SizedBox(height: 30),
              const Text('もしくは'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green
                ),
                onPressed: () async{
                  var randomRoomID = createRandomIDString();
                  await _db.collection('rooms').doc(randomRoomID).get().then((DocumentSnapshot<Map<String, dynamic>> value) async {
                    if (value.exists) {
                      _createRoomWithNewRoomID();
                    } else {
                      setState(() {
                        newRoomID = randomRoomID;
                      });
                      await _db.collection('rooms').doc(randomRoomID).set({});
                      Navigator.pushNamed(context, 'chat',
                          arguments: {'RoomID': newRoomID});
                    }
                  });
                },
                child: const Text("ルームを作る"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
