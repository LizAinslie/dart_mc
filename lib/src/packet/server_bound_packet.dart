import 'dart:io';

abstract class ServerBoundPacket {
  void writeTo(Socket socket);
}