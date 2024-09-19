import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:oko/models/place.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  // Method to get the database instance
  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user_places('
          'id TEXT PRIMARY KEY, '
          'title TEXT, '
          'image TEXT, '
          'lat REAL, '
          'lng REAL, '
          'address TEXT)',
        );
      },
      version: 1,
    );
  }

  // Method to add a place and store it in SQLite
  Future<void> addPlace(String title, File image, Placelocation location) async {
    // Get the app's documents directory
    final appDir = await syspath.getApplicationDocumentsDirectory();

    // Copy the image file to the app's directory
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    // Create a new place object
    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    // Get the database instance
    final db = await _getDatabase();

    // Insert the new place into the database
    await db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace, // Handle conflicts
    );

    // Update the state with the new place
    state = [newPlace, ...state];
  }

  // Method to fetch and set places from the database
  Future<void> fetchAndSetPlaces() async {
    final db = await _getDatabase();
    final dataList = await db.query('user_places');

    // Update the state with the fetched places
    state = dataList
        .map(
          (item) => Place(
            id: item['id'] as String,
            title: item['title'] as String,
            image: File(item['image'] as String),
            location: Placelocation(
              latitude: item['lat'] as double,
              longitude: item['lng'] as double,
              address: item['address'] as String,
            ),
          ),
        )
        .toList();
  }
}

// Riverpod provider for UserPlacesNotifier
final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
