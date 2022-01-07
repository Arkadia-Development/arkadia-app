import 'package:flutter/material.dart';

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
    var iconColor = cabinetIsWorking ? Colors.green[600] : Colors.red;
    String iconLabel = cabinetIsWorking ? "Working" : "Not Working";
    return Row(
      children: <Widget>[
        Expanded(
          flex: 9,
          child: Text(
            cabinetName,
            style: _biggerFont
          )
        ),
        Expanded(
          flex: 1,
          child: Icon(
            iconType,
            color: iconColor,
            size: 18.0,
            semanticLabel: iconLabel,
          )
        )
      ],
    );
  }
}