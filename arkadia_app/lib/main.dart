import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkadia Administration',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameCabinet(),
    );
  }
}

class GameCabinet extends StatefulWidget {
  const GameCabinet() : super();

  @override
  _GameCabinetState createState() => _GameCabinetState();
}

class _GameCabinetState extends State<GameCabinet> {
  final List<String> _suggestions = ["Pacman", "Mappy"];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arkadia Administration")
      ),
      body: _buildSuggestions()
    );
  }

  Widget _buildSuggestions(){
    List<Widget> cabinets = new List<Widget>();
    for(int i = 0; i < _suggestions.length; i++){
      cabinets.add(_buildRow(_suggestions[i]));
      if(i != _suggestions.length - 1){
        cabinets.add(Divider());
      }
    }
    return ListView(
      children: cabinets,
      padding: EdgeInsets.all(16.0)
    );
  }

  Widget _buildRow(String cabinet){
    return ListTile(
      title: Text(
        cabinet,
        style: _biggerFont,
      ),
    );
  }
}
