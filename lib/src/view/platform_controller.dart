/*
 * Copyright (c) 2022 nullptrX
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

import 'package:flutter/widgets.dart';

/// Interface for talking to the view's platform implementation.
///
/// Platform implementations that live in a separate package should extend this
/// class rather than implement it, so that newly added methods have default
/// implementations and do not break existing subclasses.
abstract class PlatformController {
  /// Adds touchable-bounds entries (iOS only).
  Future<void> addTouchableBounds(List<Rect> bounds);

  /// Clears all touchable-bounds entries (iOS only).
  Future<void> clearTouchableBounds();
}

abstract class ViewController {
  final PlatformController _controller;

  const ViewController(this._controller);

  /// Restricts which areas of the native ad view receive touch events (iOS only).
  ///
  /// When the list is non-empty, only touches within the declared rectangles
  /// are forwarded to the native view; all other touches pass through to Flutter
  /// widgets underneath.
  ///
  /// When the list is empty (the default), all touches reach the native view normally.
  ///
  /// Adding a duplicate rectangle has no effect.
  Future<void> addTouchableBounds(List<Rect> bounds) async {
    await _controller.addTouchableBounds(bounds);
  }

  /// Adds a single touchable-bounds entry (iOS only).
  ///
  /// See [addTouchableBounds].
  Future<void> addTouchableBound(Rect bound) async {
    await _controller.addTouchableBounds([bound]);
  }

  /// Clears all touchable-bounds entries (iOS only).
  ///
  /// See [addTouchableBounds].
  Future<void> clearTouchableBounds() async {
    await _controller.clearTouchableBounds();
  }
}
