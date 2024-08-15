#import "ParaHelper.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ParaHelperProtocol)];
    ParaHelper *exportedObject = [[ParaHelper alloc] init:newConnection];
    newConnection.exportedObject = exportedObject;
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ParaGreedProtocol)];
    [newConnection resume];
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ServiceDelegate *delegate = [ServiceDelegate new];
        NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.trueToastedCode.ParaHelper"];
        listener.delegate = delegate;
        [listener resume];
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
