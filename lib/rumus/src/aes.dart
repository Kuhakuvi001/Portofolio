part of vex_ecc;

class Encryption {
  final Uint8List nonce;
  final String message;
  final Uint8List checksum;

  Encryption(this.message, {required this.nonce, required this.checksum});

  static String encrypt(Uint8List key, Uint8List iv, String text) {
    return bytesToHex(
        _processChipper(true, key, iv, Uint8List.fromList(utf8.encode(text))));
  }

  static String decrypt(Uint8List key, Uint8List iv, String data) {
    final r = _processChipper(false, key, iv, hexToBytes(data));
    return utf8.decode(r);
  }

  static Uint8List _processChipper(
      bool forEncryption, Uint8List key, Uint8List iv, Uint8List data) {
    final pc.CBCBlockCipher cbcCipher = pc.CBCBlockCipher(pc.AESFastEngine());
    final pc.ParametersWithIV ivParams =
        pc.ParametersWithIV(pc.KeyParameter(key), iv);
    final pc.PaddedBlockCipherParameters paddingParams =
        pc.PaddedBlockCipherParameters(ivParams, null);

    final pc.PaddedBlockCipherImpl paddedCipher =
        pc.PaddedBlockCipherImpl(pc.PKCS7Padding(), cbcCipher);
    paddedCipher.init(forEncryption, paddingParams);

    return paddedCipher.process(data);
  }
}

Encryption encrypt(PrivateKey privateKey, PublicKey publicKey, String message,
    {Uint8List? nonce}) {
  nonce ??= uniqueNonce();

  return _crypt(privateKey, publicKey, nonce, message);
}

Encryption decrypt(PrivateKey privateKey, PublicKey publicKey, String message,
    {required Uint8List nonce, required Uint8List checksum}) {
  return _crypt(privateKey, publicKey, nonce, message, checksum);
}

Encryption _crypt(
    PrivateKey privateKey, PublicKey publicKey, Uint8List nonce, String message,
    [Uint8List? checksum]) {
  final secret = privateKey.getSharedSecret(publicKey);
  final buf = Uint8List.fromList(nonce + secret);

  final encryptionKey = sha512(buf);
  final key = encryptionKey.sublist(0, 32);
  final iv = encryptionKey.sublist(32, 48);
  final check = sha256(encryptionKey)..sublist(0, 4);
  String? results;

  if (checksum != null) {
    if (!IterableEquality().equals(check, checksum)) {
      throw StateError('Invalid checksum');
    }

    results = Encryption.decrypt(key, iv, message);
  } else {
    results = Encryption.encrypt(key, iv, message);
  }

  return Encryption(results, nonce: nonce, checksum: check);
}

// TODO:
Uint8List uniqueNonce() {
  final rand = randomBytes(2);
  final random = pc.FortunaRandom()
    ..seed(pc.KeyParameter(randomBytes(32, secure: true)));
  var nonceEntropy = safeParseInt("${(rand[0] << 8 | rand[1])}", 10);

  final entropy = ++nonceEntropy % 0xFFFF;

  return encodeBigInt(decodeBigInt(shiftLeft(Uint8List.fromList(
          List<int>.generate(16, (i) => random.nextUint8())))) |
      BigInt.from(entropy));
}

Uint8List makeEmpty(int length) {
  return Uint8List.fromList(List<int>.generate(length, (i) => 0x00));
}

Uint8List shiftLeft(Uint8List b) {
  assert(b.isNotEmpty, 'shiftLeft requires a non-empty bytes');

  final results = makeEmpty(b.length);
  var overflow = 0;

  for (var i = b.length - 1; i >= 0; i--) {
    results[i] = b[i] << 1;
    results[i] |= overflow;
    overflow = (b[i] & 0x80) >> 7;
  }

  return results;
}
