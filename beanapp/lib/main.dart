import 'package:beanapp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final Map<String, String> _markersValues = {};

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location Map'),
      ),
      body: FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          return currentPosLoaded
              ? GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentPos.latitude, currentPos.longitude),
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  onLongPress: (LatLng position) {
                    setState(
                      () {
                        _markers.add(
                          Marker(
                            markerId: MarkerId(position.toString()),
                            position: position,
                            // onTap: () {
                            //   showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return AlertDialog(
                            //         title: const Text('Marker Tapped'),
                            //         content: const Text(
                            //             'Do you want to remove this marker?'),
                            //         actions: <Widget>[
                            //           TextButton(
                            //             child: const Text('Cancel'),
                            //             onPressed: () {
                            //               Navigator.of(context).pop();
                            //             },
                            //           ),
                            //           TextButton(
                            //             child: const Text('Remove'),
                            //             onPressed: () {
                            //               _removeMarker(position.toString());
                            //               Navigator.of(context).pop();
                            //             },
                            //           ),
                            //         ],
                            //       );
                            //     },
                            //   );
                            // },
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String mapValue = "";
                                  return AlertDialog(
                                    content: const Text('Add Value to Marker'),
                                    actions: <Widget>[
                                      TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            mapValue = value;
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              setState(
                                                () {
                                                  _markersValues[position
                                                      .toString()] = mapValue;
                                                },
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                              print(_markersValues.values);
                            },
                          ),
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
        },
      ),
    );
  }
}
