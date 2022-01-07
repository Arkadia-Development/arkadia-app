import 'dart:io';

import 'package:flutter/material.dart';
import 'cabinetrow.dart';

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
      //everything inside of this ThemeData object were auto-generated and the comments may be useful later
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.indigo[800],
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //set "home" point as a GameCabinets widget, shown below
      home: GameCabinets(),
    );
  }
}

//end of default app building stuff
///////////////////////////////////////////////////////////////////
//beginning of important GameCabinets widget stuff

//stateful widget nesting within main stateless widget
class GameCabinets extends StatefulWidget {
  //super simple constructor; by default had Key parameters but idk what that is yet
  const GameCabinets() : super();

  //oh you want your stateful widget to do something? cool, create a state for it
  @override
  _GameCabinetsState createState() => _GameCabinetsState();
}

//you rang?
//an underscore at the beginning of a name forces it to be private in dart
class _GameCabinetsState extends State<GameCabinets> {
  //list of cabinets - to be replaced with an API call and a list of objects containing a name, image, and status
  var _cabinetList = {
    "Pacman" : false,
    "Mappy" : true
  };

  //default build constructor
  @override
  Widget build(BuildContext context){
    //returns a scaffold object, which is like a whole screen structure
    return Scaffold(
      appBar: AppBar(
        title: Center(
          heightFactor: 1.0,
          child: Column(
            children: [
              Image.asset(
                "assets\\arkadia_logo_raw.png",
                height: 30
              ),
              Text(
                "administration",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Comic Sans MS",
                  fontSize: 12
                )
              )
            ],
          ),
        )
      ),
      //grabs the widget for the body from this _buildCabinets function
      body: _buildCabinets()
    );
  }

  // function to build the widget that contains the cabinet row objects
  Widget _buildCabinets(){
    //default logic as you'd see in other languages to build a list of widgets based on the list of strings we had earlier
    List<Widget> cabinets = new List<Widget>();
    for(var cabinet in _cabinetList.entries){
      cabinets.add(_buildRow(cabinet.key, cabinet.value));
      if(cabinet != _cabinetList.entries.last){
        cabinets.add(Divider());
      }
    }
    //return a ListView object that contains all those widgets just built
    return ListView(
      children: cabinets,
      padding: EdgeInsets.all(16.0)
    );
  }

  //function to build a single row widget from a string - again, will need changed when each row has more than a string in it
  Widget _buildRow(String cabinet, bool working){
    return ListTile(
      title: CabinetRow(
        cabinet,
        working
      ),
    );
  }
}
