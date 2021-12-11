import 'dart:typed_data';

int writeVarIntToByteData(ByteData bytes, int byteOffset, int value) {
  int cursor = 0;
  while (value & ~0x7F != 0) {
    bytes.setUint8(byteOffset + cursor, (value & 0xFF) | 0x80);
    cursor++;
    value >>>= 7;
  }
  bytes.setUint8(byteOffset + cursor, value);

  return byteOffset + cursor + 1;
}

int calculateVarIntLength(int value) {
  int length = 0;
  while (value & ~0x7F != 0) {
    length++;
    value >>>= 7;
  }
  return length + 1;
}