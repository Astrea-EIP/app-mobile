import 'dart:async';

import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';

/// Production implementation of [ProfileRepository].
///
/// The backend has no profile-storage endpoint yet, so the profile is kept
/// in memory. On [saveProfile] the anonymous token is pre-fetched in the
/// background: the user never waits on the network, and if the API is
/// unreachable the token is simply requested again on the first itinerary
/// call.
class HttpProfileRepository implements ProfileRepository {
  HttpProfileRepository({required AstreaApiClient apiClient})
    : _apiClient = apiClient;

  final AstreaApiClient _apiClient;
  AccessibilityProfile? _cachedProfile;

  @override
  Future<void> saveProfile(AccessibilityProfile profile) async {
    _cachedProfile = profile;
    unawaited(_warmUpToken());
  }

  Future<void> _warmUpToken() async {
    try {
      await _apiClient.ensureAuthenticated();
    } on Object {
      // Best-effort warm-up only.
    }
  }

  @override
  Future<AccessibilityProfile?> getProfile() async {
    return _cachedProfile;
  }
}
