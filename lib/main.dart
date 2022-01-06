import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './view/register.dart';
import './view/top.dart';
import './view/chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(), //ダークテーマ
        initialRoute: 'top',
        routes: {
          'top': (context) => const Top(),
          'register': (context) => const Register(),
          'chat': (context) => const Chat()
        });
  }
}
