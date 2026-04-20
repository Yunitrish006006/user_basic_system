# user_basic_system

> 📖 [繁體中文說明請看這裡 →](README.zh-TW.md)

Reusable profile management and DM chat system for Flutter apps, built around abstract service interfaces.

## Features

- **`ProfileService`** — abstract `ChangeNotifier` interface; implement once per backend
- **`DmService`** — abstract interface for direct-message chat; implement once per backend
- **`ProfilePage`** — full-featured profile widget with auto-save (1.5 s debounce), avatar source switching (Google / Custom URL / Uploaded), and file-picker upload
- **`DmPage`** — full-featured DM chat widget with polling, message recall, and cross-device sync
- **`ProfileStrings` / `DmStrings`** — all UI text in English by default; override any subset or use `fromMap()` with an existing translation map
- **`UserSystemException`** — user-facing exception type for service error propagation

## Getting started

```yaml
dependencies:
  user_basic_system: ^0.1.0
```

## Usage

### 1. Implement the abstract services

```dart
import 'package:user_basic_system/user_basic_system.dart';

class MyProfileService extends ChangeNotifier implements ProfileService {
  UserProfile? _profile;

  @override
  UserProfile? get profile => _profile;

  @override
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? customAvatarUrl,
    String? avatarSource,
  }) async {
    try {
      await myApi.updateProfile(name: name, bio: bio, ...);
      _profile = _profile?.copyWith(name: name, bio: bio, ...);
      notifyListeners();
    } on ApiException catch (e) {
      throw UserSystemException(e.message);
    }
  }

  @override
  Future<void> uploadAvatarImage(Uint8List bytes) async {
    try {
      final url = await myApi.uploadAvatar(bytes);
      _profile = _profile?.copyWith(uploadedAvatarUrl: url);
      notifyListeners();
    } on ApiException catch (e) {
      throw UserSystemException(e.message);
    }
  }

  @override
  Future<void> deleteAvatarImage() async {
    try {
      await myApi.deleteAvatar();
      _profile = _profile?.copyWith(uploadedAvatarUrl: null);
      notifyListeners();
    } on ApiException catch (e) {
      throw UserSystemException(e.message);
    }
  }
}

class MyChatService implements DmService {
  // implement the 8 DmService methods …
}
```

### 2. Register providers

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProfileService()),
    Provider(create: (_) => MyChatService()),
  ],
  child: MyApp(),
);
```

### 3. Use the widgets

```dart
import 'package:user_basic_system/user_basic_system.dart';

// Profile page
ProfilePage(
  service: context.read<MyProfileService>(),
  strings: ProfileStrings(),        // English defaults
  // strings: ProfileStrings.fromMap(myTranslationMap),
  extraContent: const MySettingsPanel(),  // optional extra UI below profile
)

// DM page
DmPage(
  service: context.read<MyChatService>(),
  selfId: currentUser.id,
  friendId: friend.id,
  strings: DmStrings(),
  onActiveConversationChanged: (friendId) {
    notificationService.setActiveConversation(friendId);
  },
)
```

### 4. Localisation with an existing translation map

If your app already has a `Map<String, String>` translation system, pass it directly:

```dart
final t = context.watch<LocaleProvider>().translation;

ProfilePage(
  service: myProfileService,
  strings: ProfileStrings.fromMap(t),
)

DmPage(
  service: myChatService,
  selfId: selfId,
  friendId: friendId,
  strings: DmStrings.fromMap(t),
)
```

The `fromMap()` factories use matching keys from your map, falling back to built-in English defaults for any missing keys.

---

## API reference

### `ProfileService` (abstract)

| Member | Description |
|--------|-------------|
| `UserProfile? get profile` | Current user profile, null if not authenticated |
| `Future<void> updateProfile({name, bio, customAvatarUrl, avatarSource})` | Persist profile changes |
| `Future<void> uploadAvatarImage(Uint8List bytes)` | Upload and persist avatar image |
| `Future<void> deleteAvatarImage()` | Remove uploaded avatar |

### `DmService` (abstract)

| Member | Description |
|--------|-------------|
| `Stream<ChatMessage> get messageStream` | Incoming message stream |
| `Future<List<ChatMessage>> fetchHistory(selfId, friendId)` | Load local history |
| `Future<List<ChatMessage>> syncFromServer(selfId, friendId)` | Force server sync |
| `Future<void> sendMessage(friendId, text)` | Send a text message |
| `Future<void> recallMessage(messageId)` | Recall a sent message |
| `Future<void> uploadMessages(selfId, friendId, messages)` | Upload local messages to server |
| `Future<List<ChatMessage>> downloadMessages(selfId, friendId)` | Download messages from server |
| `Future<void> clearLocalMessages(selfId, friendId)` | Clear locally cached messages |

### `UserProfile`

```dart
UserProfile({
  required int id,
  required String name,
  required String email,
  String? bio,
  String? googleAvatarUrl,
  String? customAvatarUrl,
  String? uploadedAvatarUrl,
  String avatarSource,   // 'google' | 'custom' | 'upload'
})

String get effectiveAvatarUrl  // resolves the active avatar URL
```

### `ChatMessage`

```dart
ChatMessage({
  required int id,
  required int senderId,
  required int receiverId,
  required String content,
  required DateTime createdAt,
  bool recalled,
})

factory ChatMessage.fromJson(Map<String, dynamic> json)
ChatMessage copyWith({...})
String get messageKey   // unique deduplication key
```

---

## Exception handling

Services should throw `UserSystemException` for user-facing errors. Widgets display `exception.message` in a `SnackBar`.

```dart
throw UserSystemException('Upload failed: file too large');
```

## License

MIT
