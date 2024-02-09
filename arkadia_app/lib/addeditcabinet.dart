import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'gamecabinets.dart';
import 'notespartslist.dart';
import 'secret.dart';

// ignore: must_be_immutable
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
  String originalId = '';
  String deleteButtonText = 'DELETE CABINET';

  String mongoId = '';
  String title = '';
  TextField titleField = TextField();
  TextEditingController _titleController = TextEditingController();
  String publisher = '';
  TextField publisherField = TextField();
  TextEditingController _publisherController = TextEditingController();
  bool isWorking = true;
  Image? banner;
  String? bannerPath;
  String? banner64Src;
  String? notes;
  List<String>? parts = [];

  _AddEditCabinetState(Cabinet? cabinet) : super() {
    if (cabinet != null) {
      cabinetIsNew = false;
      mongoId = cabinet.mongoId;
      originalId = cabinet.id;

      title = cabinet.fullTitle;
      _titleController = new TextEditingController(text: cabinet.fullTitle);

      String lastTerm = !cabinet.searchTerms.isEmpty
        ? cabinet.searchTerms[cabinet.searchTerms.length - 1].toString()
        : '';
      publisher = lastTerm;
      _publisherController = new TextEditingController(text: lastTerm);

      isWorking = cabinet.isWorking;
      banner = cabinet.banner;
      banner64Src = cabinet.bannerSrc;
      notes = cabinet.notes;
      parts = cabinet.parts;
    } else {
      cabinetIsNew = true;
      _titleController = new TextEditingController(text: '');
      _publisherController = new TextEditingController(text: '');
      isWorking = true;
    }
    titleField = TextField(
      controller: _titleController,
      onChanged: (value) {
        setState(() { title = value; });
      }
    );
    publisherField = TextField(
      controller: _publisherController,
      onChanged: (value) {
        setState(() { publisher = value; });
      }
    );
  }

  void setNotesAndParts(String notes, List<String> parts) {
    setState(() {
      this.notes = notes;
      this.parts = parts;
    });
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
                'assets/arkadia_logo_raw.png',
                height: 30
              ),
              Text(
                (cabinetIsNew ? 'add' : 'edit') + ' cabinet',
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
      body:
      SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: 20, height: 20),
            Text('Game Title'),
            Row(
              children: [
                Expanded(flex: 5, child: SizedBox.shrink()),
                Expanded(flex: 90, child: titleField),
                Expanded(flex: 5, child: SizedBox.shrink())
              ],
            ),
            SizedBox(width: 20, height: 40),
            Text('Game Publisher (leave blank if unknown)'),
            Row(
              children: [
                Expanded(flex: 5, child: SizedBox.shrink()),
                Expanded(flex: 90, child: publisherField),
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
                semanticLabel: isWorking ? 'Working' : 'Not Working',
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
              )
            ),
            SizedBox(width: 20, height: 40),
            Row(
              children: [
                Expanded(flex: 25, child: SizedBox.shrink()),
                Expanded(
                  flex: 40,
                  child: Text('Notes and Parts List')
                ),
                Expanded(
                  flex: 10,
                  child: ElevatedButton(
                    child: Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 18.0,
                      semanticLabel: 'Edit',
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotesPartsList(notes, parts, setNotesAndParts))
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
                    )
                  )
                ),
                Expanded(flex: 25, child: SizedBox.shrink())
              ]
            ),
            SizedBox(width: 20, height: 40),
            Row(
              children: [
                Expanded(flex: 5, child: SizedBox.shrink()),
                Expanded(
                  flex: 35,
                  child: ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null) {
                        setState(() {
                          banner = Image.file(File(result.files.single.path ?? ''));
                          bannerPath = result.files.single.path;  
                        });
                      } else {
                        setState(() { banner = null; bannerPath = null; banner64Src = null; });
                      }
                    },
                    child: Text(
                      (banner != null
                        ? 'Replace banner'
                        : 'Select banner')
                      + ' (PNG files only)'
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
                    ? banner ?? Text('Image error')
                    : Text('No image selected')
                ),
                Expanded(flex: 5, child: SizedBox.shrink())
              ],
            ),
            SizedBox(width: 20, height: 40),
            ElevatedButton(
              onPressed: () async {
                List<String> searchTerms = List<String>.empty(growable: true);
                String lowerCaseTitle = title.replaceAll(RegExp(r'[^0-9a-z\s]', caseSensitive: false), ' ').toLowerCase();
                searchTerms.add(lowerCaseTitle.replaceAll(RegExp(r'\s'), ''));
                lowerCaseTitle.split(' ').forEach((el) { searchTerms.add(el); });
                searchTerms.add(publisher.replaceAll(RegExp(r'[^0-9a-z\s]', caseSensitive: false), ' ').toLowerCase());

                Uint8List bannerBytes = bannerPath != null
                  ? await File(bannerPath ?? '').readAsBytes()
                  : Uint8List.fromList([]);

                var gameStatus = json.encode({
                  'mongoId': mongoId,
                  'id': cabinetIsNew ? searchTerms[0] : originalId,
                  'fullTitle': title,
                  'isWorking': isWorking,
                  'searchTerms': searchTerms,
                  'banner': !bannerBytes.isEmpty
                    ? base64.encode(bannerBytes)
                    : banner64Src,
                  'notes': notes,
                  'parts': parts
                });

                if (cabinetIsNew) {
                  await http.post(
                    Uri.parse(Secrets.host + '/AddGameStatus?secret=' + Secrets.updateSecret),
                    headers: {
                      'content-type': 'application/json'
                    },
                    body: gameStatus
                  ).then((Response response) {
                      if (response.statusCode == 200) {
                        Fluttertoast.showToast(
                          msg: 'Cabinet added successfully!'
                        );
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(msg: 'Failed to add cabinet (HTTP status ' + response.statusCode.toString() + ')');
                      }
                    });
                } else {
                  await http.put(
                    Uri.parse(Secrets.host + '/UpdateGameStatus?secret=' + Secrets.updateSecret),
                    headers: {
                      'content-type': 'application/json'
                    },
                    body: gameStatus
                  ).then((Response response) {
                    if (response.statusCode == 200) {
                        Fluttertoast.showToast(
                          msg: 'Cabinet updated successfully!'
                        );
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Failed to update cabinet (HTTP status ' + response.statusCode.toString() + ')'
                        );
                      }
                  });
                }
              },
              child: Text((cabinetIsNew ? 'Add' : 'Update') + ' Cabinet'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white54)
              )
            ),
            SizedBox(width: 20, height: 80),
            cabinetIsNew ? SizedBox(width: 20, height: 20) : ElevatedButton(
              onPressed: () async {
                if (deleteButtonText == 'DELETE CABINET') {
                  setState(() { deleteButtonText = 'TAP AGAIN TO CONFIRM'; });
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    setState(() { deleteButtonText = 'DELETE CABINET'; });
                  });
                } else {
                  await http.delete(
                    Uri.parse(Secrets.host + '/DeleteGameStatus?id=' + originalId + '&secret=' + Secrets.updateSecret)
                  ).then((Response response) {
                    if (response.statusCode == 200) {
                      Fluttertoast.showToast(
                        msg: 'Cabinet deleted successfully'
                      );
                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Failed to delete cabinet (HTTP status ' + response.statusCode.toString() + ')'
                      );
                    }
                  });
                }
              },
              child: Text(deleteButtonText),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade700)
              )
            )
          ],
        )
      )
    );
  }
}
