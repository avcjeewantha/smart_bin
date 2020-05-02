import 'package:flutter/material.dart';
import '../data_models/countries.dart';

class PhoneAuthWidgets {

  static Widget searchCountry(TextEditingController controller) => Padding(
        padding:
            const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 2.0, right: 8.0),
        child: Card(
          child: TextFormField(
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(
                hintText: 'Search your country',
                contentPadding: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
                border: InputBorder.none),
          ),
        ),
      );

  static Widget phoneNumberField(
          TextEditingController controller, String prefix) =>
      Card(
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          key: Key('EnterPhone-TextFormField'),
          decoration: InputDecoration(
            border: InputBorder.none,
            errorMaxLines: 1,
            prefix: Text("  " + prefix + "  "),
          ),
        ),
      );

  static Widget oTPField(
          TextEditingController controller) =>
      Card(
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          key: Key('EnterOTP-TextFormField'),
          decoration: InputDecoration(
            border: InputBorder.none,
            errorMaxLines: 1,
          ),
        ),
      );

  static Widget selectableWidget(Country country, Function(Country) selectThisCountry) =>
      Material(
        color: Colors.white,
        type: MaterialType.canvas,
        child: InkWell(
          onTap: () => selectThisCountry(country), //selectThisCountry(country),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            child: Text(
              "  " +
                  country.flag +
                  "  " +
                  country.name +
                  " (" +
                  country.dialCode +
                  ")",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );

  static Widget selectCountryDropDown(Country country, Function onPressed) =>
      Card(
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 4.0, right: 4.0, top: 8.0, bottom: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(' ${country.flag}  ${country.name} ')),
                Icon(Icons.arrow_drop_down, size: 24.0)
              ],
            ),
          ),
        ),
      );

  static Widget subTitle(String text) => Align(
      alignment: Alignment.centerLeft,
      child: Text(' $text',
          style: TextStyle(color: Colors.black, fontSize: 14.0)));

  static Future<Widget> dialogBox(BuildContext context,Function setPolylines) async=>
      await showDialog(
  context: context,
  builder: (BuildContext context) {
   return SimpleDialog(
        title: Text("Are you going to start the ride ?",
            style: TextStyle(
              fontSize: 18,
            )

        ),
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                new FlatButton(onPressed: () {
                  Navigator.pop(context);
                },

                  child: Text('NO'),
                  color: Colors.orange,
                  textColor: Colors.white,
                ),
                new FlatButton(onPressed: () {
//                  isRideStarted = true;
                  setPolylines(); // set distance place store longitude, lat in db. use known userId
                  Navigator.pop(context);
                },

                  child: Text('YES'),
                  color: Colors.orange,
                  textColor: Colors.white,
                )
              ]
          ),
        ]
    );
  }
);
}
