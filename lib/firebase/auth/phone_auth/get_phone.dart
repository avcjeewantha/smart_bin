import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_bin/data_models/countries.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_bin/authservices.dart';
import 'package:smart_bin/utils/widgets.dart';

/*
 *  PhoneAuthUI - this file contains whole ui and controllers of ui
 *  Background code will be in other class
 *  This code can be easily re-usable with any other service type, as UI part and background handling are completely from different sources
 *  code.dart - Class to control background processes in phone auth verification using Firebase
 */
enum PhoneAuthState {
  Started,
  CodeSent,
  CodeResent,
  Verified,
  Failed,
  Error,
  AutoRetrievalTimeOut
}
// ignore: must_be_immutable
class PhoneAuthGetPhone extends StatefulWidget {
  /*
   *  cardBackgroundColor & logo values will be passed to the constructor
   *  here we access these params in the _PhoneAuthState using "widget"
   */
  Color cardBackgroundColor = Colors.orange;
  String appName = "Awesome app";

  @override
  _PhoneAuthGetPhoneState createState() => _PhoneAuthGetPhoneState();

}

class _PhoneAuthGetPhoneState extends State<PhoneAuthGetPhone> {
  /*
   *  _height & _width:
   *    will be calculated from the MediaQuery of widget's context
   *  countries:
   *    will be a list of Country model, Country model contains name, dialCode, flag and code for various countries
   *    and below params are all related to StreamBuilder
   */
  double _height, _width, _fixedPadding;

  List<Country> countries = [];
  StreamController<List<Country>> _countriesStreamController;
  Stream<List<Country>> _countriesStream;
  Sink<List<Country>> _countriesSink;

  /*
   *  _searchCountryController - This will be used as a controller for listening to the changes what the user is entering
   *  and it's listener will take care of the rest
   */
  TextEditingController _searchCountryController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _oTpController = TextEditingController();

  /*
   *  This will be the index, we will modify each time the user selects a new country from the dropdown list(dialog),
   *  As a default case, we are using India as default country, index = 31
   */
  int _selectedCountryIndex = 208;

  bool _isCountriesDataFormed = false;
     // static var _authCredential, actualCode, phone, status;
  static StreamController<String> statusStream = StreamController.broadcast();
  static StreamController<PhoneAuthState> phoneAuthState = StreamController.broadcast();
  // static Stream stateStream = phoneAuthState.stream;
  // static BuildContext cont;
  String verificationId;
  bool codeSent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // While disposing the widget, we should close all the streams and controllers

    // Disposing Stream components
//    _countriesSink.close();
//    _countriesStreamController.close();

    // Disposing _countriesSearchController
    _searchCountryController.dispose();
    super.dispose();
  }

  Future<List<Country>> loadCountriesJson() async {
    //  Cleaning up the countries list before we put our data in it
    countries.clear();

    //  Fetching the json file, decoding it and storing each object as Country in countries(list)
    var value = await DefaultAssetBundle.of(context)
        .loadString("data/country_phone_codes.json");
    var countriesJson = json.decode(value);
    for (var country in countriesJson) {
      countries.add(Country.fromJson(country));
    }

    //Finally adding the initial data to the _countriesSink
    // _countriesSink.add(countries);
    return countries;
  }

  @override
  Widget build(BuildContext context) {
    //  Fetching height & width parameters from the MediaQuery
    //  _logoPadding will be a constant, scaling it according to device's size
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      if (countries.length < 240) {
        loadCountriesJson().whenComplete(() {
          setState(() => _isCountriesDataFormed = true);
        });
      }
    });

    /*  Scaffold: Using a Scaffold widget as parent
     *  SafeArea: As a precaution - wrapping all child descendants in SafeArea, so that even notched phones won't loose data
     *  Center: As we are just having Card widget - making it to stay in Center would really look good
     *  SingleChildScrollView: There can be chances arising where
     */
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: _getBody(),
          ),
        ),
      ),
    );
  }

  /*
   *  Widget hierarchy ->
   *    Scaffold -> SafeArea -> Center -> SingleChildScrollView -> Card()
   *    Card -> FutureBuilder -> Column()
   */
  Widget _getBody() => Card(
        color: widget.cardBackgroundColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          height: _height * 8 / 10,
          width: _width * 8 / 10,

          /*
           * Fetching countries data from JSON file and storing them in a List of Country model:
           * ref:- List<Country> countries
           * Until the data is fetched, there will be CircularProgressIndicator showing, describing something is on it's way
           * (Previously there was a FutureBuilder rather that the below thing, which created unexpected exceptions and had to be removed)
           */
          child: _isCountriesDataFormed
              ? _getColumnBody()
              : Center(child: CircularProgressIndicator()),
        ),
      );

  Widget _getColumnBody() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // AppName:
          Text(widget.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700)),

          Padding(
            padding: EdgeInsets.only(top: _fixedPadding, left: _fixedPadding),
            child: PhoneAuthWidgets.subTitle('Select your country'),
          ),

          /*
           *  Select your country, this will be a custom DropDown menu, rather than just as a dropDown
           *  onTap of this, will show a Dialog asking the user to select country they reside,
           *  according to their selection, prefix will change in the PhoneNumber TextFormField
           */
          Padding(
            padding: EdgeInsets.only(left: _fixedPadding, right: _fixedPadding),
            child: PhoneAuthWidgets.selectCountryDropDown(
                countries[_selectedCountryIndex], showCountries),
          ),

          //  Subtitle for Enter your phone
          Padding(
            padding: EdgeInsets.only(top: 10.0, left: _fixedPadding),
            child: PhoneAuthWidgets.subTitle('Enter your phone'),
          ),
          //  PhoneNumber TextFormFields
          Padding(
            padding: EdgeInsets.only(
                left: _fixedPadding,
                right: _fixedPadding,
                bottom: _fixedPadding),
            child: PhoneAuthWidgets.phoneNumberField(_phoneNumberController,
                countries[_selectedCountryIndex].dialCode),
          ),

          codeSent ? Padding(
            padding: EdgeInsets.only(top: 10.0, left: _fixedPadding),
            child: PhoneAuthWidgets.subTitle('Enter OTP'),
          ):Container(),
          //  PhoneNumber TextFormFields
          codeSent ? Padding(
            padding: EdgeInsets.only(
                left: _fixedPadding,
                right: _fixedPadding,
                bottom: _fixedPadding),
            child: PhoneAuthWidgets.oTPField(_oTpController),
          ):Container(),

          /*
           *  Some informative text
           */
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: _fixedPadding),
              codeSent ? Container():Icon(Icons.info, color: Colors.black, size: 20.0),
              SizedBox(width: 10.0),
              Expanded(
                child: codeSent ? Container() :RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'We will send ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: 'One Time Password',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' to this mobile number',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400)),
                ])),
              ),
              SizedBox(width: _fixedPadding),
            ],
          ),

          /*
           *  Button: OnTap of this, it appends the dial code and the phone number entered by the user to send OTP,
           *  knowing once the OTP has been sent to the user - the user will be navigated to a new Screen,
           *  where is asked to enter the OTP he has received on his mobile (or) wait for the system to automatically detect the OTP
           */
          SizedBox(height: _fixedPadding * 1.5),
          codeSent ? RaisedButton(
            elevation: 16.0,
            onPressed: () {
                AuthService().signInWithOTP(_oTpController.text, verificationId);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Verify',
                style: TextStyle(
                    color: Colors.black, fontSize: 18.0),
              ),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ) :RaisedButton(
            elevation: 16.0,
            onPressed: () {
                verifyPhone(countries[_selectedCountryIndex].dialCode + _phoneNumberController.text);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'SEND OTP',
                style: TextStyle(
                    color: Colors.black, fontSize: 18.0),
              ),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ],
      );

  /*
   *  This will trigger a dialog, that will let the user to select their country, so the dialcode
   *  of their country will be automatically added at the end
   */
  showCountries() {
    /*
     * Initialising components required for StreamBuilder
     * We will not be using _countriesStreamController anywhere, but just to initialize Stream & Sink from that
     * _countriesStream will give us the data what we need(output) - that will be used in StreamBuilder widget
     * _countriesSink is the place where we send the data(input)
     */
    _countriesStreamController = StreamController();
    _countriesStream = _countriesStreamController.stream;
    _countriesSink = _countriesStreamController.sink;
    _countriesSink.add(countries);

    _searchCountryController.addListener(searchCountries);

    showDialog(
        context: context,
        builder: (BuildContext context) => searchAndPickYourCountryHere(),
        barrierDismissible: false);
  }

  /*
   *  This will be the listener for searching the query entered by user for their country, (dialog pop-up),
   *  searches for the query and returns list of countries matching the query by adding the results to the sink of _countriesStream
   */
  searchCountries() {
    String query = _searchCountryController.text;
    if (query.length == 0 || query.length == 1) {
      if(!_countriesStreamController.isClosed)
        _countriesSink.add(countries);
//      print('added all countries again');
    } else if (query.length >= 2 && query.length <= 5) {
      List<Country> searchResults = [];
      searchResults.clear();
      countries.forEach((Country c) {
        if (c.toString().toLowerCase().contains(query.toLowerCase()))
          searchResults.add(c);
      });
      _countriesSink.add(searchResults);
//      print('added few countries based on search ${searchResults.length}');
    } else {
      //No results
      List<Country> searchResults = [];
      _countriesSink.add(searchResults);
//      print('no countries added');
    }
  }

  /*
   * Child for Dialog
   * Contents:
   *    SearchCountryTextFormField
   *    StreamBuilder
   *      - Shows a list of countries
   */
  Widget searchAndPickYourCountryHere() => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Dialog(
          key: Key('SearchCountryDialog'),
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Container(
            margin: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //  TextFormField for searching country
                PhoneAuthWidgets.searchCountry(_searchCountryController),

                //  Returns a list of Countries that will change according to the search query
                SizedBox(
                  height: 175.0,
                  child: StreamBuilder<List<Country>>(
                      //key: Key('Countries-StreamBuilder'),
                      stream: _countriesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // print(snapshot.data.length);
                          return snapshot.data.length == 0
                              ? Center(
                                  child: Text('Your search found no results',
                                      style: TextStyle(fontSize: 16.0)),
                                )
                              : ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int i) =>
                                      PhoneAuthWidgets.selectableWidget(
                                          snapshot.data[i],
                                          (Country c) => selectThisCountry(c)),
                                );
                        } else if (snapshot.hasError)
                          return Center(
                            child: Text('Seems, there is an error',
                                style: TextStyle(fontSize: 16.0)),
                          );
                        return Center(child: CircularProgressIndicator());
                      }),
                )
              ],
            ),
          ),
        ),
      );
  /*
   *  This callback is triggered when the user taps(selects) on any country from the available list in dialog
   *    Resets the search value
   *    Close the stream & sink
   *    Updates the selected Country and adds dialCode as prefix according to the user's selection
   */
  void selectThisCountry(Country country) {
    print(country);
    _searchCountryController.clear();
    Navigator.of(context, rootNavigator: true).pop();
    Future.delayed(Duration(milliseconds: 10)).whenComplete(() {
      _countriesStreamController.close();
      _countriesSink.close();
      
      setState(() {
        _selectedCountryIndex = countries.indexOf(country);
      });
    });
  }

  Future<void> verifyPhone(phoneNo) async {
    print("Hi there Im chamodaa............................");
    print(phoneNo);
    final PhoneVerificationCompleted verified =(AuthCredential authResult){
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException){
      // addStatus('${authException.message}');
      // addState(PhoneAuthState.Error);
      // if (authException.message.contains('not authorized'))
      //   addStatus('App not authroized');
      // else if (authException.message.contains('Network'))
      //   addStatus('Please check your internet connection and try again');
      // else
      //   addStatus('Something has gone wrong, please try later ' + authException.message);
      print("chamoda : verification Failed");
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      verificationId = verId;
      print('chamoda: code sent');
      setState((){
        this.codeSent = true;
      });
      // addStatus("\nEnter the code sent to " + phone);
      // addState(PhoneAuthState.CodeSent);
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      verificationId = verId;
      // addStatus("\nAuto retrieval time out");
      // addState(PhoneAuthState.AutoRetrievalTimeOut);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNo, 
      timeout: const Duration(seconds:60), 
      verificationCompleted: verified, 
      verificationFailed: verificationFailed, 
      codeSent: smsSent, 
      codeAutoRetrievalTimeout: autoTimeout).catchError((error) {
      // addStatus(error.toString());
      });
  }

  // static addState(PhoneAuthState state) {
  //   print(state);
  //   // phoneAuthState.sink.add(state);
  // }

  // static void addStatus(String s) {
  //   // statusStream.sink.add(s);
  //   print(s);
  // }
}
