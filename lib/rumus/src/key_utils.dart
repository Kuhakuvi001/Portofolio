part of vex_ecc;

/// Return checksum encoded base58 string
String checkEncode(Uint8List keyBuffer, {String? keyType}) {
  Uint8List checksum;

  if (keyType == 'sha256x2') {
    // legacy
    checksum = sha256(sha256(keyBuffer)).sublist(0, 4);
  } else {
    final check = keyBuffer;

    if (keyType != null && keyType.isNotEmpty) {
      check.addAll(utf8.encode(keyType));
    }

    checksum = ripemd160(check).sublist(0, 4);
  }

  return Base58Encode(keyBuffer + checksum);
}

/// Return checksum decoded base58 string
Uint8List checkDecode(String keyString, {String? keyType}) {
  final buffer = Uint8List.fromList(Base58Decode(keyString));
  final checksum = buffer.toList().sublist(buffer.length - 4);
  final key = Uint8List.fromList(buffer.toList().sublist(0, buffer.length - 4));
  Uint8List newCheck;

  if (keyType == 'sha256x2') {
    // WIF (legacy)
    newCheck = sha256(sha256(key)).sublist(0, 4);
  } else {
    final check = key;

    if (keyType != null && keyType.isNotEmpty) {
      check.addAll(utf8.encode(keyType));
    }

    newCheck = ripemd160(check).sublist(0, 4); //PVT
  }

  final checksumHex = bytesToHex(checksum);
  final newCheckHex = bytesToHex(newCheck);

  if (checksumHex != newCheckHex) {
    throw AssertionError('Invalid checksum, $checksumHex $newCheckHex');
  }

  return key;
}

bool isPointCompressed(Uint8List p) {
  return p[0] != 0x04;
}

/// If present, removes the 0x from the start of a hex-string.
String strip0x(String hex) {
  if (hex.startsWith('0x')) return hex.substring(2);
  return hex;
}

/// Converts the [bytes] given as a list of integers into a hexadecimal
/// representation.
///
/// If any of the bytes is outside of the range [0, 256], the method will throw.
/// The outcome of this function will prefix a 0 if it would otherwise not be
/// of even length. If [include0x] is set, it will prefix "0x" to the hexadecimal
/// representation. If [forcePadLength] is set, the hexadecimal representation
/// will be expanded with zeroes until the desired length is reached. The "0x"
/// prefix does not count for the length.
String bytesToHex(List<int> bytes,
    {bool include0x = false,
    int? forcePadLength,
    bool padToEvenLength = false}) {
  var encoded = hex.encode(bytes);

  if (forcePadLength != null) {
    assert(forcePadLength >= encoded.length);

    final padding = forcePadLength - encoded.length;
    encoded = ('0' * padding) + encoded;
  }

  if (padToEvenLength && encoded.length % 2 != 0) {
    encoded = '0$encoded';
  }

  return (include0x ? '0x' : '') + encoded;
}

/// Converts the hexadecimal string, which can be prefixed with 0x, to a byte
/// sequence.
Uint8List hexToBytes(String hexStr) {
  final bytes = hex.decode(strip0x(hexStr));
  if (bytes is Uint8List) return bytes;

  return Uint8List.fromList(bytes);
}

// Uint8List unsignedIntToBytes(BigInt number) {
//   assert(!number.isNegative);
//   return p_utils.encodeBigIntAsUnsigned(number);
// }

// BigInt bytesToUnsignedInt(Uint8List bytes) {
//   return p_utils.decodeBigIntWithSign(1, bytes);
// }

///Takes the hexadecimal input and creates a [BigInt].
BigInt hexToInt(String hex) {
  return BigInt.parse(strip0x(hex), radix: 16);
}

/// Converts the hexadecimal input and creates an [int].
int hexToDartInt(String hex) {
  return int.parse(strip0x(hex), radix: 16);
}
