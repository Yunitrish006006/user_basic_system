## 0.1.1

- Fix: avatar preview no longer oscillates when switching avatar source while auto-save is in flight

## 0.1.0

- Initial release
- `UserProfile`: model for profile data with `effectiveAvatarUrl` getter
- `ChatMessage`: model for DM messages with `fromJson`, `copyWith`, `messageKey`
- `ProfileService`: abstract `ChangeNotifier` interface with `updateProfile`, `uploadAvatarImage`, `deleteAvatarImage`
- `DmService`: abstract interface with 8 chat operations (send, recall, fetch, sync, upload, download)
- `ProfilePage`: full-featured profile widget with auto-save (1.5 s debounce), avatar source switching, and file-picker upload
- `DmPage`: full-featured DM chat widget with polling, message recall, and cross-device sync
- `ProfileStrings` / `DmStrings`: localisation helpers with English defaults and `fromMap()` factory
- `UserSystemException`: user-facing exception type for service implementations
