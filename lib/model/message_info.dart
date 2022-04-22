import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class TextMessageInfo extends BaseMessageInfo {
  late String message = '';

  TextMessageInfo(sender, name, message, time) : super(sender, name, time) {
    this.message = message;
  }
}

class ImageMessageInfo extends BaseMessageInfo {
  late Image image;

  ImageMessageInfo(sender, name, image, time) : super(sender, name, time) {
    this.image = image;
    print(image);
  }
}