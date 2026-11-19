/// Friends/DM public surface, independent of account login internals.
///
/// Compatibility facade: implementation still lives in user_basic_system.
/// The host app injects a DmService and provides its own authentication.
export 'src/models/chat_message.dart';
export 'src/services/dm_service.dart';
export 'src/l10n/dm_strings.dart';
export 'src/widgets/dm_page.dart';
export 'src/exceptions.dart';
