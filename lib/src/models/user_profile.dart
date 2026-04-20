/// Represents a user's profile data.
///
/// All avatar URL fields may be null if the user hasn't set that source.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.googleAvatarUrl,
    this.customAvatarUrl,
    this.uploadedAvatarUrl,
    this.avatarSource = 'google',
  });

  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? googleAvatarUrl;
  final String? customAvatarUrl;
  final String? uploadedAvatarUrl;

  /// One of: 'google', 'custom', 'upload'
  final String avatarSource;

  /// Returns the currently active avatar URL based on [avatarSource].
  String get effectiveAvatarUrl {
    switch (avatarSource) {
      case 'custom':
        return customAvatarUrl ?? '';
      case 'upload':
        return uploadedAvatarUrl ?? '';
      default:
        return googleAvatarUrl ?? '';
    }
  }

  UserProfile copyWith({
    String? name,
    String? bio,
    String? googleAvatarUrl,
    String? customAvatarUrl,
    String? uploadedAvatarUrl,
    String? avatarSource,
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      googleAvatarUrl: googleAvatarUrl ?? this.googleAvatarUrl,
      customAvatarUrl: customAvatarUrl ?? this.customAvatarUrl,
      uploadedAvatarUrl: uploadedAvatarUrl ?? this.uploadedAvatarUrl,
      avatarSource: avatarSource ?? this.avatarSource,
    );
  }
}
