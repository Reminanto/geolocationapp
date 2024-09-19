import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:oko/models/place.dart';
import 'package:oko/screens/map.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onselectlocation});
  final void Function(Placelocation location) onselectlocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  Placelocation? _pickedLocation;
  var _isGettingLocation = false;
  Location location = Location();
  final String _apiKey =
      'AIzaSyBGCs1b8NQfNn3N1Aomk2iSsWl7zFCUw1M'; // Define your API key here

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }

    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=18&size=680x360&maptype=roadmap&markers=color:blue%7Clabel:A%7C$lat,$lng&key=$_apiKey';
  }

  Future<void> savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        final address = resData['results'][0]['formatted_address'];

        setState(() {
          _pickedLocation =
              Placelocation(address: address, latitude: latitude, longitude: longitude);
          _isGettingLocation = false;
        });
      } else {
        // Handle non-200 responses
       // print('Failed to fetch address');
      }
    } catch (error) {
      // Handle errors
     // print('Error fetching location: $error');
    }
    if (_pickedLocation != null) {
      widget.onselectlocation(_pickedLocation!);
    }

    setState(() {
      _isGettingLocation = false;
    });
  }

  void _currentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if the service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Fetch location data
    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    savePlace(lat, lng);
  }

  void _selectonmap() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final _pickedLocation = await Navigator.of(context)
        .push<LatLng>(MaterialPageRoute(builder: (ctx) =>  const MapScreen()));
    if (_pickedLocation == null) {
      return;
    }

    savePlace(_pickedLocation.latitude, _pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = const Text(
      'No Location Selected',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.amber),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3))),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _currentLocation,
              label: const Text('Get Current Location'),
              icon: const Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: _selectonmap,
              label: const Text('Select on Map'),
              icon: const Icon(Icons.map),
            )
          ],
        )
      ],
    );
  }
}
