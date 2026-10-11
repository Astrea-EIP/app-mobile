import 'dart:async';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';

/// Abstract contract for profile persistence and synchronization.
abstract class ProfileRepository {
  /// Persists or updates the accessibility profile.
  Future<void> saveProfile(AccessibilityProfile profile);

  /// Retrieves the current accessibility profile, if any.
  Future<AccessibilityProfile?> getProfile();
}

/// Mocked implementation simulating asynchronous backend API calls.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({
    this.simulatedDelay = const Duration(milliseconds: 600),
    this.shouldFail = false,
  });

  final Duration simulatedDelay;
  final bool shouldFail;

  AccessibilityProfile? _cachedProfile;

  @override
  Future<void> saveProfile(AccessibilityProfile profile) async {
    await Future<void>.delayed(simulatedDelay);
    if (shouldFail) {
      throw Exception('Failed to save accessibility profile. Please retry.');
    }
    _cachedProfile = profile;
  }

  @override
  Future<AccessibilityProfile?> getProfile() async {
    await Future<void>.delayed(simulatedDelay);
    if (shouldFail) {
      throw Exception('Failed to retrieve accessibility profile.');
    }
    return _cachedProfile;
  }
}
