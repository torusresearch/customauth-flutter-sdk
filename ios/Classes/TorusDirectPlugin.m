#import "TorusDirectPlugin.h"
#if __has_include(<torus_direct/torus_direct-Swift.h>)
#import <torus_direct/torus_direct-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "torus_direct-Swift.h"
#endif

@implementation TorusDirectPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftTorusDirectPlugin registerWithRegistrar:registrar];
}
@end
