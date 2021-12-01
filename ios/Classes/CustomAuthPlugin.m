#import "CustomAuthPlugin.h"
#if __has_include(<customauth/customauth-Swift.h>)
#import <customauth/customauth-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "customauth-Swift.h"
#endif

@implementation CustomAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // Should be SwiftCustomAuthPlugin in the next line, somehow not working.
  [CustomAuthPlugin registerWithRegistrar:registrar];
}
@end
