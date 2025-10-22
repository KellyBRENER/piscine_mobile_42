import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position?> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<String> getCityFromPosition(Position? position) async {
  if (position == null) {
        return 'localisation non trouvée';
  }
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return place.locality ?? place.subAdministrativeArea ?? place.name ?? 'ville inconnue';
    }
    return 'localisation non trouvée';
  } catch(e) {
    print("erreur de geocodage : $e");
    return 'erreur de service de geolocalisation';
  }
}

// Fonction pour obtenir les coordonnées à partir du nom d'une ville
Future<Position?> getPositionFromCity(String city) async {
  try {
    // La fonction retourne une liste de "Location" (coordonnées potentielles)
    List<Location> locations = await locationFromAddress(city);

    if (locations.isNotEmpty) {
      Location location = locations.first;

      // Créer et retourner un objet Position simple
      return Position position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        // Les autres champs sont requis mais peuvent être à 0 ou 0.0
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
    return null;

  } catch (e) {
    print("Erreur de géocodage inverse: $e");
    return null;
  }
}
