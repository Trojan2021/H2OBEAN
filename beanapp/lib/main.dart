import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomMarker {
  int ppm;
  LatLng position;
  String id;

  CustomMarker({
    required this.ppm,
    required this.position,
    required this.id,
  });
}

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapControl;
  late Position currentPos;
  bool currentPosLoaded = false;
  final Set<Marker> _markers = {};

  final List<CustomMarker> exampleMarkers = [
    CustomMarker(
        ppm: 150,
        position: const LatLng(40.7128, -74.0060),
        id: 'ExampleMark1'),
    CustomMarker(
        ppm: 268,
        position: const LatLng(34.0522, -118.2437),
        id: 'ExampleMark2'),
    CustomMarker(
        ppm: 900,
        position: const LatLng(41.8781, -87.6298),
        id: 'ExampleMark3'),
  ];

  void _onMapCreated(GoogleMapController control) {
    setState(() {
      mapControl = control;
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPos = position;
      currentPosLoaded = true;
    });
  }

  void _removeMarker(String markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
    });
  }

  void _removeMarkerFromData(LatLng position) async {
    const String apiUrl = 'http://127.0.0.1:5000/deletemarker';
    String latitude = "${position.latitude}";
    final response =
        await http.post(Uri.parse(apiUrl), body: {'data': latitude});
    if (response.statusCode == 200) {
      print('Data sent successfully!');
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  }

  String _qualityChecking(int ppm) {
    if (ppm <= 150) {
      return 'Excellent';
    } else if (ppm > 150 && ppm <= 250) {
      return 'Good';
    } else if (ppm > 250 && ppm <= 300) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  void _loadingMarkers() {
    for (int i = 0; i < exampleMarkers.length; i++) {
      String quality = _qualityChecking(exampleMarkers[i].ppm);
      _markers.add(
        Marker(
          markerId: MarkerId(exampleMarkers[i].id),
          position: exampleMarkers[i].position,
          infoWindow: InfoWindow(
            title: 'Level: $quality',
            snippet: '${exampleMarkers[i].ppm} ppm',
          ),
        ),
      );
    }
  }

  void _loadingMarkersFromData(List<dynamic> jsonData) {
    for (int i = 0; i < jsonData.length; i++) {
      Map<String, dynamic> markerData = jsonData[i];
      print(markerData);
      String quality = _qualityChecking(markerData['ppmValue']);
      _markers.add(
        Marker(
          markerId: MarkerId('${i}marker'),
          position: LatLng(markerData['lat'], markerData['long']),
          infoWindow: InfoWindow(
            title: 'Level: $quality',
            snippet: '${markerData['ppmValue']} ppm',
          ),
        ),
      );
    }
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/getnew'));
    String responseBody = response.body;
    List<dynamic> jsonData = json.decode(responseBody);
    _loadingMarkersFromData(jsonData);
  }

  Future<void> _sendDataToServer(LatLng data) async {
    const String apiUrl = 'http://127.0.0.1:5000/endpoint';
    String latlong = "${data.latitude},${data.longitude}";
    final response =
        await http.post(Uri.parse(apiUrl), body: {'data': latlong});
    if (response.statusCode == 200) {
      print('Data sent successfully!');
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchData();
    _loadingMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          title: const Text('Water Quality Map'),
        ),
        body: FutureBuilder(
          future: _getCurrentLocation(),
          builder: (context, snapshot) {
            return currentPosLoaded
                ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentPos.latitude, currentPos.longitude),
                      zoom: 5.0,
                    ),
                    markers: _markers,
                    onLongPress: (LatLng position) {
                      _sendDataToServer(position);
                      setState(
                        () {
                          _markers.add(
                            Marker(
                              markerId: MarkerId(position.toString()),
                              position: position,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Marker Tapped'),
                                      content: const Text(
                                          'Do you want to remove this marker?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Remove'),
                                          onPressed: () {
                                            _removeMarker(position.toString());
                                            _removeMarkerFromData(position);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
          },
        ),
      ),
    );
  }
}
