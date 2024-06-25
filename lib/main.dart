import 'package:flutter/material.dart';
import 'package:polygonic/screens/New/trckker.dart';
import 'package:polygonic/screens/form_example.dart';
import 'package:polygonic/screens/home_screen.dart';
import 'package:polygonic/screens/test_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Scaffold(
        body: GardenMap(),
      ),
    );
  }
}
