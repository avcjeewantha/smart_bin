import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_bin/firebase/auth/phone_auth/get_phone.dart';
import 'package:smart_bin/test_screen.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PhoneAuthGetPhone(),
    );
  }
}

enum States { Show, Hide }

StreamController loaderStream = StreamController<States>();

class StatelessStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TestPage(),
        StreamBuilder<States>(
            initialData: States.Hide,
            stream: loaderStream.stream,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == States.Hide) {
                  return Container();
                } else {
                  return Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      ModalBarrier(
                        dismissible: false,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      Center(
                        child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )),
                      )
                    ],
                  );
                }
              } else {
                return Container();
              }
            })
      ],
    );
  }
}
