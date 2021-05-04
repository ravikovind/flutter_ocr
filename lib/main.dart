import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: deprecated_member_use
  List textx = List();
  bool isEmpty = true;
  final FlutterTts flutterTts = FlutterTts();

  bool isInitilized = false;
  @override
  void initState() {
    FlutterMobileVision.start().then((value) {
      isInitilized = true;
    });
    super.initState();
  }

  _startScan() async {
    textx.clear();
    // ignore: deprecated_member_use
    List<OcrText> list = List();

    try {
      list = await FlutterMobileVision.read(
        waitTap: true,
        fps: 5,
        multiple: true,
      );

      for (OcrText text in list) {
        setState(() {
          textx.add(text.value);
        });
        print('value is ${text.value}');
      }
      if (textx.length != 0) {
        setState(() {
          isEmpty = false;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        actions: [
          isEmpty
              ? Container()
              : IconButton(
                  icon: Icon(Icons.replay_outlined, color: Colors.white),
                  onPressed: () async {
                    await flutterTts.stop();
                    setState(() {
                      textx.clear();
                      isEmpty = true;
                    });
                  }),
        ],
        title: Text(
          "OCR",
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isEmpty ? _startScan : _speak,
        elevation: 16.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        label: Text(
          isEmpty ? "Scan" : "Read",
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        icon: Icon(
          isEmpty ? Icons.repeat_rounded : Icons.volume_up_rounded,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 80.0, right: 80.0, left: 80, bottom: 40.0),
        child: Container(
          child: ListView.builder(
            itemCount: textx.length,
            itemBuilder: (BuildContext context, int index) {
              return Text(textx[index].toString());
            },
          ),
          decoration: isEmpty
              ? BoxDecoration(
                  image: DecorationImage(image: AssetImage("images/1.png")))
              : BoxDecoration(),
        ),
      ),
    );
  }

  Future _speak() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1);
    await flutterTts.speak(textx.toString());
  }
}
