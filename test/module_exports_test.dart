import 'package:flutter_test/flutter_test.dart';
import 'package:user_account_core/user_account_core.dart' as extracted_account;
import 'package:user_basic_system/user_account_core.dart' as account;
import 'package:user_basic_system/user_social_system.dart' as social;
import 'package:user_social_system/user_social_system.dart' as extracted_social;
import 'package:user_basic_system/src/models/chat_message.dart' as old_internal;
import 'package:user_basic_system/user_basic_system.dart' as legacy;

void main() {
  test('account, social, and legacy facades export identical contracts', () {
    const Type profile = account.UserProfile;
    const Type accountService = account.ProfileService;
    const Type chatMessage = social.ChatMessage;
    const Type dmService = social.DmService;
    const Type oldAccountService = legacy.ProfileService;
    const Type oldDmService = legacy.DmService;

    expect(profile.toString(), 'UserProfile');
    expect(accountService.toString(), 'ProfileService');
    expect(chatMessage.toString(), 'ChatMessage');
    expect(dmService.toString(), 'DmService');
    expect(oldAccountService, accountService);
    expect(oldDmService, dmService);
    expect(oldAccountService, extracted_account.ProfileService);
    expect(oldDmService, extracted_social.DmService);
    expect(old_internal.ChatMessage, extracted_social.ChatMessage);
    expect(account.UserSystemException, social.UserSystemException);
  });
}
