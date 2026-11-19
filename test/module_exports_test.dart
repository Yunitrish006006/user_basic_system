import 'package:flutter_test/flutter_test.dart';
import 'package:user_basic_system/user_account_core.dart' as account;
import 'package:user_basic_system/user_social_system.dart' as social;
import 'package:user_basic_system/user_basic_system.dart' as legacy;

void main() {
  test('account, social, and legacy facades export identical contracts', () {
    final Type profile = account.UserProfile;
    final Type accountService = account.ProfileService;
    final Type chatMessage = social.ChatMessage;
    final Type dmService = social.DmService;
    final Type oldAccountService = legacy.ProfileService;
    final Type oldDmService = legacy.DmService;

    expect(profile.toString(), 'UserProfile');
    expect(accountService.toString(), 'ProfileService');
    expect(chatMessage.toString(), 'ChatMessage');
    expect(dmService.toString(), 'DmService');
    expect(oldAccountService, accountService);
    expect(oldDmService, dmService);
  });
}
