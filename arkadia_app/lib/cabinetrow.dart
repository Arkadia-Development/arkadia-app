import 'package:flutter/material.dart';
import 'gamecabinets.dart';

class CabinetRow extends StatefulWidget {
  String cabinetName;
  bool cabinetIsWorking;
  CabinetRow(String name, bool isWorking){
    cabinetName = name;
    cabinetIsWorking = isWorking;
  }

  @override
  _CabinetRowState createState() => _CabinetRowState(cabinetName, cabinetIsWorking);
}

class _CabinetRowState extends State<CabinetRow> {
  String cabinetName;
  bool cabinetIsWorking;

  //text stylization
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  @override
  _CabinetRowState(String name, bool isWorking){
    cabinetName = name;
    cabinetIsWorking = isWorking;
  }

  @override
  Widget build(BuildContext context) {
    var iconType = cabinetIsWorking ? Icons.check : Icons.do_not_disturb_alt;
    var iconColor = cabinetIsWorking ? Colors.green[800] : Colors.red;
    String iconLabel = cabinetIsWorking ? "Working" : "Not Working";
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 85,
            child: Text(
              cabinetName,
              style: _biggerFont
            )
          ),
          Expanded(
            flex: 15,
            child: ElevatedButton(
              child: Icon(
                iconType,
                color: iconColor,
                size: 18.0,
                semanticLabel: iconLabel,
              ),
              onPressed: (){
                setState((){
                  cabinetIsWorking = GameCabinetListManager.updateListItem(cabinetName);
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white54)
              )
            )
          )
        ],
      ),
      width: 200
    );
  }
}