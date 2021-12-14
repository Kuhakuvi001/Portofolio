part of vex_ecc;

class PublicKey {
  final pc.ECPoint key;
  final String prefix;
  final bool compressed;

  static const publicKeyPattern = r'^PUB_([A-Za-z0-9]+)_([A-Za-z0-9]+)$';

  PublicKey(this.key, {this.prefix = 'VEX', this.compressed = false});

  static PublicKey fromString(String publicStr, {String prefix = 'VEX'}) {
    final keyPattern = RegExp(publicKeyPattern);

    if (!keyPattern.hasMatch(publicStr)) {
      // legacy
      var legacyKey = publicStr;

      if (RegExp("^" + prefix).hasMatch(legacyKey)) {
        legacyKey = legacyKey.substring(prefix.length);
      }

      return fromBytes(checkDecode(legacyKey));
    }

    final matches = keyPattern.allMatches(publicStr);

    // => 1 - 1 instance of pattern found in string
    assert(matches.length == 1,
        'Expecting public key like: PUB_K1_base58pubkey..');

    final match = matches.elementAt(0); // => extract the first (and only) match
    final keyType = match.group(1);
    final keyString = match.group(2);

    assert(keyString != null, 'Non empty key expected');
    assert(keyType == 'K1', 'K1 private key expected');

    return fromBytes(checkDecode(keyString!, keyType: keyType));
  }

  static PublicKey fromHex(String hex, {String prefix = 'VEX'}) {
    return fromBytes(hexToBytes(hex), prefix: prefix);
  }

  static PublicKey fromBytes(Uint8List bytes, {String prefix = 'VEX'}) {
    final compressed = isPointCompressed(bytes);
    final point = secp256k1.curve.decodePoint(bytes);

    assert(point != null);

    return PublicKey(point, prefix: prefix, compressed: compressed);
  }

  /// return  true if key is convertable to a public key object.
  static bool isValid(String key, {String prefix = 'VEX'}) {
    try {
      fromString(key, prefix: prefix);

      return true;
    } catch (e) {
      return false;
    }
  }

  PublicKey toUncompressed() {
    final bytes = key.getEncoded(false);
    final point = secp256k1.curve.decodePoint(bytes);

    assert(point != null);

    return PublicKey(point);
  }

  String toHex() {
    return bytesToHex(toBytes());
  }

  Uint8List toBytes() {
    return key.getEncoded(compressed);
  }

  @override
  String toString() {
    return prefix + checkEncode(toBytes());
  }
}
