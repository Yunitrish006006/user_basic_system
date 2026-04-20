/// user_basic_system
///
/// Reusable profile management and DM chat system for Flutter apps.
///
/// Usage:
/// 1. Implement [ProfileService] for your backend.
/// 2. Implement [DmService] for your chat backend.
/// 3. Use [ProfilePage] and [DmPage] widgets directly.
///
/// For localisation, pass [ProfileStrings.fromMap] / [DmStrings.fromMap]
/// with your existing translation map.
library user_basic_system;

export 'src/models/user_profile.dart';
export 'src/models/chat_message.dart';
export 'src/services/profile_service.dart';
export 'src/services/dm_service.dart';
export 'src/l10n/profile_strings.dart';
export 'src/l10n/dm_strings.dart';
export 'src/widgets/profile_page.dart';
export 'src/widgets/dm_page.dart';
export 'src/exceptions.dart';
