import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:smart_bin/authservices.dart';
import 'package:smart_bin/my_drawer.dart';
import 'package:smart_bin/utils/flushbar.dart';
import 'package:smart_bin/utils/widgets.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMap createState() => _DriverMap();
}

class _DriverMap extends State<DriverMap> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId;
  String binState;
  String truckState;
  BitmapDescriptor redIcon;
  BitmapDescriptor greenIcon;
  GoogleMapController mapController;
  BitmapDescriptor truckIcon;
  StreamSubscription _locationSubscription;
  Marker meMarker;
  Circle meCircle;
  Location _locationTracker = Location();
  FirebaseUser currentUser;
  bool isRideStarted = false;
  LocationData currentLocation;
  String googleAPIKey = "AIzaSyDhhXJB0516oa3gdPj7UHf8DHUu4j0ysSc";
  GoogleMapPolyline googleMapPolyline;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng currentDestination;
  Set<Polyline> _polylines = {};
  bool navigation = false;

  static final CameraPosition initialLocation =
      CameraPosition(target: LatLng(9.6615, 80.0255), zoom: 14.4746);

  void updateMarkerAndCircle(LocationData newLocaldata) {
    LatLng latlng = LatLng(newLocaldata.latitude, newLocaldata.longitude);
    this.setState(() {
      markers[MarkerId("home")] = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          draggable: false,
          zIndex: 2,
          icon: truckIcon);
      meCircle = Circle(
        circleId: CircleId("cusCir"),
        radius: newLocaldata.accuracy,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: latlng,
        fillColor: Colors.blue.withAlpha(70),
        strokeWidth: 4,
      );
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      currentLocation = location;
      updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (mapController != null) {
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 17.00)));
          updateMarkerAndCircle(newLocalData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION DENIED") {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AuthService().getCurrentUser().then((user) {
      currentUser = user;
      locationRemover();
    });
    getCurrentLocation();
    CollectionReference binReference = Firestore.instance.collection('Bin');
    CollectionReference truckReference = Firestore.instance.collection('Truck');
    binReference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        binMarkerChanger(change);
      });
    });
    truckReference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        truckMarkerChanger(change);
      });
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/redbin.png')
        .then((onValue) {
      redIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/greenbin.png')
        .then((onValue) {
      greenIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/images/truck.png')
        .then((onValue) {
      truckIcon = onValue;
    });

    _locationTracker.onLocationChanged.listen((LocationData cLoc) {
      if (navigation == true) {
         setPolylines();
      } else {
        polylineCoordinates.clear();
      }
      locationUpdater(cLoc);
    });
    polylineCoordinates.clear();
    isRideStarted =false;
  }

  void locationUpdater(LocationData currentLocationData) {
    if (isRideStarted == true) {
      currentLocation = currentLocationData;
      Firestore.instance
          .collection('Truck')
          .document('${currentUser.uid}')
          .setData({
        'state': truckState,
        'latitude': currentLocationData.latitude,
        'longitude': currentLocationData.longitude
      }).catchError((onError) {
        print(onError);
      });
    }
  }

  void locationRemover() {
    Firestore.instance
        .collection('Truck')
        .document('${currentUser.uid}')
        .delete()
        .catchError((onError) {
      print(onError);
    });
  }

  binMarkerChanger(DocumentChange change) {
    binState = change.document['state'];
    markerId = MarkerId(change.document.documentID);
    final markerPosition =
        LatLng(change.document['latitude'], change.document['longitude']);
    markers[markerId] = Marker(
      markerId: markerId,
      position: markerPosition,
      infoWindow: InfoWindow(
        title: 'Dustbin',
        snippet: binState == 'empty' ? 'Empty' : 'Full',
      ),
      onTap: () async {
        currentDestination = markerPosition;
        if (isRideStarted) {
          await PhoneAuthWidgets.dialogBox(context, setPolylines);
        }
      },
      icon: binState == 'empty' ? greenIcon : redIcon,
      anchor: Offset(0.5, 0.5),
    );
  }

  truckMarkerChanger(DocumentChange change) {
    if (change.document.documentID != currentUser.uid) {
      truckState = change.document['state'];
      markerId = MarkerId(change.document.documentID);
      markers[markerId] = Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: markerId,
        position:
            LatLng(change.document['latitude'], change.document['longitude']),
        infoWindow: InfoWindow(
          title: 'Truck',
          snippet: truckState == 'full'
              ? 'This truck is full.'
              : 'Collecting garbage.',
        ),
        icon: truckIcon,
        anchor: Offset(0.5, 0.5),
      );
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: new Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialLocation,
          markers: Set<Marker>.of(markers.values),
          polylines: _polylines,
          circles: Set.of((meCircle != null) ? [meCircle] : []),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            child: Icon(
              Icons.location_searching,
              color: Colors.black,
            ),
            onPressed: () {
              getCurrentLocation();
            }),
        bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom != 0
            ? null
            : BottomAppBar(
                color: Colors.orange,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            _scaffoldKey.currentState.openDrawer();
                          }),
                      RaisedButton(
                        textColor: Colors.orange,
                        disabledTextColor: Colors.orange,
                        disabledColor: Colors.orange,
                        color: Colors.white,
                        onPressed: () async {
                          if (isRideStarted == false) {
                            isRideStarted = true;
                            await getCurrentLocation();
                            locationUpdater(currentLocation);
                            truckState = "empty";
                          } else {
                            if (truckState == "empty") {
                              Firestore.instance
                                  .collection('Truck')
                                  .document('${currentUser.uid}')
                                  .updateData({"state": "full"}).then((value) {
                                setState(() {
                                  truckState = "full";
                                });
                              }).catchError((onError) {
                                print(onError);
                              });
                            } else if (truckState == "full") {
                              polylineCoordinates.clear();
                              isRideStarted = false;
                              navigation = false;
                              Firestore.instance
                                  .collection('Truck')
                                  .document('${currentUser.uid}')
                                  .delete()
                                  .then((value) {
                                setState(() {
                                  isRideStarted = false;
                                  navigation = false;
                                });
                              }).catchError((onError) {
                                print(onError);
                              });
                            }
                          }
                        },
                        child: isRideStarted == false
                            ? Text(
                                "Start Ride",
                                style: TextStyle(fontSize: 20),
                              )
                            : isRideStarted == true && truckState == 'empty'
                                ? Text(
                                    "Fully loaded",
                                    style: TextStyle(fontSize: 20),
                                  )
                                : Text(
                                    "End Ride",
                                    style: TextStyle(fontSize: 20),
                                  ),
                      ),
                    ]),
              ),
        drawer: MyDrawer(),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (isRideStarted) {
      ShowFlushbar.showMessage("End the ride before going back", context);
    }
    return true;
  }

  Future<void> setPolylines() async {
    navigation = true;
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        currentLocation.latitude,
        currentLocation.longitude,
        currentDestination.latitude,
        currentDestination.longitude);
    if (result.isNotEmpty) {
      polylineCoordinates.clear();
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        navigation = true;
        _polylines.add(Polyline(
            width: 2, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates));
      });
    }
  }
}
