import 'package:flutter/material.dart';

import 'package:oko/models/place.dart';
import 'package:oko/screens/map.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;
  final String _apiKey = 'AIzaSyBGCs1b8NQfNn3N1Aomk2iSsWl7zFCUw1M';

  String get locationImage {
    final lat = place.location.latitude;
    final lng = place.location.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=18&size=680x360&maptype=roadmap&markers=color:blue%7Clabel:A%7C$lat,$lng&key=$_apiKey';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(place.title),
        ),
        body: Stack(
          children: [
            Image.file(
              place.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => MapScreen(location: place.location,isSelecting: false,)));
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(locationImage),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black54],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      alignment: Alignment.center,
                      child: Text(
                        place.location.address,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
