import 'package:flutter_test/flutter_test.dart';
import 'package:user_basic_system/user_account_core.dart' as account;
import 'package:user_basic_system/user_social_system.dart' as social;
import 'package:user_basic_system/user_basic_system.dart' as legacy;

void main() {
  test('profile and DM contracts are exported by their own facades', () {
    expect(account.UserProfile.toString(), 'UserProfile');
    expect(account.ProfileService.toString(), 'ProfileService');
    expect(social.ChatMessage.toString(), 'ChatMessage');
    expect(social.DmService.toString(), 'DmService');
    // Existing apps can continue importing the legacy facade.
    expect(legacy.ProfileService, account.ProfileService);
    expect(legacy.DmService, social.DmService);
  });
}
