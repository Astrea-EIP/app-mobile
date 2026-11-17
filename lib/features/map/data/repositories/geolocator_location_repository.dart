import 'package:geolocator/geolocator.dart' as geo;
import 'package:astrea/features/map/data/models/location_exceptions.dart';
import 'package:astrea/features/map/data/models/user_location.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';

/// [LocationRepository] backed by the `geolocator` plugin.
class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository({
    this.timeLimit = const Duration(seconds: 15),
  });

  final Duration timeLimit;

  @override
  Future<UserLocation> getCurrentLocation() async {
    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceDisabledException();
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      switch (permission) {
        case geo.LocationPermission.denied:
          throw const LocationPermissionDeniedException();
        case geo.LocationPermission.deniedForever:
          throw const LocationPermissionDeniedForeverException();
        case geo.LocationPermission.whileInUse:
        case geo.LocationPermission.always:
        case geo.LocationPermission.unableToDetermine:
          break;
      }

      final geo.Position position = await geo.Geolocator.getCurrentPosition(
        locationSettings: geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationException {
      rethrow;
    } on geo.PermissionDeniedException catch (error) {
      throw LocationPermissionDeniedException(error.message ?? '');
    } on geo.LocationServiceDisabledException {
      throw const LocationServiceDisabledException();
    } catch (error) {
      throw LocationUnavailableException(error.toString());
    }
  }

  @override
  Future<bool> openAppSettings() => geo.Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => geo.Geolocator.openLocationSettings();
}
