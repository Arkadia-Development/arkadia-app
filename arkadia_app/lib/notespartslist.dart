import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class NotesPartsList extends StatefulWidget {
  String? notes;
  List<String>? parts = [];
  final Function(String notes, List<String> parts) notifyParent;

  NotesPartsList(String? notes, List<String>? parts, this.notifyParent) : super() {
    this.notes = notes;
    this.parts = parts;
  }

  @override
  _NotesPartsListState createState() => _NotesPartsListState(notes, parts, notifyParent);
}

class _NotesPartsListState extends State<NotesPartsList> {
  String notes = '';
  TextField notesField = TextField();
  TextEditingController _notesController = TextEditingController();
  List<String> parts = [];
  List<TextField> partsFields = [];
  List<TextEditingController> _partsControllers = [];
  final Function(String notes, List<String> parts) notifyParent;

  _NotesPartsListState(String? notes, List<String>? parts, this.notifyParent) : super() {
    if (notes != null) {
      this.notes = notes;
    }
    _notesController = new TextEditingController(text: this.notes);
    notesField = TextField(
      controller: _notesController,
      onChanged: (value) {
        setState(() {
          this.notes = value;
          notifyParent(this.notes, this.parts);
        });
      },
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5      
    );

    if (parts != null) {
      this.parts = parts;
    }
    for (var i = 0; i < this.parts.length; i++) {
      _partsControllers.add(new TextEditingController(text: this.parts[i]));
      partsFields.add(
        TextField(
          controller: _partsControllers[i],
          onChanged: (value) {
            setState(() {
              this.parts[i] = value;
              notifyParent(this.notes, this.parts);
            });
          }
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'cabinet notes',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: 20, height: 20),
            Text('Notes'),
            Row(
              children: [
                Expanded(flex: 5, child: SizedBox.shrink()),
                Expanded(flex: 90, child: notesField),
                Expanded(flex: 5, child: SizedBox.shrink())
              ],
            ),
            SizedBox(width: 20, height: 20),
            Row(
              children: [
                Expanded(flex: 35, child: SizedBox.shrink()),
                Expanded(flex: 20, child: Text('Parts List')),
                Expanded(
                  flex: 10,
                  child: ElevatedButton(
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18.0,
                      semanticLabel: 'Edit',
                    ),
                    onPressed: () {
                      setState(() {
                        parts.add('');
                        int ind = parts.length - 1;
                        _partsControllers.add(new TextEditingController(text: parts[ind]));
                        partsFields.add(
                          TextField(
                            controller: _partsControllers[ind],
                            onChanged: (value) {
                              setState(() { parts[ind] = value; });
                            }
                          )
                        );
                      });
                      notifyParent(notes, parts);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white54),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
                    )
                  )
                ),
                Expanded(flex: 35, child: SizedBox.shrink())
              ],
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: parts.length,
              itemBuilder: (BuildContext context, int ind) {
                return Row(
                  children: [
                    Expanded(flex: 5, child: SizedBox.shrink()),
                    Expanded(flex: 75, child: partsFields[ind]),
                    Expanded(flex: 5, child: SizedBox.shrink()),
                    Expanded(
                      flex: 10,
                      child: ElevatedButton(
                        child: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.white,
                          size: 18.0,
                          semanticLabel: 'Delete Row'
                        ),
                        onPressed: () {
                          setState(() {
                            parts.removeAt(ind);
                            _partsControllers.removeAt(ind);
                            partsFields.removeAt(ind);
                          });
                          notifyParent(notes, parts);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)
                        )
                      )
                    ),
                    Expanded(flex: 5, child: SizedBox.shrink())
                  ],
                );
              }
            )
          ],
        )
      )
    );
  }
}
