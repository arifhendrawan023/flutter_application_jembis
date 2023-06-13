import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LihatMapPage extends StatefulWidget {
  final LatLng koordinatTempat;
  final String namaTempat;

  const LihatMapPage({Key? key, required this.koordinatTempat, required this.namaTempat})
      : super(key: key);

  @override
  _LihatMapPageState createState() => _LihatMapPageState();
}

class _LihatMapPageState extends State<LihatMapPage> {
  late LatLng koordinat;
  GoogleMapController? mapController; //controller for Google map
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDIxtidxNLZkYjxPOv9Ik0QhkuNwEgNQwM";

  Set<Marker> markers = {}; //markers for Google Map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  LatLng startLocation = const LatLng(-8.168313120170373, 113.70175981984788);
  LatLng endLocation = const LatLng(27.6683619, 85.3101895);


  @override
  void initState() {
    markers.add(
      Marker(
        //add destination location marker
        markerId: const MarkerId('endLocation'),
        position: endLocation, //position of marker
        infoWindow: const InfoWindow(
          //popup info
          title: 'Destination Point',
          snippet: 'Destination Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ),
    );

    getDirections(); //fetch direction polylines from Google API

    super.initState();
    koordinat = widget.koordinatTempat;
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR$error");
    });
    return await Geolocator.getCurrentPosition();
  }

  getDirections() async {
  List<LatLng> polylineCoordinates = [];

  Position userPosition = await getUserCurrentLocation();

  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleAPiKey,
    PointLatLng(widget.koordinatTempat.latitude, widget.koordinatTempat.longitude),
    PointLatLng(userPosition.latitude, userPosition.longitude),
    travelMode: TravelMode.driving,
  );

  if (result.points.isNotEmpty) {
    for (var point in result.points) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    }
  } else {
    print(result.errorMessage);
  }
  addPolyLine(polylineCoordinates);
}


  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.orange,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaTempat),
        backgroundColor: Colors.orange,
      ),
      body: GoogleMap(
        zoomGesturesEnabled: true,
        initialCameraPosition: CameraPosition(
          target: koordinat, 
          zoom: 16.0, 
        ),
        markers: markers, 
        polylines: Set<Polyline>.of(polylines.values), 
        mapType: MapType.normal, 
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
      ),
    );
  }
}
