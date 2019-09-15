tea加解密 for dart

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:crypto_tea/crypto_tea.dart';

main() {
    List<int> key = [1,2,3,4,5,6,7,8,9,0,11,12,13,14,15,16];
    var tt = tea(key,wheel.cycle2(),Padding().pkcs5);
    var aa = "abc";
    var dest = tt.encrypt(aa.codeUnits);

    print(dest);
    //print(tt.decrypt(dest));
    print(String.fromCharCodes(tt.decrypt(dest)) == aa); // true
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
