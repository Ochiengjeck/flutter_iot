import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'dart:io' show Platform, Socket;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Socket? socket;
  final WebSocketChannel? webSocketChannel;

  MyApp({this.socket, this.webSocketChannel});

  @override
  Widget build(BuildContext context) {
    final title = 'IoT Incubator Control';
    return MaterialApp(
      title: title,
      home: FutureBuilder(
        future: initializeConnection(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text(title)),
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            }
            return MyHomePage(
              title: title,
              socket: snapshot.data as Socket?,
              webSocketChannel: snapshot.data as WebSocketChannel?,
            );
          } else {
            return Scaffold(
              appBar: AppBar(title: Text(title)),
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Future<dynamic> initializeConnection() async {
    if (kIsWeb) {
      // For Web environment
      return WebSocketChannel.connect(Uri.parse('ws://192.168.1.101:80'));
    } else {
      // For Mobile/Desktop environments
      return await Socket.connect('192.168.1.101', 80);
    }
  }
}
