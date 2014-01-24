
#import "RFPlugin.h"
#import "dout.h"

@implementation RFPlugin

- (id)init {
    self = [super init];
    if (self) {
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (id)initWithMaster:(id<RFPluginSupported>)master {
    self = [super init];
    if (self) {
        self.master = master;
        [self onInit];
//        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
    // Nothing
    [self afterInit];
}

- (void)afterInit {
#if DEBUG
    @weakify(self);
    dispatch_after_seconds(2.0, ^{
        @strongify(self);
        if (!self) return;
        
        if (self.master == nil) {
            dout_warning(@"%@: master not set yet", self);
        }
    });
#endif
}

- (void)dealloc {
    _dout(@"Dealloc: %@", self)
}

@end
