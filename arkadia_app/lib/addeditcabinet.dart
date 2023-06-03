import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:file_picker/file_picker.dart';
import 'gamecabinets.dart';
import 'cabinetrow.dart';
import 'secret.dart';

class AddEditCabinet extends StatefulWidget {
  Cabinet? editingCabinet;

  AddEditCabinet(Cabinet? cabinet) : super() {
    editingCabinet = cabinet;
  }

  @override
  _AddEditCabinetState createState() => _AddEditCabinetState(editingCabinet);
}

class _AddEditCabinetState extends State<AddEditCabinet> {
  bool cabinetIsNew = true;

  TextField title = TextField();
  TextEditingController _titleController = TextEditingController();
  TextField publisher = TextField();
  TextEditingController _publisherController = TextEditingController();
  bool isWorking = true;
  File? banner;

  _AddEditCabinetState(Cabinet? cabinet) : super() {
    if (cabinet != null) {
      cabinetIsNew = false;
      _titleController = new TextEditingController(text: cabinet.fullTitle);
      _publisherController = new TextEditingController(text: cabinet.searchTerms[cabinet.searchTerms.length - 1].toString());
      isWorking = cabinet.isWorking;
      banner = cabinet.banner;
    } else {
      cabinetIsNew = true;
      _titleController = new TextEditingController(text: '');
      _publisherController = new TextEditingController(text: '');
      isWorking = true;
    }
    title = TextField(controller: _titleController);
    publisher = TextField(controller: _publisherController);
  }

  @override
  Widget build(BuildContext context){
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
                (cabinetIsNew ? "add" : "edit") + " cabinet",
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
      body: Column(
        children: [
          SizedBox(width: 20, height: 20),
          Text('Game Title'),
          Row(
            children: [
              Expanded(flex: 5, child: SizedBox.shrink()),
              Expanded(flex: 90, child: title),
              Expanded(flex: 5, child: SizedBox.shrink())
            ],
          ),
          SizedBox(width: 20, height: 40),
          Text('Game Publisher (leave blank if unknown)'),
          Row(
            children: [
              Expanded(flex: 5, child: SizedBox.shrink()),
              Expanded(flex: 90, child: publisher),
              Expanded(flex: 5, child: SizedBox.shrink())
            ],
          ),
          SizedBox(width: 20, height: 40),
          Text('Currently working?'),
          ElevatedButton(
            onPressed: () { setState(() { isWorking = !isWorking; }); },
            child: Icon(
              isWorking ? Icons.check : Icons.do_not_disturb_alt,
              color: isWorking ? Colors.green[700] : Colors.red,
              size: 18.0,
              semanticLabel: isWorking ? "Working" : "Not Working",
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
            )
          ),
          SizedBox(width: 20, height: 40),
          Row(
            children: [
              Expanded(flex: 5, child: SizedBox.shrink()),
              Expanded(
                flex: 35,
                child: ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      banner = File(result.files.single.path ?? '');
                    } else {
                      banner = null;
                    }
                  },
                  child: Text(
                    (banner != null
                      ? "Replace banner"
                      : "Select banner")
                    + " (PNG files only)"
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white54)
                  )
                )
              ),
              Expanded(flex: 20, child: SizedBox.shrink()),
              Expanded(
                flex: 35,
                child: banner != null
                  ? Image.file(banner ?? File(''))
                  : Text("No image selected")
              ),
              Expanded(flex: 5, child: SizedBox.shrink())
            ],
          )
        ],
      )
    );
  }

  FutureBuilder _getUserFileFutureBuilder() {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot){
        print(snapshot);
        return Text("No image selected");
      },
      future: FilePicker.platform.pickFiles()
    );
  }
}

class CabinetFormManager {
  CabinetFormManager();

  static List<Cabinet> cabinetList = List<Cabinet>.empty(growable: true);
  static List<Cabinet> filteredCabinetList = List<Cabinet>.empty(growable: true);

  static Future<List<Cabinet>> getCabinetList() async {
    return await http.get(Uri.parse('http://192.168.1.70:8080/GetAllGameStatuses'))
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
          throw Exception("Failed to retrieve game statuses");
        }
        return cabinetList;
      });
  }

  static Future<bool> updateListItem(String cabinet) async {
    return await http.get(Uri.parse('http://192.168.1.70:8080/SwitchGameStatus?id=' + cabinet + '&secret=' + Secrets.updateSecret))
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

    List<bool> containsParams = new List<bool>.filled(params.length, false);
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
