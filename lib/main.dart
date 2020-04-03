import 'package:flutter/material.dart';
import './customer_map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.amber),
      title: 'Flutter Playground',
      home: HomePage(),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Important: Remove any padding from the ListView.
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text("Chamoda Jeewantha"),
              accountEmail: new Text("avcjeewantha@gmail.com"),
              currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.grey,
                child: new Text('AV'),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}