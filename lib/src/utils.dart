import 'dart:typed_data';

List<int> uint32ToByte(int uint32) {
  var bytes = Uint8List(4);
  var byteData = ByteData.view(bytes.buffer);
  byteData.setUint32(0, uint32, Endian.little);
  return bytes;
}

int byteToUint32(List<int> byte) {
  var bytes = Uint8List(4)..setAll(0, byte);
  var byteData = ByteData.view(bytes.buffer);
  return byteData.getUint32(0, Endian.little);
}

abstract class wheelCycle {
  final _cycle;
  final _chunk;
  wheelCycle(int cycle, chunk)
      : _cycle = cycle,
        _chunk = chunk;
  int get cycle => this._cycle;
  int get chunk => this._chunk;
}
