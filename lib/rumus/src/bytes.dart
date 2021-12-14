part of vex_ecc;

/// Returns a buffer filled with 0s.
Uint8List zeros(int bytes) {
  var buffer = Uint8List(bytes);
  buffer.fillRange(0, bytes, 0);
  return buffer;
}

/// Left Pads an [Uint8List] with leading zeros till it has [length] bytes.
/// Or it truncates the beginning if it exceeds.
Uint8List setLengthLeft(Uint8List msg, int length, {bool right = false}) {
  var buf = zeros(length);
  msg = toBuffer(msg);
  if (right) {
    if (msg.length < length) {
      buf.setAll(0, msg);
      return buf;
    }
    return msg.sublist(0, length);
  } else {
    if (msg.length < length) {
      buf.setAll(length - msg.length, msg);
      return buf;
    }
    return msg.sublist(msg.length - length);
  }
}

Uint8List setLength(Uint8List msg, int length, {bool right = false}) {
  return setLengthLeft(msg, length, right: right);
}

/// Right Pads an [Uint8List] with leading zeros till it has [length] bytes.
/// Or it truncates the beginning if it exceeds.
Uint8List setLengthRight(Uint8List msg, int length) {
  return setLength(msg, length, right: true);
}

/// Trims leading zeros from a [Uint8List].
Uint8List unpad(Uint8List a) {
  for (int i = 0; i < a.length; i++) {
    if (a[i] != 0) {
      return a.sublist(i);
    }
  }
  return Uint8List(0);
}

Uint8List stripZeros(Uint8List a) {
  return unpad(a);
}

String unpadString(String a) {
  a = stripHexPrefix(a);
  for (int i = 0; i < a.length; i++) {
    if (a[i] != '0') {
      return a.substring(i);
    }
  }
  return '';
}

/// Attempts to turn a value into a [Uint8List]. As input it supports [Uint8List], [String], [int], [null], [BigInt] method.
Uint8List toBuffer(Object? v) {
  if (v is! Uint8List) {
    if (v is List) {
      v = Uint8List.fromList(v as List<int>);
    } else if (v is String) {
      if (isHexString(v)) {
        v = Uint8List.fromList(
            hex.decode(padToEven(stripHexPrefix(v))));
      } else {
        v = Uint8List.fromList(utf8.encode(v));
      }
    } else if (v is int) {
      v = intToBuffer(v);
    } else if (v == null) {
      v = Uint8List(0);
    } else if (v is BigInt) {
      v = Uint8List.fromList(encodeBigInt(v));
    } else {
      throw 'invalid type';
    }
  }

  return v;
}

/// Converts a [Uint8List] to a [int].
int bufferToInt(Uint8List buf) {
  return decodeBigInt(toBuffer(buf)).toInt();
}

/// Converts a [Uint8List] into a hex [String].
String bufferToHex(Uint8List buf) {
  return '0x' + hex.encode(buf);
}

/// Interprets a [Uint8List] as a signed integer and returns a [BigInt]. Assumes 256-bit numbers.
BigInt fromSigned(Uint8List signedInt) {
  return decodeBigInt(signedInt).toSigned(256);
}

/// Converts a [BigInt] to an unsigned integer and returns it as a [Uint8List]. Assumes 256-bit numbers.
Uint8List toUnsigned(BigInt unsignedInt) {
  return encodeBigInt(unsignedInt.toUnsigned(256));
}
