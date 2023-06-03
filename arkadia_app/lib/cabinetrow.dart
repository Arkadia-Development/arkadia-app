import 'package:flutter/material.dart';
import 'gamecabinets.dart';

class CabinetRow extends StatefulWidget {
  String cabinetId;
  String cabinetName;
  bool cabinetIsWorking;
  CabinetRow(String id, String name, bool isWorking){
    cabinetId = id;
    cabinetName = name;
    cabinetIsWorking = isWorking;
  }

  @override
  _CabinetRowState createState() => _CabinetRowState(cabinetId, cabinetName, cabinetIsWorking);
}

class _CabinetRowState extends State<CabinetRow> {
  String cabinetId;
  String cabinetName;
  bool cabinetIsWorking;

  //text stylization
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  @override
  _CabinetRowState(String id, String name, bool isWorking){
    cabinetId = id;
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
            flex: 70,
            child: Text(
              cabinetName,
              style: _biggerFont
            )
          ),
          Expanded(flex: 5, child: SizedBox.shrink()),
          Expanded(
            flex: 10,
            child: ElevatedButton(
              child: Icon(
                Icons.edit,
                color: Colors.black,
                size: 18.0,
                semanticLabel: "Edit",
              ),
              onPressed: () async {
                cabinetIsWorking = await GameCabinetListManager.updateListItem(cabinetId)
                  .then((bool works){
                    setState(() {
                      iconType = works ? Icons.check : Icons.do_not_disturb_alt;
                      iconColor = works ? Colors.green[600] : Colors.red;
                    });
                    return works;
                  });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
              )
            )
          ),
          Expanded(flex: 5, child: SizedBox.shrink()),
          Expanded(
            flex: 10,
            child: ElevatedButton(
              child: Icon(
                iconType,
                color: iconColor,
                size: 18.0,
                semanticLabel: iconLabel,
              ),
              onPressed: () async {
                cabinetIsWorking = await GameCabinetListManager.updateListItem(cabinetId)
                  .then((bool works){
                    setState(() {
                      iconType = works ? Icons.check : Icons.do_not_disturb_alt;
                      iconColor = works ? Colors.green[600] : Colors.red;
                    });
                    return works;
                  });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
              )
            )
          )
        ],
      ),
      width: 200
    );
  }
}