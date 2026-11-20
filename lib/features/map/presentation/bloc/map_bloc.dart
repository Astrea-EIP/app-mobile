import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/features/map/data/models/location_exceptions.dart';
import 'package:astrea/features/map/data/models/user_location.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';
import 'package:astrea/features/map/presentation/bloc/map_event.dart';
import 'package:astrea/features/map/presentation/bloc/map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required LocationRepository locationRepository})
    : _locationRepository = locationRepository,
      super(const MapState()) {
    on<MapLocationRequested>(_onLocationRequested);
    on<MapAppSettingsRequested>(
      (MapAppSettingsRequested event, Emitter<MapState> emit) =>
          _locationRepository.openAppSettings(),
    );
    on<MapLocationSettingsRequested>(
      (MapLocationSettingsRequested event, Emitter<MapState> emit) =>
          _locationRepository.openLocationSettings(),
    );
  }

  final LocationRepository _locationRepository;

  Future<void> _onLocationRequested(
    MapLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    // Refreshing from a displayed map keeps it on screen (no spinner).
    if (state.status != MapStatus.located) {
      emit(const MapState(status: MapStatus.loading));
    }
    try {
      final UserLocation location = await _locationRepository
          .getCurrentLocation();
      emit(MapState(status: MapStatus.located, location: location));
    } on LocationPermissionDeniedForeverException {
      emit(const MapState(status: MapStatus.permissionDeniedForever));
    } on LocationPermissionDeniedException {
      emit(const MapState(status: MapStatus.permissionDenied));
    } on LocationServiceDisabledException {
      emit(const MapState(status: MapStatus.serviceDisabled));
    } on LocationException {
      emit(const MapState(status: MapStatus.unavailable));
    }
  }
}
