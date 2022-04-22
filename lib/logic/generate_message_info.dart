import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterchat2/model/message_info.dart';
import 'package:firebase_storage/firebase_storage.dart';


Future<BaseMessageInfo> generateMessageInfo(
    QueryDocumentSnapshot<Map<String, dynamic>> message) async {
  final _db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  var doc = await _db.collection('users').doc(message.get('sender')).get();
  var name = await doc.get('name');
  bool? isImage = false;

  if (message.data().containsKey('isImage')) {
    isImage = await message.get('isImage');
  }

  if (isImage != null && isImage == true) {
    final ref = storage.ref('images/1111/Xvfbkt5c8TNR85PRQhMS');
    final String url = await ref.getDownloadURL();

    final image = new Image(image: new CachedNetworkImageProvider(url),width: 70,);

    return ImageMessageInfo(
        message.get('sender'), name, image, message.get('time'));
  } else {
    return TextMessageInfo(message.get('sender'), name, message.get('message'),
        message.get('time'));
  }
}