import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

/// Abstract service for profile-related operations.
///
/// Extend [ChangeNotifier] so [ProfilePage] can listen for changes.
///
/// Throw [UserSystemException] (from `exceptions.dart`) for user-facing errors.
///
/// Example implementation:
/// ```dart
/// class MyProfileService extends ProfileService {
///   @override
///   UserProfile? get profile => _profile;
///
///   @override
///   Future<void> updateProfile({...}) async {
///     await myApi.updateProfile(...);
///     notifyListeners();
///   }
/// }
/// ```
abstract class ProfileService extends ChangeNotifier {
  /// The currently authenticated user's profile, or null if not authenticated.
  UserProfile? get profile;

  /// Update profile fields.
  ///
  /// Should call [notifyListeners] after the update so the UI rebuilds.
  Future<void> updateProfile({
    required String name,
    required String bio,
    required String avatarSource,
    required String customAvatarUrl,
  });

  /// Upload a new avatar image as base-64 encoded bytes.
  ///
  /// Should call [notifyListeners] after the upload so the UI rebuilds.
  Future<void> uploadAvatarImage({
    required String bytesBase64,
    required String contentType,
    String? fileName,
  });

  /// Remove the uploaded avatar image.
  ///
  /// Should call [notifyListeners] after removal so the UI rebuilds.
  Future<void> deleteAvatarImage();
}
