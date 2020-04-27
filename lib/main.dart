import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_bin/customer_map.dart';
import 'package:smart_bin/driver_map.dart';
import 'package:smart_bin/login.dart';
import 'package:smart_bin/my_drawer.dart';
import 'package:smart_bin/utils/flushbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.amber),
      title: 'Flutter Playground',
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "/login": (BuildContext context) => new Login(),
        "/driver_map": (BuildContext context) => new DriverMap(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController complain = new TextEditingController();
  Firestore _firestore = Firestore.instance;

  String snackbarMessage;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: CustomerMap(),
      bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom != 0
          ? null
          : BottomAppBar(
              color: Colors.orange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      }),
                  IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () async {
                        complain.clear();
                        await _showDialog(context);
                        if (snackbarMessage != null) {
//                 print("snackbarMessage not null");
//                 print(snackbarMessage);

                          ShowFlushbar.showMessage(snackbarMessage, context);
                        }
                      }),
                ],
              ),
            ),
      drawer: MyDrawer(),
    );
  }

  _showDialog(BuildContext context) async {
//
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Enter your complain",
                style: TextStyle(
                  fontSize: 18,
                )),
            children: <Widget>[
              new SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: TextField(
                    decoration: new InputDecoration(
                        hintText: "Enter your complain",
                        contentPadding: const EdgeInsets.all(20.0)),
                    controller: complain,
                    maxLines: null,
                  ),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      snackbarMessage = null;
                      Navigator.pop(context, true);
                    },
                    child: Text('CANCEL'),
                    color: Colors.orange,
                    textColor: Colors.white,
                  ),
                  new FlatButton(
                    onPressed: () async {
                      if (complain.text.trim().isNotEmpty) {
                        await _firestore
                            .collection('complain')
                            .add({'complain': complain.text}).then(
                                (documentReference) {
                          snackbarMessage = 'Successful! Complain was sent';
                        }).catchError((onError) {
                          snackbarMessage = 'Something is wrong ';
                        });
                        Navigator.pop(context, true);
                      }
                      ShowFlushbar.showMessage(
                          'Please enter valid complain ', context);
                    },
                    disabledColor: Colors.grey,
                    child: Text('SEND'),
                    color: Colors.orange,
                    textColor: Colors.white,
                  ),
                ],
              )
            ],
          );
        });
  }
}
