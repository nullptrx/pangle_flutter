import 'package:flutter/foundation.dart';

extension CheckNotNull on String {
  bool get isNotBlank => this?.isNotEmpty ?? false;
}

class Enum {
  static String enumToString(Object enumEntry) {
    return describeEnum(enumEntry);
  }

  static T enumFromString<T>(List<T> enumValues, String value) {
    if (value == null || enumValues == null) return null;

    return enumValues.singleWhere(
      (enumItem) => describeEnum(enumItem) == value,
      orElse: () => null,
    );
  }
}



