#import "CustomAuthPlugin.h"
#if __has_include(<customauth_flutter/customauth_flutter-Swift.h>)
#import <customauth_flutter/customauth_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "customauth_flutter-Swift.h"
#endif

@implementation CustomAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // Should be SwiftCustomAuthPlugin in the next line, somehow not working.
  [SwiftCustomAuthPlugin registerWithRegistrar:registrar];
}
@end
