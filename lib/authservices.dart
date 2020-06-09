import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin/driver_map.dart';
import 'package:smart_bin/searchservice.dart';
import 'package:smart_bin/utils/flushbar.dart';

class AuthService {
  static FirebaseUser okUser;

  signOut() {
    FirebaseAuth.instance.signOut();
  }

  signIn(AuthCredential authCreds, context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth
        .signInWithCredential(authCreds)
        .then((value) => {
              _auth.currentUser().then((user) {
                if (user != null) {
                  SearchService()
                      .searchPhoneNo(user.phoneNumber)
                      .then((QuerySnapshot docs) {
                    if (docs.documents.length != 1) {
                      ShowFlushbar.showMessage('Not allowed to login', context);
                    } else {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new DriverMap()));
                    }
                  });
                } else {
                  Navigator.of(context).pop();
                }
              })
            })
        .catchError((onError) {
      if (onError.code.contains('ERROR_NETWORK_REQUEST_FAILED'))
        ShowFlushbar.showMessage('Network Error', context);
      else
        ShowFlushbar.showMessage('Error', context);
    });
  }

  signInWithOTP(smsCode, verId, context) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCreds, context);
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      SearchService()
          .searchPhoneNo(user.phoneNumber)
          .then((QuerySnapshot docs) {
        if (docs.documents.length == 1) {
          print(docs.documents);
          okUser = user;
        }
      });
    }
    return okUser;
  }
}
