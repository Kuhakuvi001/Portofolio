part of vex_ecc;

enum PrivateKeyType {
  k1,
}

enum PrivateKeyFormat {
  wif,
  pvt,
}

class PrivateKeyData {
  final PrivateKey privateKey;
  final PrivateKeyFormat format;
  final PrivateKeyType keyType;

  PrivateKeyData(this.privateKey, this.format, this.keyType);
}

class PrivateKey {
  PrivateKey(this.key);

  static const privateKeyPattern = r'^PVT_([A-Za-z0-9]+)_([A-Za-z0-9]+)$';

  static PrivateKeyData parseKey(String privateStr) {
    final keyPattern = RegExp(privateKeyPattern);

    if (!keyPattern.hasMatch(privateStr)) {
      final versionKey = checkDecode(privateStr, keyType: 'sha256x2');
      final version = versionKey[0];

      assert(0x80 == version, "Expected version 0x80, instead got $version");

      final privateKey =
          fromBytes(Uint8List.fromList(versionKey.toList().sublist(1)));

      return PrivateKeyData(
          privateKey, PrivateKeyFormat.wif, PrivateKeyType.k1);
    }

    final matches = keyPattern.allMatches(privateStr);

    // => 1 - 1 instance of pattern found in string
    assert(matches.length == 1,
        'Expecting private key like: PVT_K1_base58privateKey..');

    final match = matches.elementAt(0); // => extract the first (and only) match
    final keyType = match.group(1);
    final keyString = match.group(2);

    assert(keyString != null, 'Non empty key expected');
    assert(keyType == 'K1', 'K1 private key expected');

    var privateKey = fromBytes(checkDecode(keyString!, keyType: keyType));

    return PrivateKeyData(privateKey, PrivateKeyFormat.pvt, PrivateKeyType.k1);
  }

  static PrivateKey fromHex(String hex) {
    return fromBytes(hexToBytes(hex));
  }

  static PrivateKey fromBytes(Uint8List bytes) {
    var decodedBytes = bytes;

    if (decodedBytes.length == 33 && decodedBytes[32] == 1) {
      // remove compression flag
      decodedBytes = Uint8List.fromList(
          decodedBytes.toList().sublist(0, decodedBytes.length - 1));
    }

    if (32 != decodedBytes.length) {
      throw AssertionError(
          "Expecting 32 bytes, instead got ${decodedBytes.length}");
    }

    return PrivateKey(decodeBigInt(decodedBytes));
  }

  /// Creates a [PrivateKey] by using [seed].
  ///
  /// [seed] is private, the same seed produces the same private key every time.
  static PrivateKey fromSeed(String seed) {
    final sha256 = pc.SHA256Digest();

    return fromBytes(sha256.process(Uint8List.fromList(utf8.encode(seed))));
  }

  /// Parse [PrivateKey]
  static PrivateKey fromString(String seed) {
    return parseKey(seed).privateKey;
  }

  /// return  true if key is in the Wallet Import Format
  static bool isWif(String key) {
    try {
      return parseKey(key).format == PrivateKeyFormat.wif;
    } catch (e) {
      return false;
    }
  }

  /// return  true if key is convertable to a private key object.
  static bool isValid(String key) {
    try {
      parseKey(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generates a new private key using the random instance provided. Please make
  /// sure you're using a cryptographically secure generator.
  static PrivateKey random({Random? random}) {
    final generator = pc.ECKeyGenerator();

    final keyParams = pc.ECKeyGeneratorParameters(secp256k1);
    final random = pc.FortunaRandom()
      ..seed(pc.KeyParameter(randomBytes(32, secure: true)));

    generator.init(pc.ParametersWithRandom(keyParams, random));

    final key = generator.generateKeyPair();
    final privateKey = key.privateKey as pc.ECPrivateKey;

    return PrivateKey(privateKey.d!);
  }

  final BigInt key;
  PublicKey? _publicKey;

  /// Returns a 64 byte shared secret
  Uint8List getSharedSecret(PublicKey publicKey) {
    final key = publicKey.toUncompressed().toBytes();
    final point = secp256k1.curve.createPoint(
        decodeBigInt(key.sublist(1, 33)), // x
        decodeBigInt(key.sublist(33, 65)));
    final r = toBytes();
    final P = point * decodeBigInt(r);
    final secret = encodeBigInt(P.affineX); // SHA512 used in ECIES

    return sha512(secret);
  }

  /// Generates a public key for the given private key using the ecdsa curve.
  PublicKey toPublic() {
    if (_publicKey != null) {
      return _publicKey!;
    }

    final p = secp256k1.G * key;

    _publicKey = PublicKey.fromBytes(p.getEncoded());

    return _publicKey!;
  }

  String toWif() {
    var checksum = toBytes(); // checksum includes the version

    return checkEncode(Uint8List.fromList([0x80] + checksum),
        keyType: 'sha256x2');
  }

  Uint8List toBytes() {
    return encodeBigInt(key);
  }

  String toHex() {
    return bytesToHex(toBytes());
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return toWif();
  }
}
