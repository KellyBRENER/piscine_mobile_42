import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position?> determinePosition() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error("l'accés à la géolocalisation a été refusée");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error("l'accés à la géolocalisation a été définitivement refusé. Pour l'activer, allez dans les paramètres de l'application");
  }

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
Future<Location?> getPositionFromCity(String city) async {
  try {
    // La fonction retourne une liste de "Location" (coordonnées potentielles)
    List<Location> locations = await locationFromAddress(city);

    if (locations.isNotEmpty) {
      // Créer et retourner un objet Position simple
      return locations.first;
    }
    return null;

  } catch (e) {
    print("Erreur de géocodage inverse: $e");
    return null;
  }
}
