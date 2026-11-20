import 'package:equatable/equatable.dart';

/// Geographic position of the user, independent from any location plugin.
class UserLocation extends Equatable {
  const UserLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => <Object?>[latitude, longitude];
}
