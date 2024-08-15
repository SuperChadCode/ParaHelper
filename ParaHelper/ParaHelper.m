#import "ParaHelper.h"

@implementation ParaHelper

- (void)setup_shm_mem:
(NSString *)shm_read_name
shm_write_name:(NSString *)shm_write_name
handler:(setup_shm_mem_completion_handler_t)handler {
    _shm_read_name = shm_read_name;
    if (!open_shared_memory(_shm_read_name, SHM_SIZE, &_shm_read_fd, &_shm_read_ptr)) {
        return handler(NO);
    }
    _shm_write_name = shm_write_name;
    if (!open_shared_memory(_shm_write_name, SHM_SIZE, &_shm_write_fd, &_shm_write_ptr)) {
        close_shared_memory(_shm_read_name, SHM_SIZE, _shm_read_fd, _shm_read_ptr);
        return handler(NO);
    }
    handler(YES);
}

- (void)clean_shm_mem:
(clean_shm_mem_completion_handler_t)handler {
    close_shared_memory(_shm_read_name, SHM_SIZE, _shm_read_fd, _shm_read_ptr);
    close_shared_memory(_shm_write_name, SHM_SIZE, _shm_write_fd, _shm_write_ptr);
    handler();
}

- (void)vmnet_start_interface_wrap:
(NSDictionary *)ser_interface_desc
handler:(vmnet_start_interface_wrap_completion_handler_t)handler {
    xpc_object_t interface_desc = unserialize_xpc_object_t(ser_interface_desc);
    dispatch_semaphore_t vmnet_sp = dispatch_semaphore_create(0);
    _iface = vmnet_start_interface(interface_desc, _queue, ^(vmnet_return_t handler_status, xpc_object_t  _Nullable handler_interface_param) {
        dispatch_semaphore_signal(vmnet_sp);
        // call original callback and wait for it to complete
        NSDictionary *handler_ser_interface_param = serialize_xpc_object_t(handler_interface_param);
        dispatch_semaphore_t complete_sp = dispatch_semaphore_create(0);
        [[self.con remoteObjectProxy] vmnet_start_interface_wrap_complete:handler_status ser_interface_param:handler_ser_interface_param handler:^(void) {
            dispatch_semaphore_signal(complete_sp);
        }];
        dispatch_semaphore_wait(complete_sp, dispatch_time(DISPATCH_TIME_NOW, SP_TIMEOUT * NSEC_PER_SEC));
    });
    handler((intptr_t)_iface);
    dispatch_semaphore_wait(vmnet_sp, dispatch_time(DISPATCH_TIME_NOW, SP_TIMEOUT * NSEC_PER_SEC));
}

- (void)vmnet_interface_set_event_callback_wrap:
(interface_event_t)event_mask
remove:(BOOL)remove
handler:(vmnet_interface_set_event_callback_wrap_completion_handler_t)handler {
    vmnet_return_t status = vmnet_interface_set_event_callback(_iface, event_mask, remove ? NULL : _queue, remove ? NULL : ^(interface_event_t handler_event_mask, xpc_object_t  _Nonnull handler_event) {
        NSDictionary *handler_ser_event = serialize_xpc_object_t(handler_event);
        dispatch_semaphore_t sp = dispatch_semaphore_create(0);
        [[self.con remoteObjectProxy] vmnet_interface_callback_wrap:handler_event_mask ser_event:handler_ser_event handler:^() {
            dispatch_semaphore_signal(sp);
        }];
        dispatch_semaphore_wait(sp, dispatch_time(DISPATCH_TIME_NOW, SP_TIMEOUT * NSEC_PER_SEC));
    });
    handler(status);
}

- (void)vmnet_stop_interface_wrap:
(vmnet_stop_interface_wrap_completion_handler_t)handler {
    dispatch_semaphore_t vmnet_sp = dispatch_semaphore_create(0);
    vmnet_return_t status = vmnet_stop_interface(_iface, _queue, ^(vmnet_return_t handler_status) {
        dispatch_semaphore_signal(vmnet_sp);
        // call original callback and wait for it to complete
        dispatch_semaphore_t complete_sp = dispatch_semaphore_create(0);
        [[self.con remoteObjectProxy] vmnet_stop_interface_wrap_complete:handler_status handler:^(void) {
            dispatch_semaphore_signal(complete_sp);
        }];
        dispatch_semaphore_wait(complete_sp, dispatch_time(DISPATCH_TIME_NOW, SP_TIMEOUT * NSEC_PER_SEC));
    });
    handler(status);
    dispatch_semaphore_wait(vmnet_sp, dispatch_time(DISPATCH_TIME_NOW, SP_TIMEOUT * NSEC_PER_SEC));
}

- (void)vmnet_read_wrap:
(int)pktcnt
handler:(vmnet_read_wrap_completion_handler_t)handler {
    update_packets_ptrs(_shm_read_ptr, SHM_SIZE, pktcnt, pktcnt);
    int actual = pktcnt;
    vmnet_return_t status = vmnet_read(_iface, _shm_read_ptr, &actual);
    handler(status, actual);
}

- (void)vmnet_write_wrap:
(int)pktcnt
handler:(vmnet_write_wrap_completion_handler_t)handler {
    update_packets_ptrs(_shm_write_ptr, SHM_SIZE, pktcnt, pktcnt);
    int actual = pktcnt;
    vmnet_return_t status = vmnet_write(_iface, _shm_write_ptr, &actual);
    handler(status, actual);
}

- (void)vmnet_copy_shared_interface_list_wrap:
(vmnet_copy_shared_interface_list_wrap_completion_handler_t)handler {
    xpc_object_t shared_ifaces = vmnet_copy_shared_interface_list();
    NSArray *ser_shared_ifaces = serialize_xpc_str_array(shared_ifaces);
    handler(ser_shared_ifaces);
}

- (instancetype)init:(NSXPCConnection *)con {
    self = [super init];
    if (self) {
        self.con = con;
        self.queue = dispatch_queue_create("com.trueToastedCode.ParaQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

@end

