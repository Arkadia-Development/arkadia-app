import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'cabinetrow.dart';
import 'secret.dart';
import 'addeditcabinet.dart';

//stateful widget nesting within main stateless widget
class GameCabinets extends StatefulWidget {
  //super simple constructor
  const GameCabinets() : super();

  //oh you want your stateful widget to do something? cool, create a state for it
  @override
  _GameCabinetsState createState() => _GameCabinetsState();
}

//you rang?
//an underscore at the beginning of a name forces it to be private in dart
class _GameCabinetsState extends State<GameCabinets> {
  TextField searchBar = TextField();
  List<Cabinet>? displayCabs = new List<Cabinet>.empty(growable: true);
  Widget mainWidget = Text('');
  TextEditingController defaultController = TextEditingController(text: '');

  //default build constructor
  @override
  Widget build(BuildContext context){
    searchBar = TextField(
      onChanged: (String val) {
        setState((){
          GameCabinetListManager.searchCabinetList(val);
        });
      },
      controller: searchBar.controller ?? defaultController
    );

    void stateSetter () {
      GameCabinetListManager.filteredCabinetList = List.empty();
      searchBar.controller?.text = '';
      setState(() { mainWidget = _buildCabinets(stateSetter); });
    };

    mainWidget = _buildCabinets(stateSetter);

    //returns a scaffold object, which is like a whole screen structure
    return Scaffold(
      appBar: AppBar(
        title: Center(
          heightFactor: 1.0,
          child: Column(
            children: [
              Image.asset(
                'assets/arkadia_logo_raw.png',
                height: 30
              ),
              Text(
                'administration',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Comic Sans MS',
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
                  width: 10,
                  height: 20
                ),
                SizedBox(
                  width: 35,
                  height: 35,
                  child: ElevatedButton(
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18.0,
                      semanticLabel: 'Add cabinet',
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEditCabinet(null))
                      ).then((_) {
                        stateSetter();
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
                    )
                  ),
                ),
                SizedBox(
                  width: 10,
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
  Widget _buildCabinets(stateSetter) {
    //return a FutureBuilder object that contains all the cabinet info
    bool hasData = !GameCabinetListManager.filteredCabinetList.isEmpty;
    displayCabs = hasData ? GameCabinetListManager.filteredCabinetList : null;
    return hasData ? _buildRowsFromExistingCabinets(stateSetter) : _getFutureBuilder(stateSetter);
  }

  FutureBuilder _getFutureBuilder(stateSetter){
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator()
          );
        } else if(snapshot.hasData){
          displayCabs = GameCabinetListManager.filteredCabinetList;
          return ListView.builder(
            itemCount: displayCabs?.length,
            itemBuilder: (BuildContext context, int ind){
              return _buildRow(displayCabs?[ind] ?? Cabinet('', '', '', true, [], null, null, null), stateSetter);
            },
            padding: EdgeInsets.all(16.0)
          );
        } else if(snapshot.hasError){
          return Text('ERROR: ${snapshot.error}');
        } else{
          return Text('No data');
        }
      },
      future: GameCabinetListManager.getCabinetList()
    );
  }

  Widget _buildRowsFromExistingCabinets(stateSetter){
    displayCabs = GameCabinetListManager.filteredCabinetList;
    if(displayCabs == null || (displayCabs?.isEmpty ?? true)){
      return Center(
        child: Text(
          'No cabinets found'
        )
      );
    }
    return ListView.builder(
      key: ValueKey(displayCabs),
      itemCount: displayCabs?.length,
      itemBuilder: (BuildContext context, int ind){
        Widget item = _buildRow(displayCabs?[ind] ?? Cabinet('', '', '', true, [], null, null, null), stateSetter);
        return item;
      },
      padding: EdgeInsets.all(16.0)
    ); 
  }

  //function to build a single row widget from a string and bool
  Widget _buildRow(Cabinet cabinet, stateSetter){
    return CabinetRow(cabinet, stateSetter);
  }
}

class GameCabinetListManager {
  GameCabinetListManager();

  static List<Cabinet> cabinetList = List<Cabinet>.empty(growable: true);
  static List<Cabinet> filteredCabinetList = List<Cabinet>.empty(growable: true);

  static Future<List<Cabinet>> getCabinetList() async {
    return await http.get(Uri.parse(Secrets.host + '/GetAllGameStatuses'))
      .then((Response response) {
        if(response.statusCode == 200){
          List<Cabinet> list = List<Cabinet>.empty(growable: true);
          for(var cab in jsonDecode(response.body)){
            list.add(Cabinet.fromJson(cab));
          }
          list.sort((a, b) => a.fullTitle.compareTo(b.fullTitle));
          cabinetList = list;
          filteredCabinetList = list;
        }
        else{
          throw Exception('Failed to retrieve game statuses');
        }
        return cabinetList;
      });
  }

  static Future<bool> updateListItem(String cabinet) async {
    return await http.get(Uri.parse(Secrets.host + '/SwitchGameStatus?id=' + cabinet + '&secret=' + Secrets.updateSecret))
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
    List<String> params = param.split(' ');
    for(int i = 0; i < params.length; i++) params[i] = params[i].replaceAll(RegExp('[^A-Za-z0-9]'), '');
    while(params.remove(''));
    filteredCabinetList = new List<Cabinet>.from(cabinetList);
    if(params.isEmpty) return filteredCabinetList;

    List<bool> containsParams = new List<bool>.filled(params.length, false);
    for(Cabinet cab in cabinetList){
      for(int i = 0; i < params.length; i++){
        for(String term in cab.searchTerms){
          if(term.contains(params[i].toLowerCase())){
            containsParams[i] = true;
          }
        }
      }
      if(!containsParams.every((element) => element)) {
        filteredCabinetList.removeAt(filteredCabinetList.indexWhere((cabinet) => cabinet.id == cab.id));
      }
      containsParams = new List<bool>.filled(params.length, false);
    }

    return filteredCabinetList;
  }
}

class Cabinet {
  String mongoId = '';
  String id = '';
  String fullTitle = '';
  bool isWorking = true;
  List<dynamic> searchTerms = List<String>.empty(growable: true);
  Image? banner;
  String? bannerSrc;
  String? notes;
  List<String>? parts = [];

  Cabinet(String mongoId, String id, String fullTitle, bool isWorking, List<dynamic> searchTerms, String? banner, String? notes, List<dynamic>? parts){
    this.mongoId = mongoId;
    this.id = id;
    this.fullTitle = fullTitle;
    this.isWorking = isWorking;
    List<String> termlist = List<String>.empty(growable: true);
    for(String s in searchTerms){
      termlist.add(s);
    }
    this.searchTerms = termlist;
    if (banner != null) {
      this.banner = Image.memory(base64Decode(banner));
      this.bannerSrc = banner;
    }
    this.notes = notes;
    List<String> partsList = List<String>.empty(growable: true);
    for (String p in (parts ?? [])) {
      partsList.add(p);
    }
    this.parts = partsList;
  }

  factory Cabinet.fromJson(Map<String, dynamic> json){
    return Cabinet(json['mongoId'], json['id'], json['fullTitle'], json['isWorking'], json['searchTerms'], json['banner'], json['notes'], json['parts']);
  }
}
