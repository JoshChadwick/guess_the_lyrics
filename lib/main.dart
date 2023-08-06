// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class SongStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/TS/counter.txt');
  }

  Future<String> readSong() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "e";
    }
  }

  Future<File> writeSong(String counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(counter);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlayPage(storage: SongStorage())),
                  );
                },
                child: Text("Play"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PlayPage extends StatefulWidget {
  const PlayPage({super.key, required this.storage});
  final SongStorage storage;

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  final TextEditingController _controller = TextEditingController();

  List<String> song = [];
  List<String> displayLines = [];
  List<String> words = [];
  List<String> lines = [];
  String guess = "";

  void initState() {
    super.initState();

    widget.storage.readSong().then((value) {
      lines = processLyrics(value);
      displayLines = getDisplayLines(lines);
      words = getWords(lines);
      print(words);
      _controller.addListener(checkGuess);

      setState(() {
        song = displayLines;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool linearSearch(List<String> list, String word) {
    bool result=false;
    for (var i = 0; i < list.length; i++) {
      if (list[i].toUpperCase() == word.toUpperCase()) {
        result= true;
      }
    }
    return result;
  }

  List<String> getWords(List<String> lines) {
    List<String> words = [];
    for (var i = 0; i < lines.length; i++) {
      if (words.contains(lines[i])==false) {
        words.add(lines[i].toUpperCase());
      }
    }
    return words;
  }

  void checkGuess() {
    var guess = _controller.text.toUpperCase();
    for(var word =0; word<lines.length; word++){
      if(lines[word].toUpperCase()==guess){
          if(words.contains(guess)){
          _controller.clear();}
          words.remove(guess);
          displayLines[word]=lines[word];
      }
    }
    
    setState(() {
        song = displayLines;
      });    
  }

  List<String> getDisplayLines(List<String> lines) {
    List<String> displayLines = [];
    for (var word = 0; word < lines.length; word++) {
      displayLines.add("_____");
    }
    return displayLines;
  }

  List<String> processLyrics(String lyrics) {
    List<String> lines = lyrics.split("\n");
    List<String> lines2 = [];
    for(var word=0; word<lines.length; word++){
      lines2.add(lines[word].substring(0,lines[word].length-1));
    }
    return lines2;
  }

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Play"),
        ),
        body: Column(children: <Widget>[
          TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              )),
          Expanded(
            child: SizedBox(
              child: GridView.count(
                  padding: const EdgeInsets.all(2),
                  childAspectRatio: (itemWidth / itemHeight),
                  crossAxisCount: 20,
                  mainAxisSpacing: 0,
                  shrinkWrap: true,
                  children: List.generate(song.length, (index) {
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: Center(
                        child: Text(
                          song[index],
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  })),
            ),
          ),
        ]));
  }
}
