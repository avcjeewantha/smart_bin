import 'package:flutter/material.dart';
import 'package:smart_bin/authservices.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.orange,
        child: ListView(
          padding: EdgeInsets
              .zero, // Important: Remove any padding from the ListView.
          children: <Widget>[
            new DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/drawer_header.png"),
                      fit: BoxFit.cover)),
              child: null,
            ),
            ListTile(
              title: Text('Truck Map'),
              onTap: () {

                AuthService().getCurrentUser().then((user) {
                  if (user != null) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/driver_map");
                  } else {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/login");
                  }
                });
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
