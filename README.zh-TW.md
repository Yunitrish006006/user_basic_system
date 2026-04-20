# user_basic_system

> 📖 [English README →](README.md)

可重複使用的個人資料管理與私訊聊天系統，基於抽象服務介面，適用於任何 Flutter 應用程式。

## 功能特色

- **`ProfileService`** — 抽象 `ChangeNotifier` 介面，依後端實作一次即可全套件重用
- **`DmService`** — 抽象私訊聊天介面，包含 8 項操作
- **`ProfilePage`** — 完整個人資料頁面：自動儲存（1.5 秒 debounce）、頭像來源切換（Google / 自訂 URL / 上傳圖片）、檔案選擇器上傳
- **`DmPage`** — 完整私訊聊天頁面：輪詢接收、訊息收回、跨裝置同步
- **`ProfileStrings` / `DmStrings`** — UI 文字預設英文；可覆寫任意欄位，或用 `fromMap()` 傳入現有翻譯表
- **`UserSystemException`** — 供服務層拋出的使用者可見錯誤型別

## 快速開始

```yaml
dependencies:
  user_basic_system: ^0.1.0
```

## 使用方式

### 1. 實作抽象服務

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
  Future<void> uploadAvatarImage(Uint8List bytes) async { ... }

  @override
  Future<void> deleteAvatarImage() async { ... }
}

class MyChatService implements DmService {
  // 實作 8 個 DmService 方法 …
}
```

### 2. 註冊 Provider

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProfileService()),
    Provider(create: (_) => MyChatService()),
  ],
  child: MyApp(),
);
```

### 3. 使用 Widget

```dart
import 'package:user_basic_system/user_basic_system.dart';

// 個人資料頁面
ProfilePage(
  service: context.read<MyProfileService>(),
  strings: ProfileStrings(),            // 英文預設
  // strings: ProfileStrings.fromMap(myTranslationMap),
  extraContent: const MySettingsPanel(), // 選填：在下方插入額外 UI
)

// 私訊聊天頁面
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

### 4. 與現有翻譯系統整合

若你的 app 已有 `Map<String, String>` 翻譯系統，直接傳入即可：

```dart
final t = context.watch<LocaleProvider>().translation;

ProfilePage(
  service: myProfileService,
  strings: ProfileStrings.fromMap(t),
)
```

`fromMap()` 工廠方法會自動從翻譯表中取對應的鍵值，找不到的鍵則 fallback 到英文預設。

---

## API 總覽

### `ProfileService`（抽象）

| 成員 | 說明 |
|------|------|
| `UserProfile? get profile` | 目前登入使用者的個人資料，未登入則為 null |
| `Future<void> updateProfile({name, bio, customAvatarUrl, avatarSource})` | 儲存個人資料變更 |
| `Future<void> uploadAvatarImage(Uint8List bytes)` | 上傳並儲存頭像圖片 |
| `Future<void> deleteAvatarImage()` | 刪除已上傳的頭像 |

### `DmService`（抽象）

| 成員 | 說明 |
|------|------|
| `Stream<ChatMessage> get messageStream` | 接收新訊息的 Stream |
| `Future<List<ChatMessage>> fetchHistory(selfId, friendId)` | 讀取本地快取聊天紀錄 |
| `Future<List<ChatMessage>> syncFromServer(selfId, friendId)` | 強制從伺服器同步 |
| `Future<void> sendMessage(friendId, text)` | 傳送文字訊息 |
| `Future<void> recallMessage(messageId)` | 收回已傳訊息 |
| `Future<void> uploadMessages(selfId, friendId, messages)` | 上傳本地訊息至伺服器 |
| `Future<List<ChatMessage>> downloadMessages(selfId, friendId)` | 從伺服器下載訊息 |
| `Future<void> clearLocalMessages(selfId, friendId)` | 清除本地快取訊息 |

---

## 例外處理

服務實作應拋出 `UserSystemException` 來傳遞使用者可見的錯誤訊息。Widget 會自動在 `SnackBar` 中顯示 `exception.message`。

```dart
throw UserSystemException('上傳失敗：檔案過大');
```

## 授權條款

MIT
