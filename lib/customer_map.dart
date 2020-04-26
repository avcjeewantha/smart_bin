import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomerMap extends StatefulWidget {
  @override
  _CustomerMap createState() => _CustomerMap();
}

class _CustomerMap extends State<CustomerMap> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId markerId;
  String binState;
  BitmapDescriptor redIcon;
  BitmapDescriptor greenIcon;
  GoogleMapController mapController;
  StreamSubscription _locationSubscription;
  Marker meMarker;
  Circle meCircle;
  Location _locationTracker = Location();

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
          icon: BitmapDescriptor.defaultMarker);
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

  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
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
    getCurrentLocation();
    CollectionReference reference = Firestore.instance.collection('Bin');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        markerChanger(change);
      });
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(1, 1)), 'assets/images/redbin.png')
        .then((onValue) {
      redIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(1, 1)), 'assets/images/greenbin.png')
        .then((onValue) {
      greenIcon = onValue;
    });
  }

  markerChanger(DocumentChange change) {
    binState = change.document['state'];
    markerId = MarkerId(change.document.documentID);
    markers[markerId] = Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: markerId,
      position: LatLng(double.parse(change.document['latitude']),
          double.parse(change.document['longitude'])),
      infoWindow: InfoWindow(
        title: 'Dustbin',
        snippet: binState == 'empty' ? 'Empty' : 'Full',
      ),
      icon: binState == 'empty' ? greenIcon : redIcon,
      anchor: Offset(0.5, 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: initialLocation,
          markers: Set<Marker>.of(markers.values),
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
      ),
    );
  }
}
