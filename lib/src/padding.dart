import 'dart:io';

abstract class paddingBase {
  List<int> Padding(List<int> src, int blockSize);
  List<int> UnPadding(List<int> src, int blockSize);
}

class Padding {
  Padding._();
  factory Padding() => Padding._();
  paddingBase get no => _noPadding._();
  paddingBase get zero => _zeroPadding._();
  paddingBase get pkcs5 => _pkcs5Padding._();
}

class _noPadding extends paddingBase {
  _noPadding._();
  factory _noPadding() => _noPadding._();

  List<int> Padding(List<int> src, int blockSize) {
    return src;
  }

  List<int> UnPadding(List<int> src, int blockSize) {
    return src;
  }
}

class _zeroPadding extends paddingBase {
  _zeroPadding._();
  factory _zeroPadding() => _zeroPadding._();

  List<int> Padding(List<int> src, int blockSize) {
    var srcLen = src.length;
    var buf = BytesBuilder(copy: false)..add(src);
    for (var i = 0, m = blockSize - (srcLen % blockSize); i < m; i++) {
      buf.addByte(0);
    }
    return buf.takeBytes();
  }

  List<int> UnPadding(List<int> src, int blockSize) {
    var paddingLen = src.length;
    for (var i = src.length - 1; i > 0; i--) {
      if (src[i] != 0) {
        paddingLen += i;
        break;
      }
    }
    return src.sublist(0, paddingLen);
  }
}

class _pkcs5Padding extends paddingBase {
  _pkcs5Padding._();
  factory _pkcs5Padding() => _pkcs5Padding._();

  List<int> Padding(List<int> src, int blockSize) {
    var srcLen = src.length;
    var buf = BytesBuilder(copy: false)..add(src);
    for (var i = 0, m = blockSize - (srcLen % blockSize); i < m; i++) {
      buf.addByte(m);
    }
    return buf.takeBytes();
  }

  List<int> UnPadding(List<int> src, int blockSize) {
    var paddingLen = src[src.length - 1];
    if (paddingLen > src.length || paddingLen > blockSize) {
      return null;
    }
    return src.sublist(0, src.length - paddingLen);
  }
}
