part of vex_ecc;

final secp256k1 = pc.ECCurve_secp256k1();

Uint8List sha256(Uint8List data) => pc.SHA256Digest().process(data);

Uint8List sha512(Uint8List data) => pc.SHA512Digest().process(data);

Uint8List ripemd160(Uint8List data) => pc.RIPEMD160Digest().process(data);

extension PointExtenstions on pc.ECPoint {
  BigInt get z {
    return BigInt.one;
  }

  BigInt get zInv {
    return z.modInverse((curve as fp.ECCurve).q!);
  }

  BigInt get affineX {
    final bigX = x!.toBigInteger()!;
    final p = bigX * zInv;

    return p % (curve as fp.ECCurve).q!;
  }

  BigInt get affineY {
    final bigY = y!.toBigInteger()!;
    final p = bigY * zInv;

    return p % (curve as fp.ECCurve).q!;
  }
}
