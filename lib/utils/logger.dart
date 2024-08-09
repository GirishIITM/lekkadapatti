import 'package:flutter/foundation.dart';

void logger(dynamic args,
    [dynamic args2,
    dynamic args3,
    dynamic args4,
    dynamic args5,
    dynamic args6]) {
  if (kDebugMode) {
    print(args);
    if (args2 != null) print(args2);
    if (args3 != null) print(args3);
    if (args4 != null) print(args4);
    if (args5 != null) print(args5);
    if (args6 != null) print(args6);
  }
}

void errorLogger(dynamic args,
    [dynamic args2,
    dynamic args3,
    dynamic args4,
    dynamic args5,
    dynamic args6]) {
  if (kDebugMode) {
    print('Error: $args');
    if (args2 != null) print(args2);
    if (args3 != null) print(args3);
    if (args4 != null) print(args4);
    if (args5 != null) print(args5);
    if (args6 != null) print(args6);
  }
}

void main() {
  logger('Hello World', 123, 123.45, true, [1, 2, 3], {'key': 'value'});
}
