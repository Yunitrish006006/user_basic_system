# Account and social boundaries

The compatibility package forwards the combined legacy library, the two
feature facades and the existing source import paths. All aliases reference
the same Dart types.

- `user_account_core` owns reusable profile types, the profile-service port,
  profile widgets, and the compatibility exception.
- `user_social_system` owns reusable DM types, the DM-service port and the DM
  widgets. The compatibility social facade continues to export the same
  exception type.
- `user_notification_system` owns interpreting push and Web notification
  intents. The Taiwan Brawl app owns auth, registration, device permissions
  and navigation. The backend owns FCM delivery and durable message polling.

Taiwan Brawl injects auth, local storage, and API implementations. Friend and
game invite flows, session tokens, and database contracts remain host-owned.
Feature-branch consumers use immutable Git references. The published 0.1.1
package has the original bundled implementation; the Git-only compatibility
branch requires Dart 3.11.1 or later.
