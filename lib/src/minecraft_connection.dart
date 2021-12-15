import 'dart:io';
import 'dart:typed_data';

import 'package:dart_mc/src/packet/server_bound_packet.dart';

typedef SocketHandler = Function(Socket socket, Uint8List message);

class MinecraftConnection {
  Socket? _socket;
  String serverAddress;
  int serverPort;
  List<SocketHandler> handlers = [];

  MinecraftConnection(this.serverAddress, this.serverPort);

  Future<void> openConnection() async {
    _socket = await Socket.connect(serverAddress, serverPort);

    if (_socket != null) {
      _socket!.listen((data) {
        for (SocketHandler handler in handlers) {
          handler(_socket!, data);
        }
      });
    } else {
      throw 'Cannot continue with null socket.';
    }
  }

  addHandler(SocketHandler handler) {
    handlers.add(handler);
  }

  Future<void> sendPacket(ServerBoundPacket packet) async {
    if (_socket == null) {
      throw 'Cannot send packets to null socket';
    }

    packet.writeTo(_socket!);
  }

  void closeConnection() {
    _socket?.close();
    _socket = null;
  }
}
