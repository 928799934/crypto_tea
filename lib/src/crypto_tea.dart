import 'dart:typed_data';

import 'utils.dart';
import 'padding.dart';

final _delta = 0x9e3779b9;

class wheel extends wheelCycle {
  wheel._(int wheel, chunk) : super(wheel, chunk);
  factory wheel.cycle2() => wheel._(2, 1);
  factory wheel.cycle4() => wheel._(4, 2);
  factory wheel.cycle8() => wheel._(8, 3);
  factory wheel.cycle16() => wheel._(16, 4);
  factory wheel.cycle32() => wheel._(32, 5);
  factory wheel.cycle64() => wheel._(64, 6);
}

class tea {
  final _blockSize = 8;
  final _byteSize = 4;
  final _byte2Size = 4 * 2;
  final _key;
  final _wheel;
  final _padding;
  tea._(List<int> key, wheel wheel, paddingBase padding)
      : _wheel = wheel,
        _padding = padding,
        _key = _parseKey(key);

  factory tea(List<int> key, wheel wheel, paddingBase padding) =>
      tea._(key, wheel, padding);

  List<int> encrypt(List<int> src) {

    src = (this._padding as paddingBase).Padding(src, _blockSize);
    for (var i = 0; i < src.length;) {
      var firstChunk = byteToUint32(src.sublist(i, i + this._byteSize));
      var secondChunk =
          byteToUint32(src.sublist(i + this._byteSize, i + this._byte2Size));

      var arr = _encryptTEA(firstChunk, secondChunk, this._key, this._wheel);
      firstChunk = arr[0];
      secondChunk = arr[1];

      src.setRange(i, i + this._byteSize, uint32ToByte(firstChunk));
      src.setRange(
          i + this._byteSize, i + this._byte2Size, uint32ToByte(secondChunk));
      i = i + this._byte2Size;
    }
    return src;
  }

  Uint8List decrypt(List<int> dest) {
    if (dest.length < this._blockSize || dest.length % this._blockSize != 0) {
      return null;
    }
    for (var i = 0; i < dest.length;) {
      var firstChunk = byteToUint32(dest.sublist(i, i + this._byteSize));
      var secondChunk =
          byteToUint32(dest.sublist(i + this._byteSize, i + this._byte2Size));

      var arr = _decryptTEA(firstChunk, secondChunk, this._key, this._wheel);
      firstChunk = arr[0];
      secondChunk = arr[1];

      dest.setRange(i, i + this._byteSize, uint32ToByte(firstChunk));
      dest.setRange(
          i + this._byteSize, i + this._byte2Size, uint32ToByte(secondChunk));

      i = i + this._byte2Size;
    }

    return (this._padding as paddingBase).UnPadding(dest, _blockSize);
  }

  void ppp() {
    print(this._key);
  }
}

List<int> _parseKey(List<int> key) {
  List<int> _key = List(4);
  for (var i = 0; i < 4; i++) {
    _key[i] = byteToUint32(key.sublist(i * 4, (i + 1) * 4));
  }
  return _key;
}

List<int> _encryptTEA(
    int firstChunk, int secondChunk, List<int> key, wheelCycle wheel) {
  var y = firstChunk, z = secondChunk, sum = 0;
  for (var i = 0; i < wheel.cycle; i++) {
    sum = byteToUint32(uint32ToByte(sum + _delta));

    // dart 单纯int 无法表式 uint32
    // + 容易超出uint32 需要转换一下还原对应的数值
    var yy = (((z << 4) + key[0]) ^ (z + sum) ^ ((z >> 5) + key[1]));
    y = y + byteToUint32(uint32ToByte(yy));
    y = byteToUint32(uint32ToByte(y));

    var zz = (((y << 4) + key[2]) ^ (y + sum) ^ ((y >> 5) + key[3]));
    z = z + byteToUint32(uint32ToByte(zz));
    z = byteToUint32(uint32ToByte(z));
  }
  return [y, z];
}

List<int> _decryptTEA(
    int firstChunk, secondChunk, List<int> key, wheelCycle wheel) {
  var y = firstChunk,
      z = secondChunk,
      sum = byteToUint32(uint32ToByte(_delta << wheel.chunk));

  for (var i = 0; i < wheel.cycle; i++) {
    var zz = (((y << 4) + key[2]) ^ (y + sum) ^ ((y >> 5) + key[3]));
    z = z - byteToUint32(uint32ToByte(zz));
    z = byteToUint32(uint32ToByte(z));

    var yy = (((z << 4) + key[0]) ^ (z + sum) ^ ((z >> 5) + key[1]));
    y = y - byteToUint32(uint32ToByte(yy));
    y = byteToUint32(uint32ToByte(y));

    sum = byteToUint32(uint32ToByte(sum - _delta));
  }
  return [y, z];
}
