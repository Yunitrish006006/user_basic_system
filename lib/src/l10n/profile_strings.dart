/// Localisation strings for [ProfilePage].
///
/// All fields have English defaults. Override any subset you need.
///
/// For existing `Map<String, String>` translation maps use the convenience
/// factory [ProfileStrings.fromMap], which matches the same keys that the
/// taiwan_brawl translation system uses.
class ProfileStrings {
  const ProfileStrings({
    this.pageTitle = 'Profile',
    this.pleaseLogIn = 'Please log in first',
    this.avatarPreview = 'Avatar Preview',
    this.noAvatar = 'No avatar available',
    this.uploading = 'Uploading...',
    this.avatarSource = 'Avatar Source',
    this.custom = 'Custom',
    this.upload = 'Upload',
    this.googleAvatarDesc =
        'Use your Google sign-in avatar. It will sync again the next time you sign in.',
    this.customAvatarDesc =
        'Use your custom image URL. Future Google sign-ins will not overwrite it.',
    this.uploadAvatarDesc =
        'Use an uploaded image. Future Google sign-ins will not overwrite it.',
    this.customAvatarUrl = 'Custom Avatar URL',
    this.name = 'Name',
    this.bio = 'Bio',
    this.noGoogleAvatar =
        'This account does not have an available Google avatar.',
    this.fileBytesError = 'Selected file has no readable bytes',
    this.fileUnsupported = 'Selected image is unsupported',
    this.fileTooLarge = 'Image must be 1 MB or smaller',
    this.uploadSuccess = 'Avatar image uploaded successfully',
    this.removeSuccess = 'Avatar image removed successfully',
  });

  final String pageTitle;
  final String pleaseLogIn;
  final String avatarPreview;
  final String noAvatar;
  final String uploading;
  final String avatarSource;
  final String custom;
  final String upload;
  final String googleAvatarDesc;
  final String customAvatarDesc;
  final String uploadAvatarDesc;
  final String customAvatarUrl;
  final String name;
  final String bio;
  final String noGoogleAvatar;
  final String fileBytesError;
  final String fileUnsupported;
  final String fileTooLarge;
  final String uploadSuccess;
  final String removeSuccess;

  /// Build from an existing `Map<String, String>` translation map.
  /// Unrecognised keys fall back to English defaults.
  factory ProfileStrings.fromMap(Map<String, String> t) {
    String s(String key) => t[key] ?? key;
    return ProfileStrings(
      pageTitle: s('Profile'),
      pleaseLogIn: s('Please log in first'),
      avatarPreview: s('Avatar Preview'),
      noAvatar: s('No avatar available'),
      uploading: s('Uploading...'),
      avatarSource: s('Avatar Source'),
      custom: s('Custom'),
      upload: s('Upload'),
      googleAvatarDesc: s(
        'Use your Google sign-in avatar. It will sync again the next time you sign in.',
      ),
      customAvatarDesc: s(
        'Use your custom image URL. Future Google sign-ins will not overwrite it.',
      ),
      uploadAvatarDesc: s(
        'Use an uploaded image stored in Taiwan Brawl. You can pick a file from your device and future Google sign-ins will not overwrite it.',
      ),
      customAvatarUrl: s('Custom Avatar URL'),
      name: s('Name'),
      bio: s('Bio'),
      noGoogleAvatar: s(
        'This account does not have an available Google avatar.',
      ),
      fileBytesError: s('Selected file has no readable bytes'),
      fileUnsupported: s('Selected image is unsupported'),
      fileTooLarge: s('Image must be 1 MB or smaller'),
      uploadSuccess: s('Avatar image uploaded successfully'),
      removeSuccess: s('Avatar image removed successfully'),
    );
  }
}
