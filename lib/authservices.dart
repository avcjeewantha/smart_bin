import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  // handleAuth() {
  //   return StreamBuilder(
  //     stream: FirebaseAuth.instance.onAuthStateChanged,
  //     builder: (BuildContext context, snapshot) {
  //       print("inside meeee");
  //       if (snapshot.hasData){
  //         print("in hasdta");
  //         return DriverMap();
  //       }else{
  //         print("in nodata");
  //         return Login();
  //       }
  //     }
  //   );
  // }

  signOut(){
    print('chamoda : sign out fuction called');
    FirebaseAuth.instance.signOut();
  }

  signIn(AuthCredential authCreds){
    print('chamoda : sign in fuction called');
    FirebaseAuth.instance.signInWithCredential(authCreds);
  }

}