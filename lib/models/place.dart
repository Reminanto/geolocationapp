import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Place {
  Place({required this.title, required this.image, 
  required this.location,
  String? id
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final File image;
  final Placelocation location;
}

class  Placelocation {
  const Placelocation(
      {required this.address, required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
  final String address;
}
