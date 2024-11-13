#import "TencentLiveCloudPlugin.h"

#if __has_include(<live_flutter_plugin/live_flutter_plugin-Swift.h>)
#import <live_flutter_plugin/live_flutter_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "live_flutter_plugin-Swift.h"
#endif

@implementation TencentLiveCloudPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [TXLivePluginManager registerWithRegistrar:registrar]; // 注册Plugin管理类
}

@end
