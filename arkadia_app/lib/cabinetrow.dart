import 'package:flutter/material.dart';
import 'gamecabinets.dart';
import 'addeditcabinet.dart';

class CabinetRow extends StatefulWidget {
  Cabinet cabinet = Cabinet('', '', true, []);
  final void Function() stateSetter;

  CabinetRow(Cabinet givenCabinet, this.stateSetter){
    cabinet = givenCabinet;
  }

  @override
  _CabinetRowState createState() => _CabinetRowState(cabinet, stateSetter);
}

class _CabinetRowState extends State<CabinetRow> {
  String cabinetId = '';
  String cabinetName = '';
  bool cabinetIsWorking = true;
  Cabinet rawCabinet = Cabinet('', '', true, []);
  final void Function() stateSetter;

  //text stylization
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  @override
  _CabinetRowState(Cabinet cabinet, this.stateSetter){
    cabinetId = cabinet.id;
    cabinetName = cabinet.fullTitle;
    cabinetIsWorking = cabinet.isWorking;
    rawCabinet = cabinet;
  }

  @override
  Widget build(BuildContext context) {
    var iconType = cabinetIsWorking ? Icons.check : Icons.do_not_disturb_alt;
    var iconColor = cabinetIsWorking ? Colors.green[700] : Colors.red;
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditCabinet(rawCabinet))
                ).then((_) {
                  stateSetter.call();
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
                      iconColor = works ? Colors.green[700] : Colors.red;
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