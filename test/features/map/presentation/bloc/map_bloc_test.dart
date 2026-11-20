import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/map/data/models/location_exceptions.dart';
import 'package:astrea/features/map/data/models/user_location.dart';
import 'package:astrea/features/map/presentation/bloc/map_bloc.dart';
import 'package:astrea/features/map/presentation/bloc/map_event.dart';
import 'package:astrea/features/map/presentation/bloc/map_state.dart';
import '../../fake_location_repository.dart';

void main() {
  const UserLocation paris = UserLocation(latitude: 48.8566, longitude: 2.3522);

  Future<List<MapState>> run(
    FakeLocationRepository repository,
    MapEvent event,
  ) async {
    final MapBloc bloc = MapBloc(locationRepository: repository);
    final List<MapState> states = <MapState>[];
    final StreamSubscription<MapState> subscription = bloc.stream.listen(
      states.add,
    );
    bloc.add(event);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await bloc.close();
    return states;
  }

  group('MapBloc', () {
    test('starts in the initial state', () async {
      final MapBloc bloc = MapBloc(
        locationRepository: FakeLocationRepository(result: paris),
      );
      expect(bloc.state.status, MapStatus.initial);
      await bloc.close();
    });

    test('emits loading then located with the user position', () async {
      final List<MapState> states = await run(
        FakeLocationRepository(result: paris),
        const MapLocationRequested(),
      );
      expect(states, const <MapState>[
        MapState(status: MapStatus.loading),
        MapState(status: MapStatus.located, location: paris),
      ]);
    });

    final Map<String, (Exception, MapStatus)> failures =
        <String, (Exception, MapStatus)>{
          'permission denied': (
            const LocationPermissionDeniedException(),
            MapStatus.permissionDenied,
          ),
          'permission denied forever': (
            const LocationPermissionDeniedForeverException(),
            MapStatus.permissionDeniedForever,
          ),
          'service disabled': (
            const LocationServiceDisabledException(),
            MapStatus.serviceDisabled,
          ),
          'position unavailable': (
            const LocationUnavailableException('timeout'),
            MapStatus.unavailable,
          ),
        };
    failures.forEach((String name, (Exception, MapStatus) value) {
      test('maps $name to ${value.$2.name}', () async {
        final List<MapState> states = await run(
          FakeLocationRepository(error: value.$1),
          const MapLocationRequested(),
        );
        expect(states.last, MapState(status: value.$2));
      });
    });

    test('refreshing a located map does not go back to loading', () async {
      final FakeLocationRepository repository = FakeLocationRepository(
        result: paris,
      );
      final MapBloc bloc = MapBloc(locationRepository: repository);
      bloc.add(const MapLocationRequested());
      await Future<void>.delayed(Duration.zero);

      final List<MapState> states = <MapState>[];
      final StreamSubscription<MapState> subscription = bloc.stream.listen(
        states.add,
      );
      repository.result = const UserLocation(latitude: 1, longitude: 2);
      bloc.add(const MapLocationRequested());
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      await bloc.close();

      expect(states.map((MapState s) => s.status), <MapStatus>[
        MapStatus.located,
      ]);
      expect(states.single.location?.latitude, 1);
    });

    test('can recover after a refusal', () async {
      final FakeLocationRepository repository = FakeLocationRepository(
        error: const LocationPermissionDeniedException(),
      );
      final MapBloc bloc = MapBloc(locationRepository: repository);
      bloc.add(const MapLocationRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.status, MapStatus.permissionDenied);

      repository
        ..error = null
        ..result = paris;
      bloc.add(const MapLocationRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.status, MapStatus.located);
      await bloc.close();
    });

    test('opens the settings through the repository', () async {
      final FakeLocationRepository repository = FakeLocationRepository(
        result: paris,
      );
      await run(repository, const MapAppSettingsRequested());
      await run(repository, const MapLocationSettingsRequested());
      expect(repository.appSettingsCalls, 1);
      expect(repository.locationSettingsCalls, 1);
    });
  });
}
