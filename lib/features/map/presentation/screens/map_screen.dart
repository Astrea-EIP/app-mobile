import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide UserLocation;
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/map/data/models/user_location.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';
import 'package:astrea/features/map/presentation/bloc/map_bloc.dart';
import 'package:astrea/features/map/presentation/bloc/map_event.dart';
import 'package:astrea/features/map/presentation/bloc/map_state.dart';
import 'package:astrea/features/map/presentation/widgets/location_fallback.dart';
import 'package:astrea/features/map/presentation/widgets/map_widgets.dart';

/// Builds the map surface for a position (overridden in widget tests).
typedef MapSurfaceBuilder =
    Widget Function(BuildContext context, UserLocation location);

/// Base map screen: centered on the user's position, with a fallback when the
/// permission is refused or the position is unavailable.
///
/// It creates its own [MapBloc] from [locationRepository] and asks for the
/// position as soon as it is displayed.
class MapScreen extends StatelessWidget {
  const MapScreen({
    required this.locationRepository,
    this.mapBuilder,
    super.key,
  });

  final LocationRepository locationRepository;

  /// Replaces the MapLibre map (a native view) with a stand-in in widget tests.
  @visibleForTesting
  final MapSurfaceBuilder? mapBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapBloc>(
      create: (BuildContext context) =>
          MapBloc(locationRepository: locationRepository)
            ..add(const MapLocationRequested()),
      child: _MapView(mapBuilder: mapBuilder),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({this.mapBuilder});

  final MapSurfaceBuilder? mapBuilder;

  @override
  Widget build(BuildContext context) {
    // The map is light: keep the status bar icons dark so they stay readable.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.page,
        body: Column(
          children: <Widget>[
            const MapHeader(),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _content(context)),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: SosButton(
                      onActivated: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "L'appel d'urgence arrive bientôt.",
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (BuildContext context, MapState state) {
        final MapBloc bloc = context.read<MapBloc>();
        switch (state.status) {
          case MapStatus.initial:
          case MapStatus.loading:
            return const ColoredBox(
              color: AppColors.map,
              child: _LoadingView(),
            );
          case MapStatus.located:
            return _LocatedMap(
              location: state.location!,
              mapBuilder: mapBuilder,
              onRecenter: () => bloc.add(const MapLocationRequested()),
            );
          case MapStatus.permissionDenied:
            return LocationFallback(
              icon: Icons.location_off_rounded,
              title: 'Localisation refusée',
              message:
                  'Astrea a besoin de votre position pour centrer la carte et préparer vos itinéraires. Vous pouvez autoriser la localisation à tout moment.',
              primaryLabel: 'Autoriser la localisation',
              onPrimary: () => bloc.add(const MapLocationRequested()),
            );
          case MapStatus.permissionDeniedForever:
            return LocationFallback(
              icon: Icons.location_off_rounded,
              title: 'Localisation désactivée',
              message:
                  "L'accès à votre position est bloqué pour Astrea. Activez-le dans les paramètres de l'application pour afficher la carte autour de vous.",
              primaryLabel: 'Ouvrir les paramètres',
              onPrimary: () => bloc.add(const MapAppSettingsRequested()),
              secondaryLabel: 'Réessayer',
              onSecondary: () => bloc.add(const MapLocationRequested()),
            );
          case MapStatus.serviceDisabled:
            return LocationFallback(
              icon: Icons.gps_off_rounded,
              title: 'GPS désactivé',
              message:
                  'Le service de localisation de votre appareil est éteint. Activez-le pour afficher votre position sur la carte.',
              primaryLabel: 'Activer la localisation',
              onPrimary: () => bloc.add(const MapLocationSettingsRequested()),
              secondaryLabel: 'Réessayer',
              onSecondary: () => bloc.add(const MapLocationRequested()),
            );
          case MapStatus.unavailable:
            return LocationFallback(
              icon: Icons.wrong_location_rounded,
              title: 'Position introuvable',
              message:
                  "Nous n'avons pas réussi à déterminer votre position. Vérifiez votre signal GPS ou votre connexion, puis réessayez.",
              primaryLabel: 'Réessayer',
              onPrimary: () => bloc.add(const MapLocationRequested()),
            );
        }
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Recherche de votre position en cours',
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: AppColors.primaryStrong),
            SizedBox(height: AppSpacing.md),
            ExcludeSemantics(
              child: Text(
                'Recherche de votre position…',
                style: AppTypography.corpsMd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocatedMap extends StatefulWidget {
  const _LocatedMap({
    required this.location,
    required this.onRecenter,
    this.mapBuilder,
  });

  final UserLocation location;
  final VoidCallback onRecenter;
  final MapSurfaceBuilder? mapBuilder;

  @override
  State<_LocatedMap> createState() => _LocatedMapState();
}

class _LocatedMapState extends State<_LocatedMap> {
  static const String _styleUrl =
      'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json';
  static const double _zoom = 17.5;
  // Astrea greens (AppColors.primaryStrong for the dot, primary for the halo).
  static const String _dotColor = '#2E7D32';
  static const String _haloColor = '#4CAF50';

  MapLibreMapController? _controller;
  Circle? _halo;
  Circle? _dot;

  LatLng get _position =>
      LatLng(widget.location.latitude, widget.location.longitude);

  @override
  void didUpdateWidget(covariant _LocatedMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _showPosition();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Brings the camera back on the last known position right away (the
  /// refreshed position is not emitted when it did not change), then asks for
  /// a fresh one.
  Future<void> _recenter() async {
    widget.onRecenter();
    try {
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(_position, _zoom),
      );
    } catch (error) {
      debugPrint('Map: unable to recenter: $error');
    }
  }

  Future<void> _showPosition() async {
    final MapLibreMapController? controller = _controller;
    if (controller == null) {
      return;
    }
    try {
      if (_halo == null || _dot == null) {
        _halo = await controller.addCircle(
          CircleOptions(
            geometry: _position,
            circleRadius: 22,
            circleColor: _haloColor,
            circleOpacity: 0.3,
          ),
        );
        _dot = await controller.addCircle(
          CircleOptions(
            geometry: _position,
            circleRadius: 9,
            circleColor: _dotColor,
            circleStrokeWidth: 3,
            circleStrokeColor: '#FFFFFF',
          ),
        );
      } else {
        await controller.updateCircle(
          _halo!,
          CircleOptions(geometry: _position),
        );
        await controller.updateCircle(
          _dot!,
          CircleOptions(geometry: _position),
        );
      }
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_position, _zoom),
      );
    } catch (error) {
      debugPrint('Map: unable to draw the position: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final MapSurfaceBuilder? mapBuilder = widget.mapBuilder;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: mapBuilder != null
              ? mapBuilder(context, widget.location)
              : MapLibreMap(
                  styleString: _styleUrl,
                  initialCameraPosition: CameraPosition(
                    target: _position,
                    zoom: _zoom,
                  ),
                  onMapCreated: (MapLibreMapController controller) =>
                      _controller = controller,
                  onStyleLoadedCallback: () {
                    // A new style drops the overlays: draw them again.
                    _halo = null;
                    _dot = null;
                    _showPosition();
                  },
                  myLocationEnabled: false,
                  compassEnabled: true,
                  translucentTextureSurface: true,
                ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.paddingOf(context).bottom,
          child: Semantics(
            button: true,
            label: 'Recentrer la carte sur ma position',
            excludeSemantics: true,
            child: FloatingActionButton(
              heroTag: 'recenter',
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.ink,
              onPressed: _recenter,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
