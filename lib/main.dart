import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Channel Sample With SocketIO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Channel Sample With SocketIO Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  MethodChannel channel = MethodChannel('SocketIOClient');
  List<String> messages = List<String>();
  bool isConnected = false;
  String senderName = "user";
  final messageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkFlutterChanel();
    int userNo = new Random().nextInt(100);
    senderName = senderName + userNo.toString();
    setupMetodCallHandlers();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: 200,
              height: 50,
              child: FlatButton(
                child: Text(this.isConnected ? 'Disconnect' : 'Connect', style: TextStyle(color: Colors.black, fontSize: 20)),
                onPressed: (){
                  if(this.isConnected) {
                    disconnect();
                  } else {
                    connect();
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        color: index % 2 == 0 ? Colors.blue : Colors.red,
                        child: Text(messages[index], textAlign: TextAlign.left, style: TextStyle(fontSize: 15)),
                      );
                    }
                ),
              ),
            ),
            SafeArea(
              bottom: true,
              child: Container(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: this.messageTextController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            border: OutlineInputBorder()
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.green,
                      child: FlatButton(
                        child: Text("Gönder", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          sendMessage(this.messageTextController.value.text);
                        },
                      ),
                    )
                  ],
                ),

              ),
            )
          ],
        )


      )
    );
  }

  void checkFlutterChanel() {
    Future<bool> result = channel.invokeMethod('flutterChannelTest',<String, String> {
      'arg': 'test'
    });
    result.then((boolVal) {
      if (boolVal == true) {
        setState(() {
          this.messages.add("Flutter Channel Test Başarılı");
        });
      } else {
        setState(() {
          this.messages.add("Flutter Channel Test Başarısız");
        });
      }
    });
  }

  void connect() {
    channel.invokeMethod('connect');
  }
  void disconnect() {
    channel.invokeMethod('disconnect');
  }

  void sendMessage(String message) {
    if(message != null && message.length > 0) {
      channel.invokeMethod('sendMessage',<String, String> {
        'message': message,
        'sender': this.senderName
      });
      setState(() {
        this.messageTextController.text = "";
      });
    }
  }

  void setupMetodCallHandlers() {
    Future<dynamic> handlers(MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'connected':
          print('Bağlandı');
          setState(() {
            this.isConnected = true;
            this.messages.add('Bağlandı');
          });
          return;
        case 'disconnected':
          print('Bağlantı koptu');
          setState(() {
            this.isConnected = false;
            this.messages.add('Bağlantı Koptu');
          });
          return;
        case 'messageReceived':
          List args = methodCall.arguments as List;
          String sender = args[0] as String;
          String message = args[1] as String;
          print(sender + ' kullanıcısından mesaj geldi: ' + message);
          setState(() {
            this.messages.add(sender + ': ' + message);
          });
          return;
        default:
          return;
      }
    }

    channel.setMethodCallHandler(handlers);
  }
}
