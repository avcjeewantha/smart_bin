import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission/permission.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './utils/widgets.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMap createState() => _DriverMap();
}

class _DriverMap extends State<DriverMap> {

  CollectionReference binReference;
  CollectionReference diverReference;
  FirebaseUser currentUser;
   GoogleMap googleMap;
  Completer<GoogleMapController> _controller = Completer();

//  Set<Marker> _markers = Set<Marker>();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  MarkerId markerId;
  LatLng markerPosition;
  LatLng currentDestination;
  String binState;
  String truckState="empty";

  // for my drawn routes on the map
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<LatLng> routeCoords;

  // PolylinePoints polylinePoints;
  String googleAPIKey = "AIzaSyDhhXJB0516oa3gdPj7UHf8DHUu4j0ysSc";

//  String googleAPIKey = "113";

  PolylinePoints polylinePoints = PolylinePoints();

// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  BitmapDescriptor redIcon;
  BitmapDescriptor greenIcon;

// the user's initial location and current location
// as it moves
  LocationData currentLocation;


// a reference to the destination location
  LocationData destinationLocation;

// wrapper around the location API
  Location location;

//  PinInformation sourcePinInfo;
//  PinInformation destinationPinInfo;
  GoogleMapPolyline googleMapPolyline;


//   LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
  LatLng DEST_LOCATION = LatLng(5.956048, 80.468666);

//check ride has started
  bool isRideStarted = false;


  static final CameraPosition initialLocation = CameraPosition(
      target: LatLng(9.6615, 80.0255),
      zoom: 14.4746
  );

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();
    // polylinePoints = PolylinePoints();
    googleMapPolyline = new GoogleMapPolyline(apiKey: googleAPIKey);
    setSourceAndDestinationIcons();
    setInitialDetail();


    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      if (isRideStarted) {
        locationUpdater(currentLocation);
        setPolylines();
      }else{
        polylineCoordinates.clear();
      }

      // updatePinOnMap();
    });
    // print(currentLocation);
    // set custom marker pins
    // setSourceAndDestinationIcons();

    // dustbin markers
    binReference = Firestore.instance.collection('Bin');
    binReference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        markerChanger(change);
      });
    });

    print(_markers);
  }

  void locationUpdater(LocationData currentLocationData) {
    Firestore.instance.collection('Truck')
        .document('${currentUser.uid}')
        .setData(
        {
          'state':truckState,
          'latitude': currentLocationData.latitude,
          'longitude': currentLocationData.longitude
        }
    )
        .catchError((onError) {
      print(onError);
    });
  }

  void setSourceAndDestinationIcons() async {
    await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'assets/images/truck.png')
        .then((onValue) {
      sourceIcon = onValue;
    });

    await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0),
        'assets/images/destination.png')
        .then((onValue) {
      destinationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'assets/images/redbin.png')
        .then((onValue) {
      redIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'assets/images/greenbin.png')
        .then((onValue) {
      greenIcon = onValue;
    });
  }

  markerChanger(DocumentChange change) {
//    print('change');
//    print(change.document.data);
//  print("markerchanger");
    binState = change.document['state'];
    markerId = MarkerId(change.document.documentID);
//    print(change.document.data);
    final markerPosition = LatLng(double.parse(change.document['latitude']),
        double.parse(change.document['longitude']));
  print(markerPosition);
//    print(markerId);
//    print(binState);
//    print(change.document['latitude']);
//    print(change.document['longitude']);
    _markers[markerId] = Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: markerId,
      position: markerPosition,
      infoWindow: InfoWindow(
        title: 'Dustbin',
        snippet: binState == 'empty' ? 'Empty' : 'Full',
      ),
      onTap: () async {
        currentDestination = markerPosition;
       // print(markerPosition);
        await PhoneAuthWidgets.dialogBox(context, setPolylines);
      },
      icon: binState == 'empty' ? greenIcon : redIcon,
      anchor: Offset(0.5, 0.5),

    );
    // print(markers);

  }

  void setInitialDetail() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();
    print(currentLocation);
    // hard-coded destination for this example

    ///////// this should be implemented by us ////////////////////////////////////
//    destinationLocation = LocationData.fromMap({
//      "latitude": DEST_LOCATION.latitude,
//      "longitude": DEST_LOCATION.longitude
//    });
//   setState(() {
//     showPinsOnMap();
//   });
    showPinsOnMap();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: Set<Marker>.of(_markers.values),
              polylines: _polylines,
              mapType: MapType.normal,
              onTap: (LatLng latLng) async {
//                print(latLng);
//                QuerySnapshot object=await reference.where('latitude',isEqualTo:latLng.latitude).where('longitude',isEqualTo:latLng.longitude).getDocuments();
//                print (object.documents.isNotEmpty);
//                if(object.documents.isNotEmpty){
//
//                }
//                currentDestination=latLng;

              },
              initialCameraPosition: initialLocation,
              onMapCreated: (GoogleMapController controller) {
                //   controller.setMapStyle(Utils.mapStyles);

                _controller.complete(controller);

                //setInitialLocation();

              },
            ),

          ],
        ),


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
//                Ink(
//                  decoration: const ShapeDecoration(
//                    color: isRideStarted==false?Colors.orange:Colors.white,
//                    shape: CircleBorder(),
//                  ),
//                  child:
                truckState=="empty"?
                RaisedButton(
                  textColor: Colors.orange,
                  disabledTextColor: Colors.orange,
                  disabledColor: Colors.orange,
                  color: Colors.white,
                  onPressed: isRideStarted == false ? null : () {
                    //delete diver's record
                    Firestore.instance.collection('Truck').document(
                        '${currentUser.uid}').updateData({
                      "state":"full"
                    }).then((value){
                      setState((){
                        truckState="full";
                      });

                    }).catchError((onError){
                      print(onError);
                    });

                    // delete polyline and object from the database //make sure you have known user id
                  },
                  child: Text("Change State",
                    style: TextStyle(fontSize: 20),
                  ),

                ):RaisedButton(
                  textColor: Colors.orange,
                  disabledTextColor: Colors.orange,
                  disabledColor: Colors.orange,
                  color: Colors.white,
                  onPressed: isRideStarted == false ? null : () {
                    Firestore.instance.collection('Truck').document(
                        '${currentUser.uid}').delete().then((value){
                      isRideStarted = false;
                      //           polylineCoordinates.clear();
                      //delete diver's record
                      print(truckState);
                      creatingSourcePin( LatLng(currentLocation.latitude, currentLocation.longitude),truckState);

                    }).catchError((onError){
                      print(onError);
                    });


                    // delete polyline and object from the database //make sure you have known user id
                  },
                  child: Text("End Ride",
                    style: TextStyle(fontSize: 20),
                  ),

                )
                //    ),

              ],
            ),
          );
        },),

      ),
    );
  }

  void showPinsOnMap() {
    print("showPinsOnMap");
    print(currentLocation);
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
    LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
//    var destPosition =
//    LatLng(destinationLocation.latitude, destinationLocation.longitude);
    creatingSourcePin(pinPosition,truckState);
//    sourcePinInfo = PinInformation(
//        locationName: "Start Location",
//        location: SOURCE_LOCATION,
//        pinPath: "assets/driving_pin.png",
//        avatarPath: "assets/friend1.jpg",
//        labelColor: Colors.blueAccent);
//
//    destinationPinInfo = PinInformation(
//        locationName: "End Location",
//        location: DEST_LOCATION,
//        pinPath: "assets/destination_map_marker.png",
//        avatarPath: "assets/friend2.jpg",
//        labelColor: Colors.purple);



    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    if(currentDestination!=null){
      setPolylines().then((value) {
        setState(() {
          isRideStarted=value;
          print(isRideStarted);
        });

      });
    }
  }
  void creatingSourcePin(LatLng pinPosition, String state){
    // add the initial source location pin
    setState(() {
      _markers[MarkerId('sourcePin')] = Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition,
//        onTap: () {
//          setState(() {
//            currentlySelectedPin = sourcePinInfo;
//            pinPillPosition = 0;
//          });
//        },
          infoWindow:InfoWindow(
              title: 'Truck',
              snippet: state
          ),
          icon: sourceIcon);
      // destination pin we don't want a destination pin
//      _markers[MarkerId('destPin')]=Marker(
//          markerId: MarkerId('destPin'),
//          position: destPosition,
////        onTap: () {
////          setState(() {
////            currentlySelectedPin = destinationPinInfo;
////            pinPillPosition = 0;
////          });
////        },
//          icon: destinationIcon);

    });

  }
  Future<bool> setPolylines() async {
   print(isRideStarted);
    print("RHIS IS EORKING @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@222");
//    var permissions =
//    await Permission.getPermissionsStatus([PermissionName.Location]);
//    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
//      var askpermissions =
//      await Permission.requestPermissions([PermissionName.Location]);
//    } else
//    {

//        var permissions =
//    await Permission.getPermissionsStatus([PermissionName.Location]);
//    print(permissions[0].permissionName);
//        print(permissions[0].permissionStatus);
//    List<PointLatLng> result = await
//    polylinePoints?.getRouteBetweenCoordinates(
//        googleAPIKey,
//        5.980718,
//        80.365755,
//        5.982468,
//        80.366463);
//      routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
////          origin: LatLng(5.980718, 80.365755),
////          destination: LatLng(5.982468, 80.366463),
//        origin: LatLng(currentLocation.latitude, currentLocation.longitude),
//        destination: LatLng(destinationLocation.latitude, destinationLocation.longitude),
//        mode: RouteMode.driving).catchError((onError){
//          print(onError);
//    });
//  ;}
//    print("result");
//    print(result);
//    if(result.isNotEmpty){
//      // loop through all PointLatLng points and convert them
//      // to a list of LatLng, required by the Polyline
//      result.forEach((PointLatLng point){
//        polylineCoordinates.add(
//            LatLng(point.latitude, point.longitude));
//      });
//    }
//    setState(() {
//      // create a Polyline instance
//      // with an id, an RGB color and the list of LatLng pairs
//      Polyline polyline = Polyline(
//          polylineId: PolylineId("destination"),
//          color: Color.fromARGB(255, 40, 122, 198),
//          points: polylineCoordinates
//      );

    // add the constructed polyline as a set of points
    // to the polyline set, which will eventually
    // end up showing up on the map
//      _polylines.add(polyline);
//    });
//    print ('????????????????????????????');
//    print(routeCoords);
//    setState(() {
//    _polylines.add(Polyline(
//        polylineId: PolylineId('destination'),
//        visible: true,
//        points: routeCoords,
//        width: 4,
//        color: Colors.blue,
//        startCap: Cap.roundCap,
//        endCap: Cap.buttCap));
//  });
//  }


    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        currentLocation.latitude,
        currentLocation.longitude,
        currentDestination.latitude,
        currentDestination.longitude);
    print(googleAPIKey);
    print(currentLocation);
    print(currentDestination);
    print(result.length);
    if (result.isNotEmpty) {
      polylineCoordinates.clear();
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
            width: 2, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates));
      });
      return true;

    //  isRideStarted=true;
    }
  }



}




