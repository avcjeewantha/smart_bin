import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService{

  searchPhoneNo(String phoneNo){
    return Firestore.instance.collection("allowedUsers")
    .where('phoneNo', isEqualTo:phoneNo)
    .getDocuments();
  }

}