import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomerMap extends StatefulWidget {
  @override
  _CustomerMap createState() => _CustomerMap();
}

class _CustomerMap extends State<CustomerMap> {
  GoogleMapController mapController;
  StreamSubscription _locationSubscription;
  Marker meMarker;
  Circle meCircle;
  Location _locationTracker = Location();

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(9.6615, 80.0255),
    zoom: 14.4746
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/me-marker.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocaldata, Uint8List imageData){
    LatLng latlng = LatLng(newLocaldata.latitude, newLocaldata.longitude);
    this.setState(() {
      meMarker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        draggable: false,
        zIndex: 2,
        icon: BitmapDescriptor.fromBytes(imageData) 
      );
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
    try{
        Uint8List imageData = await getMarker();
        var location = await _locationTracker.getLocation();
        updateMarkerAndCircle(location, imageData);
        
        if(_locationSubscription != null){
          _locationSubscription.cancel();
        }

        _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData){
          if(mapController != null){
            mapController.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 17.00)));
            updateMarkerAndCircle(newLocalData, imageData);
          }
        });
    } on PlatformException catch(e){
      if(e.code == "PERMISSION DENIED"){
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose(){
    if(_locationSubscription != null){
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: initialLocation,
          markers: Set.of((meMarker != null) ? [meMarker] : []),
          circles: Set.of((meCircle != null) ? [meCircle] : []),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: Icon(Icons.location_searching, 
            color: Colors.black,),
          onPressed: (){
            getCurrentLocation();
          }
        ),
      ),
    );
  }
}