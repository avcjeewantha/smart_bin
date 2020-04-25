import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:smart_bin/driver_map.dart';
import 'package:smart_bin/login.dart';
import 'package:smart_bin/my_drawer.dart';
import './customer_map.dart';
import './utils/flushbar.dart';

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
  TextEditingController complain = new TextEditingController();
  Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      resizeToAvoidBottomPadding:false,
      body: CustomerMap(),
      bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom !=0 ? null :
        BottomAppBar(
          color: Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () {
                Scaffold.of(context).openDrawer();
              }),
              IconButton(icon: Icon(Icons.message), onPressed:(){
                _showDialog(context);
             }

              ),
            ],
          ),
        ),

      drawer: MyDrawer(),
    );


  }
     _showDialog(BuildContext context)  async {
//
       await showDialog(
           context: context,
           builder: (BuildContext context) {

             return SimpleDialog(
               title: Text("Enter your complain",
               style:TextStyle(
                 fontSize: 18,
               )

               ),
               children: <Widget>[

                 new SizedBox(
                     width: MediaQuery.of(context).size.width,
                     child: SingleChildScrollView(
                     child: TextField(
                       decoration: new InputDecoration(hintText: "Enter your complain", contentPadding: const EdgeInsets.all(20.0)),
                       controller: complain,
                       maxLines: null,
                       
                     ),
                   ),
             ),



                 new Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: <Widget>[
                     new FlatButton(onPressed: (){
                       complain.clear();
                       Navigator.pop(context, true);
                     },

                      child: Text('CANCEL'),
                       color: Colors.orange,
                       textColor: Colors.white,
             ),

                     new FlatButton(onPressed: (){
                        print(complain.text);
                       _firestore.collection('complain').add({
                         'complain': complain.text
                       }).then((documentReference){
                         complain.clear();
                         print(documentReference.documentID);
                         ShowFlushbar.showMessage(
                             'Successful! Complain was sent', context);
                       }
                       ).catchError((onError){
                         print(onError);
                         complain.clear();
                         ShowFlushbar.showMessage('Something is wrong ', context);
                       }
                       );
                     },

                         child: Text('SEND'),
                       color: Colors.orange,
                       textColor: Colors.white,
                     )
                   ],
                 )
               ],

             );
           }
       );
     }


}