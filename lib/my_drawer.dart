import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.orange,
        child:ListView(
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
              title: Text('Truck Map'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/driver_map");
              },
            ),
            new Divider(),
            ListTile(
              title: Text('Close'),
              trailing: new Icon(Icons.close),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            new Divider(),
          ],
        ),
      ),
      );    
  }
}