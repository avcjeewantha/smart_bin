import 'package:flutter/material.dart';
import 'package:smart_bin/driver_map.dart';
import 'package:smart_bin/login.dart';
import 'package:smart_bin/my_drawer.dart';
import './customer_map.dart';

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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomerMap(),
      bottomNavigationBar: Builder(builder: (BuildContext context) {
        return BottomAppBar(
          color: Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () {
                Scaffold.of(context).openDrawer();
              }),
              IconButton(icon: Icon(Icons.message), onPressed: () {}),
            ],
          ),
        );
        },),
      drawer: MyDrawer(),
    );
  }
}