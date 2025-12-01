import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position?> determinePosition() async {
  LocationPermission permission;
  bool serviceEnabled;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("GPS désactivé");
    //return Future.error("GPS désactivé");
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("l'accés à la géolocalisation a été refusée");
      // return Future.error("l'accés à la géolocalisation a été refusée");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception("l'accés à la géolocalisation a été définitivement refusé. Pour l'activer, allez dans les paramètres de l'application");
    // return Future.error("l'accés à la géolocalisation a été définitivement refusé. Pour l'activer, allez dans les paramètres de l'application");
  }

  return await Geolocator.getCurrentPosition();
}

//détermine la localité à partir des coordonnées, toujours la placer dans un try/catch
Future<Map<String, dynamic>?> getCityFromPosition(Position? position) async {
  if (position == null) {
    throw Exception("aucune position n'a été trouvée, la ville correspondante ne peut être trouvée");
        // return null;
  }
  List<Placemark> placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
    );
  if (placemarks.isNotEmpty) {
    Placemark place = placemarks.first;
    return {'name' : place.locality ?? place.subAdministrativeArea ?? 'ville inconnue',
    'admin' : place.administrativeArea ?? 'région inconnue',
    'country' : place.country ?? 'pays inconnu',
    'lat' : position.latitude, 'lon' : position.longitude
    };
  } else {
    throw Exception("aucune localité n'a été trouvée pour cette position");
  }
}

// Fonction pour obtenir les coordonnées à partir du nom d'une ville
Future<List<double>?> getPositionFromCity(String city) async {
  try {
    // La fonction retourne une liste de "Location" (coordonnées potentielles)
    List<Location> locations = await locationFromAddress(city);

    if (locations.isNotEmpty) {
      // Créer et retourner un objet Position simple
      return [locations.first.latitude, locations.first.longitude];
    }
    return null;

  } catch (e) {
    print("Erreur de géocodage inverse: $e");
    return null;
  }
}
