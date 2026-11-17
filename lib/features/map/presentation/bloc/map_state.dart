import 'package:equatable/equatable.dart';
import 'package:astrea/features/map/data/models/user_location.dart';

enum MapStatus {
  initial,
  loading,
  located,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  unavailable,
}

class MapState extends Equatable {
  const MapState({this.status = MapStatus.initial, this.location});

  final MapStatus status;
  final UserLocation? location;

  @override
  List<Object?> get props => <Object?>[status, location];
}
