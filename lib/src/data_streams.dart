import 'dart:typed_data';

import 'package:dart_mc/src/utils.dart';

enum PacketPartType {
  string, varInt, short, boolean, unsignedByte
}

class PacketPart<T> {
  PacketPartType type;
  T data;

  PacketPart(this.type, this.data);
}

class PacketBufferBuilder {
  List<PacketPart<dynamic>> packetParts = [];

  PacketBufferBuilder();

  addVarInt(int varIntValue) {
    packetParts.add(PacketPart(PacketPartType.varInt, varIntValue));
  }

  addString(String stringValue) {
    packetParts.add(PacketPart(PacketPartType.string, stringValue));
  }

  addShort(int shortValue) {
    packetParts.add(PacketPart(PacketPartType.short, shortValue));
  }

  addBoolean(bool booleanValue) {
    packetParts.add(PacketPart(PacketPartType.boolean, booleanValue));
  }

  addUnsignedByte(int byteValue) {
    packetParts.add(PacketPart(PacketPartType.unsignedByte, byteValue));
  }

  Uint8List build() {
    int length = 0;

    for(PacketPart<dynamic> packetPart in packetParts) {
      switch(packetPart.type) {
        case PacketPartType.varInt: {
          if (packetPart.data is int) {
            length += calculateVarIntLength(packetPart.data);
            break;
          } else {
            throw 'Data should be of type int if encoding as varint. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
        case PacketPartType.string: {
          if (packetPart.data is String) {
            String value = packetPart.data as String;
            int stringLength = value.length; // * 4;
            int varIntLength = calculateVarIntLength(stringLength);
            length += stringLength + varIntLength;
            break;
          } else {
            throw 'Data should be of type String if encoding as string. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
        case PacketPartType.short: {
          length += 2;
          break;
        }
        case PacketPartType.unsignedByte:
        case PacketPartType.boolean: {
          length += 1;
          break;
        }
      }
    }

    Uint8List message = Uint8List(length + calculateVarIntLength(length));
    ByteData bytes = ByteData.view(message.buffer);

    int byteOffset = 0;

    byteOffset = writeVarIntToByteData(bytes, byteOffset, length);
    
    for (PacketPart<dynamic> packetPart in packetParts) {
      switch(packetPart.type) {
        case PacketPartType.varInt: {
          if (packetPart.data is int) {
            byteOffset = writeVarIntToByteData(bytes, byteOffset, packetPart.data);
            break;
          } else {
            throw 'Data should be of type int if encoding as varint. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
        case PacketPartType.string: {
          if (packetPart.data is String) {
            String stringValue = packetPart.data as String;
            int stringLength = stringValue.length;

            // write the length as a VarInt
            byteOffset = writeVarIntToByteData(bytes, byteOffset, stringLength);

            // write the string
            for (int codePoint in stringValue.codeUnits) {
              bytes.setUint8(byteOffset, codePoint);
              byteOffset += 1;
            }
            break;
          } else {
            throw 'Data should be of type String if encoding as string. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
        case PacketPartType.short: {
          if (packetPart.data is int) {
            int shortValue = packetPart.data as int;
            bytes.setInt16(byteOffset, shortValue, Endian.big);
            byteOffset += 2;

            break;
          } else {
            throw 'Data should be of type int if encoding as short. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
        case PacketPartType.boolean: {
          if (packetPart.data is bool) {
            bool booleanValue = packetPart.data as bool;
            bytes.setInt8(byteOffset, booleanValue ? 0x01 : 0x00);
            byteOffset += 1;

            break;
          } else {
            throw 'Data should be of type bool if encoding as boolean. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
        case PacketPartType.unsignedByte: {
          if (packetPart.data is int) {
            int byteValue = packetPart.data as int;
            bytes.setUint8(byteOffset, byteValue);
            byteOffset += 1;

            break;
          } else {
            throw 'Data should be of type int if encoding as unsigned byte. Found: ${packetPart.data.runtimeType.toString()}';
          }
        }
      }
    }

    return message;
  }
}