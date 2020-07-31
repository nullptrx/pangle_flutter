#import "PangleFlutterPlugin.h"
#if __has_include(<pangle_flutter/pangle_flutter-Swift.h>)
#import <pangle_flutter/pangle_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pangle_flutter-Swift.h"
#endif

@implementation PangleFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPangleFlutterPlugin registerWithRegistrar:registrar];
}
@end
