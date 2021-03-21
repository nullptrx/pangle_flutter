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

/// log level, only ios works.
enum PangleLogLevel {
  none,
  error,
  debug,
}

/// Pick image size for ad
/// From [v0.2.0] not works for express ads.
enum PangleImgSize {
  banner640_90,
  banner640_100,
  banner600_150,
  banner600_260,
  banner600_286,
  banner600_300,
  banner690_388,
  banner600_400,
  banner600_500,
  feed228_150,
  feed690_388,
  interstitial600_400,
  interstitial600_600,
  interstitial600_900,
  drawFullScreen,
}

/// title bar theme for land page, only android works.
enum AndroidTitleBarTheme {
  light,
  dark,
  no_title_bar,
}

/// available network type for downloading type ad.
class AndroidDirectDownloadNetworkType {
  AndroidDirectDownloadNetworkType._();

  static const int kMobile = 1;
  static const int k2G = 2;
  static const int k3G = 3;
  static const int kWiFi = 4;
  static const int k4G = 5;
}

/// The type of loading ads.
///
/// [normal] Showing ads up without preloading.
/// [preload] Showing ads up and preloading next ads.
/// [preload_only] Preloading ads only, not showing ads up.
enum PangleLoadingType {
  normal,
  preload,
  preload_only,
}

@Deprecated('Use `PangleLoadingType` instead.')
class LoadingType {
  static PangleLoadingType get normal => PangleLoadingType.normal;

  static PangleLoadingType get preload => PangleLoadingType.preload;

  // ignore: non_constant_identifier_names
  static PangleLoadingType get preload_only => PangleLoadingType.preload_only;
}

enum PangleOrientation {
  // ignore: unused_field
  _,
  veritical,
  horizontal,
}

enum PangleAuthorizationStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
}
