#import <Foundation/Foundation.h>
#import <vmnet/vmnet.h>

typedef void (^setup_shm_mem_completion_handler_t)(BOOL ok);

typedef void (^clean_shm_mem_completion_handler_t)(void);

typedef void (^vmnet_start_interface_wrap_completion_handler_t)(intptr_t iface);

typedef void (^vmnet_interface_set_event_callback_wrap_completion_handler_t)(vmnet_return_t status);

typedef void (^vmnet_stop_interface_wrap_completion_handler_t)(vmnet_return_t status);

typedef void (^vmnet_read_wrap_completion_handler_t)(vmnet_return_t status, int actual);

typedef void (^vmnet_write_wrap_completion_handler_t)(vmnet_return_t status, int actual);

typedef void (^vmnet_copy_shared_interface_list_wrap_completion_handler_t)(NSArray *ser_shared_ifaces);

@protocol ParaHelperProtocol

- (void)setup_shm_mem:
(NSString *)shm_read_name
shm_write_name:(NSString *)shm_write_name
handler:(setup_shm_mem_completion_handler_t)handler;

- (void)clean_shm_mem:
(clean_shm_mem_completion_handler_t)handler;

- (void)vmnet_start_interface_wrap:
(NSDictionary *)ser_interface_desc
handler:(vmnet_start_interface_wrap_completion_handler_t)handler;

- (void)vmnet_interface_set_event_callback_wrap:
(interface_event_t)event_mask
remove:(BOOL)remove
handler:(vmnet_interface_set_event_callback_wrap_completion_handler_t)handler;

- (void)vmnet_stop_interface_wrap:
(vmnet_stop_interface_wrap_completion_handler_t)handler;

- (void)vmnet_read_wrap:
(int)pktcnt
handler:(vmnet_read_wrap_completion_handler_t)handler;

- (void)vmnet_write_wrap:
(int)pktcnt
handler:(vmnet_write_wrap_completion_handler_t)handler;

- (void)vmnet_copy_shared_interface_list_wrap:
(vmnet_copy_shared_interface_list_wrap_completion_handler_t)handler;

@end
