import 'package:flutter/material.dart';

class DriverMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: new Center(
          child: new Text("Truck map")
        ),
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
              ],
            ),
          );
          },),
      ),
    );
  }
}