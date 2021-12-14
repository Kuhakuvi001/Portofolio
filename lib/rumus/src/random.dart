part of vex_ecc;

/// [randomBytes] generates random bytes at given length.
///
/// when [secure] is enabled, Random.secure() is used instead of Random().
///
/// example:
/// ```
/// randomBytes(20);
/// ```
///
/// or:
/// ```
/// randomBytes(20, secure: true);
/// ```
Uint8List randomBytes(int length, {bool secure = false}) {
  assert(length > 0);

  final random = secure ? Random.secure() : Random();

  return Uint8List.fromList(
      List<int>.generate(length, (i) => random.nextInt(256)));
}
