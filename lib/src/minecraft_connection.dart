import 'dart:io';
import 'dart:typed_data';

import 'package:dart_mc/src/packet/server_bound_packet.dart';

typedef SocketHandler = Function(Socket socket, Uint8List data);

class MinecraftConnection {
  Socket? _socket;
  String serverAddress;
  int serverPort;
  List<SocketHandler> handlers = [];

  MinecraftConnection(this.serverAddress, this.serverPort);

  Future<void> openConnection() async {
    _socket = await Socket.connect(serverAddress, serverPort);

    if (_socket == null) {
      print('PANIK! NO SOCKET?????');
      throw 'bitch';
    }

    _socket!.listen((data) {
      print(String.fromCharCodes(data));
    });
  }

  addHandler(SocketHandler handler) {
    handlers.add(handler);
  }

  Future<void> sendPacket(ServerBoundPacket packet) async {
    if (_socket == null) {
      throw 'The socket doesn\'t exist yet you bitch';
    }

    packet.writeTo(_socket!);
  }

  void closeConnection() {
    _socket?.close();
    _socket = null;
  }
}
