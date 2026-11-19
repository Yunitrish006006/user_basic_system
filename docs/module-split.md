# Account / Social extraction boundary

This repository currently bundles profile and direct messaging features.

New public facades provide an incremental, backwards-compatible migration:
- `package:user_basic_system/user_account_core.dart`: profile model, service contract, locale strings, profile UI.
- `package:user_basic_system/user_social_system.dart`: chat model, DM service contract, locale strings, chat UI.
- `package:user_basic_system/user_basic_system.dart`: unchanged legacy combined export.

These are **facades in one repository**, not two independent published packages.
The final split into `user_account_core` and `user_social_system` repositories
requires separate repos, versioned dependencies, migrated imports, and tests.
Existing apps should continue using the combined export until the individual
package APIs stabilize.

The account service owns authentication and session state. Social modules
receive a host-provided user identity and DmService; they must not own
credentials or log-in state. Notification transport is a separate concern.

Acceptance: combined export remains compatible; no behavioral changes to
profile or DM; independent facades compile; all host-app regressions pass.
