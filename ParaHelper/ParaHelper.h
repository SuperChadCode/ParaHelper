#import "ParaHelperProtocol.h"
#import "ParaGreedProtocol.h"
#import "Tools.h"

#define SP_TIMEOUT 3
#define SHM_SIZE 10240000

@interface ParaHelper : NSObject <ParaHelperProtocol>

@property NSXPCConnection *con;

@property void *shm_read_ptr;
@property NSString *shm_read_name;
@property int shm_read_fd;

@property void *shm_write_ptr;
@property NSString *shm_write_name;
@property int shm_write_fd;

@property interface_ref iface;
@property dispatch_queue_t queue;

- (instancetype)init:(NSXPCConnection *)con;

@end
