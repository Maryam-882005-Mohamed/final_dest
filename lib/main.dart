import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'inputnames.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: NameInputPage(),
    debugShowCheckedModeBanner: false,
  ));
}
