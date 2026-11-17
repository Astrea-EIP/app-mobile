import 'package:astrea/features/map/data/models/user_location.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';

/// In-memory [LocationRepository] returning [result] or throwing [error].
class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({this.result, this.error});

  UserLocation? result;
  Exception? error;
  int locationCalls = 0;
  int appSettingsCalls = 0;
  int locationSettingsCalls = 0;

  @override
  Future<UserLocation> getCurrentLocation() async {
    locationCalls++;
    if (error != null) {
      throw error!;
    }
    return result!;
  }

  @override
  Future<bool> openAppSettings() async {
    appSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsCalls++;
    return true;
  }
}
