/*
 * Copyright (c) 2021 nullptrX
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/// Version values of the current Android operating system build derived from
/// `android.os.Build.VERSION`.
///
/// See: https://developer.android.com/reference/android/os/Build.VERSION.html
class AndroidDeviceInfo {
  const AndroidDeviceInfo._({
    this.sdkInt,
  });

  /// The user-visible SDK version of the framework.
  ///
  /// Possible values are defined in: https://developer.android.com/reference/android/os/Build.VERSION_CODES.html
  final int? sdkInt;

  /// Serializes [ AndroidDeviceInfo ] to map.
  Map<String, dynamic> toMap() {
    return {
      'sdkInt': sdkInt,
    };
  }

  /// Deserializes from the map message received from [_kChannel].
  static AndroidDeviceInfo fromMap(Map<String, dynamic> map) {
    return AndroidDeviceInfo._(
      sdkInt: map['sdkInt'],
    );
  }
}

/// Version values of the current IOS operating system build derived from
/// `android.os.Build.VERSION`.
///
/// See: https://developer.android.com/reference/android/os/Build.VERSION.html
class IOSDeviceInfo {
  const IOSDeviceInfo._({
    this.systemVersion,
  });

  /// The current operating system version.
  final String? systemVersion;

  /// Serializes [ AndroidDeviceInfo ] to map.
  Map<String, dynamic> toMap() {
    return {
      'systemVersion': systemVersion,
    };
  }

  /// Deserializes from the map message received from [_kChannel].
  static IOSDeviceInfo fromMap(Map<String, dynamic> map) {
    return IOSDeviceInfo._(
      systemVersion: map['systemVersion'],
    );
  }
}
