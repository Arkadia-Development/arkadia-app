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
  TextField searchBar;
  List<Cabinet> displayCabs = new List<Cabinet>();

  //default build constructor
  @override
  Widget build(BuildContext context){
    searchBar = TextField(
      onChanged: (String val) {
        setState((){
          GameCabinetListManager.searchCabinetList(val);
        });
      },
    );

    Widget mainWidget = _buildCabinets();

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
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                SizedBox(
                  width: 10,
                  height: 20
                ),
                Icon(Icons.search),
                SizedBox(
                  width: 10,
                  height: 20
                ),
                Expanded(
                  child: searchBar
                ),
                SizedBox(
                  width: 20,
                  height: 20
                )
              ],
            ),
            Expanded(
              child: mainWidget
            ,)
          ],
          mainAxisSize: MainAxisSize.max,
        ),
      ),
    );
  }

  // function to build the widget that contains the cabinet row objects
  Widget _buildCabinets() {
    //return a FutureBuilder object that contains all the cabinet info
    bool hasData = GameCabinetListManager.filteredCabinetList != null;
    displayCabs = hasData ? GameCabinetListManager.filteredCabinetList : null;
    return hasData ? _buildRowsFromExistingCabinets() : _getFutureBuilder();
  }

  FutureBuilder _getFutureBuilder(){
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator()
          );
        } else if(snapshot.hasData){
          displayCabs = GameCabinetListManager.filteredCabinetList;
          return ListView.builder(
            itemCount: displayCabs.length,
            itemBuilder: (BuildContext context, int ind){
              return _buildRow(displayCabs[ind].id, displayCabs[ind].fullTitle, displayCabs[ind].isWorking);
            },
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

  Widget _buildRowsFromExistingCabinets(){
    displayCabs = GameCabinetListManager.filteredCabinetList;
    if(displayCabs.isEmpty){
      return Center(
        child: Text(
          "No cabinets found"
        )
      );
    }
    return ListView.builder(
      key: ValueKey(displayCabs),
      itemCount: displayCabs.length,
      itemBuilder: (BuildContext context, int ind){
        Widget item = _buildRow(displayCabs[ind].id, displayCabs[ind].fullTitle, displayCabs[ind].isWorking);
        return item;
      },
      padding: EdgeInsets.all(16.0)
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
  static List<Cabinet> filteredCabinetList;

  static Future<List<Cabinet>> getCabinetList() async {
    return await http.get(Uri.parse('https://arkadia-site-api.herokuapp.com/GetAllGameStatuses'))
      .then((Response response) {
        if(response.statusCode == 200){
          List<Cabinet> list = List<Cabinet>();
          for(var cab in jsonDecode(response.body)){
            list.add(Cabinet.fromJson(cab));
          }
          list.sort((a, b) => a.fullTitle.compareTo(b.fullTitle));
          cabinetList = list;
          filteredCabinetList = list;
        }
        else{
          throw Exception("Failed to retrieve game statuses");
        }
        return cabinetList;
      });
  }

  static Future<bool> updateListItem(String cabinet) async {
    return await http.get(Uri.parse('https://arkadia-site-api.herokuapp.com/SwitchGameStatus?id=' + cabinet + '&secret=' + Secrets.updateSecret))
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

  static List<Cabinet> searchCabinetList(String param){
    List<String> params = param.split(" ");
    for(int i = 0; i < params.length; i++) params[i] = params[i].replaceAll(RegExp("[^A-Za-z0-9]"), "");
    while(params.remove(""));
    filteredCabinetList = new List<Cabinet>.from(cabinetList);
    if(params.isEmpty) return filteredCabinetList;

    List<bool> containsParams = new List<bool>(params.length);
    for(Cabinet cab in cabinetList){
      for(int i = 0; i < containsParams.length; i++) containsParams[i] = false;
      for(int j = 0; j < params.length; j++){
        for(String term in cab.searchTerms){
          if(term.contains(params[j].toLowerCase())){
            containsParams[j] = true;
          }
        }
      }
      if(!containsParams.every((element) => element)) filteredCabinetList.remove(cab);
    }

    return filteredCabinetList;
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
