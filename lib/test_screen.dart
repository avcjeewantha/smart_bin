import 'package:flutter/material.dart';
import 'package:smart_bin/login.dart' show loaderStream, States;

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    startWork();
    super.initState();
  }

  startWork() {
    print("started work");
    Future.delayed(Duration(seconds: 4)).whenComplete(() {
      print('showing');
      loaderStream.sink.add(States.Show);
//      Future.delayed(Duration(seconds: 2)).whenComplete((){
//        print('hiding');
//        loaderStream.sink.add(States.Hide);
//      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('This is a test page'),
          Image.asset(
            'images/firebase.png',
            height: 250.0,
          ),
          RaisedButton(
            color: Colors.greenAccent,
            child: Text('Click here'),
            onPressed: () {
              print('clicked');
            },
          )
        ],
      ),
    );
  }
}