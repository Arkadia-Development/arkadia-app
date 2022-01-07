import 'package:flutter/material.dart';
import 'cabinetrow.dart';

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
    for(var cabinet in GameCabinetListManager.cabinetList.entries){
      if(cabinet.key != null){
        cabinets.add(_buildRow(cabinet.key, cabinet.value));
        if(cabinet != GameCabinetListManager.cabinetList.entries.last){
          cabinets.add(Divider());
        }
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
    return CabinetRow(
      cabinet,
      working,
    );
  }
}

class GameCabinetListManager {
  GameCabinetListManager();

  //list of cabinets - to be replaced with an API call and a list of objects containing a name, image, and status
  static var cabinetList = <String, bool>{
    "Pacman" : false,
    "Mappy" : true
  };

  static Function updateListItem = (String cabinet){
    if(cabinetList.containsKey(cabinet)){
      cabinetList.update(cabinet, (val) => !val);
      return cabinetList[cabinet];
    }
  };
}
