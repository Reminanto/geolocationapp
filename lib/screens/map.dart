import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oko/models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const Placelocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '', // Changed to constant empty string to allow const constructor
    ),
    this.isSelecting = true,
  });

  final Placelocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'PICK YOUR LOCATION' : 'YOUR LOCATION'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(pickedLocation);
              },
              icon: const Icon(Icons.save),
            )
        ],
      ),
      body: GoogleMap(
        onTap: widget.isSelecting == false
            ? null
            : (position) {
                setState(() {
                  pickedLocation = position;
                });
              },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.location.latitude, widget.location.longitude),
          zoom: 16,
        ),
        markers: (pickedLocation == null && widget.isSelecting == true)
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: pickedLocation != null
                      ? pickedLocation!
                      : LatLng(widget.location.latitude,
                          widget.location.longitude),
                ),
              },
      ),
    );
  }
}
