import 'dart:io';

import 'package:flutter/material.dart';
import 'gamecabinets.dart';

//main runs by default as in most languages
void main() {
  //builds and runs "ArkadiaAdministrationApp" class below
  runApp(ArkadiaAdministrationApp());
}

//main app class - a stateless widget is one that doesn't change and doesn't need much interaction, but they can hold stateful
//  widgets (which are the opposite) so it's fine as a baseline widget
class ArkadiaAdministrationApp extends StatelessWidget {
  //build function returns the bottom level widget for the app - everything that shows on the screen is a widget basically
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkadia Administration',
      //everything inside of this ThemeData object was auto-generated and the comments may be useful later
      // theme: ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // Try running your application with "flutter run". You'll see the
      //   // application has a blue toolbar. Then, without quitting the app, try
      //   // changing the primarySwatch below to Colors.green and then invoke
      //   // "hot reload" (press "r" in the console where you ran "flutter run",
      //   // or simply save your changes to "hot reload" in a Flutter IDE).
      //   // Notice that the counter didn't reset back to zero; the application
      //   // is not restarted.
      //   primaryColor: Colors.indigo[800],
      //   // This makes the visual density adapt to the platform that you run
      //   // the app on. For desktop platforms, the controls will be smaller and
      //   // closer together (more dense) than on mobile platforms.
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      theme: ThemeData
          .dark(), //dark theme data, will synch based on system settings
      //set "home" point as a GameCabinets widget, shown below
      home: GameCabinets(),
    );
  }
}
