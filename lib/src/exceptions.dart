/// A user-friendly exception thrown by [ProfileService] and [DmService]
/// implementations so widgets can display [message] directly.
class UserSystemException implements Exception {
  const UserSystemException(this.message);

  final String message;

  @override
  String toString() => message;
}
