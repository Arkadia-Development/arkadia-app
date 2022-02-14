import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'cabinetrow.dart';
import 'secret.dart';

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
                "assets/arkadia_logo_raw.png",
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
  Widget _buildCabinets() {
    //return a FutureBuilder object that contains all the cabinet info
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator()
          );
        } else if(snapshot.hasData){
          List<Widget> cabinets = new List<Widget>();
          for(var cabinet in GameCabinetListManager.cabinetList){
            if(cabinet.id != null){
              cabinets.add(_buildRow(cabinet.id, cabinet.fullTitle, cabinet.isWorking));
              if(cabinet != GameCabinetListManager.cabinetList[GameCabinetListManager.cabinetList.length - 1]){
                cabinets.add(Divider());
              }
            }
          }
          return ListView(
            children: cabinets,
            padding: EdgeInsets.all(16.0)
          );
        } else if(snapshot.hasError){
          return Text("ERROR: ${snapshot.error}");
        } else{
          return Text("No data");
        }
      },
      future: GameCabinetListManager.getCabinetList()
    );
  }

  //function to build a single row widget from a string and bool
  Widget _buildRow(String id, String name, bool working){
    return CabinetRow(
      id,
      name,
      working,
    );
  }
}

class GameCabinetListManager {
  GameCabinetListManager();

  static List<Cabinet> cabinetList;
  static Future<List<Cabinet>> getCabinetList() async {
    return await http.get(Uri.parse('http://localhost:8080/GetAllGameStatuses'))
      .then((Response response) {
        if(response.statusCode == 200){
          List<Cabinet> list = List<Cabinet>();
          for(var cab in jsonDecode(response.body)){
            list.add(Cabinet.fromJson(cab));
          }
          list.sort((a, b) => a.fullTitle.compareTo(b.fullTitle));
          cabinetList = list;
        }
        else{
          throw Exception("Failed to retrieve game statuses");
        }
        return cabinetList;
      });
  }

  static Future<bool> updateListItem(String cabinet) async {
    return await http.get(Uri.parse('http://localhost:8080/SwitchGameStatus?id=' + cabinet + '&secret=' + Secrets.updateSecret))
      .then((Response response) async {
        return await getCabinetList()
          .then((List<Cabinet> list){
            for(var cab in list){
              if(cab.id == cabinet){
                return cab.isWorking;
              }
            }
            return false;
          });
      });
  }
}

class Cabinet {
  String id;
  String fullTitle;
  bool isWorking;
  List<dynamic> searchTerms;

  Cabinet(String id, String fullTitle, bool isWorking, List<dynamic> searchTerms){
    this.id = id;
    this.fullTitle = fullTitle;
    this.isWorking = isWorking;
    List<String> termlist = List<String>();
    for(String s in searchTerms){
      termlist.add(s);
    }
    this.searchTerms = termlist;
  }

  factory Cabinet.fromJson(Map<String, dynamic> json){
    return Cabinet(json['id'], json['fullTitle'], json['isWorking'],json['searchTerms']);
  }
}
