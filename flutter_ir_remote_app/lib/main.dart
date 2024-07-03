import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

void main() async {
  // Modify with your actual address/port
  Socket socket = await Socket.connect('192.168.1.101', 80);
  runApp(MyApp(socket));
}

class MyApp extends StatelessWidget {
  final Socket socket;

  MyApp(this.socket);

  @override
  Widget build(BuildContext context) {
    final title = 'IoT Incubator Control';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        channel: socket,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Socket channel;

  MyHomePage({required this.title, required this.channel});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String temperature = "Loading...";
  String humidity = "Loading...";
  String waterLevel = "Loading...";
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    widget.channel.listen((data) {
      final response = String.fromCharCodes(data);
      final parts = response.split(',');
      if (parts.length == 3) {
        setState(() {
          temperature = parts[0];
          humidity = parts[1];
          waterLevel = parts[2];
          history.add(
              "Temp: $temperature °C, Hum: $humidity %, Water: $waterLevel cm");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Temperature: $temperature °C',
                style: TextStyle(fontSize: 20)),
            Text('Humidity: $humidity %', style: TextStyle(fontSize: 20)),
            Text('Water Level: $waterLevel cm', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                "Fan On/Off",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0),
              ),
              onPressed: _toggleFan,
            ),
            ElevatedButton(
              child: Text(
                "Light On/Off",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0),
              ),
              onPressed: _toggleLight,
            ),
            ElevatedButton(
              child: Text(
                "Fill Water Tank",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0),
              ),
              onPressed: _fillWaterTank,
            ),
            SizedBox(height: 20),
            Text("History of the Day:", style: TextStyle(fontSize: 20)),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(history[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFan() {
    widget.channel.write("FAN_TOGGLE\n");
  }

  void _toggleLight() {
    widget.channel.write("LIGHT_TOGGLE\n");
  }

  void _fillWaterTank() {
    widget.channel.write("FILL_WATER\n");
  }

  @override
  void dispose() {
    widget.channel.close();
    super.dispose();
  }
}
