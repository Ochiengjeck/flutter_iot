import 'package:flutter/material.dart';
import 'dart:io' show Socket;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class MyHomePage extends StatefulWidget {
  final String title;
  final Socket? socket;
  final WebSocketChannel? webSocketChannel;

  MyHomePage({required this.title, this.socket, this.webSocketChannel});

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
    if (widget.socket != null) {
      widget.socket!.listen((data) {
        handleData(String.fromCharCodes(data));
      });
    } else if (widget.webSocketChannel != null) {
      widget.webSocketChannel!.stream.listen((data) {
        handleData(data);
      });
    }
  }

  void handleData(String data) {
    final parts = data.split(',');
    if (parts.length == 3) {
      setState(() {
        temperature = parts[0];
        humidity = parts[1];
        waterLevel = parts[2];
        history.add(
            "Temp: $temperature °C, Hum: $humidity %, Water: $waterLevel cm");
      });
    }
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
              child: Text("Fan On/Off",
                  style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 20.0)),
              onPressed: _toggleFan,
            ),
            ElevatedButton(
              child: Text("Light On/Off",
                  style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 20.0)),
              onPressed: _toggleLight,
            ),
            ElevatedButton(
              child: Text("Fill Water Tank",
                  style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 20.0)),
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
    sendData("FAN_TOGGLE\n");
  }

  void _toggleLight() {
    sendData("LIGHT_TOGGLE\n");
  }

  void _fillWaterTank() {
    sendData("FILL_WATER\n");
  }

  void sendData(String data) {
    if (widget.socket != null) {
      widget.socket!.write(data);
    } else if (widget.webSocketChannel != null) {
      widget.webSocketChannel!.sink.add(data);
    }
  }

  @override
  void dispose() {
    if (widget.socket != null) {
      widget.socket!.close();
    } else if (widget.webSocketChannel != null) {
      widget.webSocketChannel!.sink.close(status.goingAway);
    }
    super.dispose();
  }
}
