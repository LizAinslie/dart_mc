import 'dart:io';
import 'dart:typed_data';

import 'package:dart_mc/src/data_streams.dart';
import 'package:dart_mc/src/packet/server_bound_packet.dart';
import 'package:dart_mc/src/protocol_version.dart';

enum NextState {
  status,
  login
}

extension _NextStateExtension on NextState {
  int get value {
    switch(this) {
      case NextState.status: return 1;
      case NextState.login: return 2;
    }
  }
}

class HandshakePacket extends ServerBoundPacket {
  int protocolVersion;
  String address;
  int port;
  NextState nextState;

  HandshakePacket(this.address, [
    this.port = 25565,
    this.nextState = NextState.status,
    this.protocolVersion = ProtocolVersion.oneEighteenOne,
  ]);

  @override
  void writeTo(Socket socket) {
    PacketBufferBuilder pbb = PacketBufferBuilder();
    pbb.addVarInt(0x00); // packet id: 0x00
    pbb.addVarInt(protocolVersion);
    pbb.addString(address);
    pbb.addShort(port);
    pbb.addVarInt(nextState.value);

    Uint8List message = pbb.build();
    socket.add(message);
  }
}