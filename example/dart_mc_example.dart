import 'package:dart_mc/dart_mc.dart';
import 'package:dart_mc/src/packet/server_bound/handshake.dart';

void main() async {
  const serverAddress = 'localhost';
  const port = 25565;

  MinecraftConnection conn = MinecraftConnection(serverAddress, port);
  conn.addHandler((socket, data) {
    print('got data');
    print(String.fromCharCodes(data));
  });
  await conn.openConnection();
  await conn.sendPacket(HandshakePacket(serverAddress, port));
  // conn.closeConnection();
}
