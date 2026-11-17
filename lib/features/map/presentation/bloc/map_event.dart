import 'package:equatable/equatable.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Asks the permission if needed and (re)centers the map on the user.
final class MapLocationRequested extends MapEvent {
  const MapLocationRequested();
}

/// Opens the app settings (permission refused for good).
final class MapAppSettingsRequested extends MapEvent {
  const MapAppSettingsRequested();
}

/// Opens the system location settings (GPS switched off).
final class MapLocationSettingsRequested extends MapEvent {
  const MapLocationSettingsRequested();
}
