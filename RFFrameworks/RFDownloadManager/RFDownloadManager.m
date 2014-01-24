
#import "RFDownloadManager.h"
#import "AFNetworking.h"

@interface RFDownloadManager ()
@property (RF_STRONG, atomic) NSMutableArray *requrestURLs;
@property (RF_STRONG, atomic) NSMutableArray *requrestOperationsQueue;
@property (RF_STRONG, atomic) NSMutableArray *requrestOperationsDownloading;
@property (RF_STRONG, atomic) NSMutableArray *requrestOperationsPaused;

@property (assign, readwrite, nonatomic) BOOL isDownloading;
@property (copy, nonatomic) NSString *tempFileStorePath;
@end

@implementation RFDownloadManager
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, downloading:%@, queue:%@, paused:%@>", [self class], self, self.requrestOperationsDownloading, self.requrestOperationsQueue, self.requrestOperationsPaused];
}

#pragma mark - Property
- (NSArray *)operations {
    return [[self.requrestOperationsDownloading arrayByAddingObjectsFromArray:self.requrestOperationsQueue]arrayByAddingObjectsFromArray:self.requrestOperationsPaused];
}

- (NSUInteger)operationsCountInQueue {
    return self.requrestOperationsDownloading.count+self.requrestOperationsQueue.count;
}

- (NSArray *)downloadingOperations {
    return [self.requrestOperationsDownloading copy];
}

- (BOOL)isDownloading {
    return (self.requrestOperationsDownloading.count > 0);
}

#pragma mark -
- (RFDownloadManager *)init {
    if ((self = [super init])) {
        _isDownloading = NO;
        _requrestURLs = [NSMutableArray array];
        _requrestOperationsQueue = [NSMutableArray array];
        _requrestOperationsDownloading = [NSMutableArray arrayWithCapacity:5];
        _requrestOperationsPaused = [NSMutableArray array];
        _maxRunningTaskCount = 3;
        return self;
    }
    return nil;
}

- (RFDownloadManager *)initWithDelegate:(id<RFDownloadManagerDelegate>)delegate {
    if ((self = [self init])) {
        self.delegate = delegate;
        return self;
    }
    return nil;
}

+ (instancetype)sharedInstance {
	static RFDownloadManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

#pragma mark -
- (RFFileDownloadOperation *)addURL:(NSURL *)url fileStorePath:(NSString *)destinationFilePath {
    if ([self.requrestURLs containsObject:url]) {
        dout_warning(@"RFDownloadManager: the url already existed. %@", url)
        return nil;
    }

    /// 临时禁用续传
    if (!url) {
        return nil;
    }
    RFFileDownloadOperation *downloadOperation = [[RFFileDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url] targetPath:destinationFilePath shouldResume:NO shouldCoverOldFile:YES];
    if (downloadOperation == nil) {
        return nil;
    }
    
    [self setupDownloadOperation:downloadOperation];
    [self.requrestOperationsQueue addObject:downloadOperation];
    [self.requrestURLs addObject:url];    
    return downloadOperation;
}

- (void)setupDownloadOperation:(RFFileDownloadOperation *)downloadOperation {
    __weak RFFileDownloadOperation *operation = downloadOperation;
    operation.deleteTempFileOnCancel = YES;
    
    [operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(RFDownloadManager:operationStateUpdate:totalBytesRead:totalBytesExpected:)]) {
            [self.delegate RFDownloadManager:self operationStateUpdate:operation totalBytesRead:totalBytesRead totalBytesExpected:totalBytesExpected];
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(RFFileDownloadOperation *operation, id responseObject) {
        // 完成，尝试下载下一个
        [self.requrestURLs removeObject:operation.request.URL];
        [self.requrestOperationsDownloading removeObject:operation];
        [self startNextQueuedOperation];

        if (self.delegate && [self.delegate respondsToSelector:@selector(RFDownloadManager:operationCompleted:)]) {
            [self.delegate RFDownloadManager:self operationCompleted:operation];
        }
    } failure:^(RFFileDownloadOperation *operation, NSError *error) {
        // 回退回队列
        [self.requrestOperationsDownloading removeObject:operation];
        [self.requrestOperationsPaused addObject:operation];
        [self startNextQueuedOperation];
        dout_error(@"%@", operation.error);
        _douto(self)
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(RFDownloadManager:operationFailed:)]) {
            [self.delegate RFDownloadManager:self operationFailed:operation];
        }
    }];
}

- (void)startAll {
    // Paused => Queue
    
    [self.requrestOperationsQueue unionArray:self.requrestOperationsPaused withBlock:^BOOL(NSMutableArray *aimArray, id obj2) {
        return  ![aimArray containsObject:obj2];
    }];
    
    [self.requrestOperationsPaused removeAllObjects];
    // Queue => Start
    
    while (self.requrestOperationsDownloading.count < _maxRunningTaskCount) {
        [self.requrestOperationsQueue unionArray:self.requrestOperationsPaused withBlock:^BOOL(NSMutableArray *aimArray, id obj2) {
            return  ![aimArray containsObject:obj2];
        }];
                
        [self.requrestOperationsPaused removeAllObjects];
        
        RFFileDownloadOperation *operation = self.requrestOperationsQueue[0];
        if (!operation) break;
        
        [self startOperation:operation];
    }
}
- (void)pauseAll {
    RFFileDownloadOperation *operation;
    // Downloading => Pause

    for (RFFileDownloadOperation *aOperation in self.requrestOperationsDownloading) {
        if (operation == aOperation) {
            [self pauseOperation:aOperation];
        }
    }
    
    [self.requrestOperationsPaused unionArray:self.self.requrestOperationsQueue withBlock:^BOOL(NSMutableArray *aimArray, id obj2) {
        return  ![aimArray containsObject:obj2];
    }];
    [self.requrestOperationsQueue removeAllObjects];
    
}
- (void)cancelAll {
    
    while ([self.requrestOperationsDownloading count]>0) 
        [self cancelOperation:self.requrestOperationsDownloading[0]];
    
    
    while ([self.requrestOperationsQueue count]>0) 
        [self cancelOperation:self.requrestOperationsQueue[0]];
    
    
    while ([self.requrestOperationsPaused count]>0) 
        [self cancelOperation:self.requrestOperationsPaused[0]];
    
}

// Note: 这些方法本身会管理队列
- (void)startOperation:(RFFileDownloadOperation *)operation {
    
    if (!operation) {
        dout_warning(@"RFDownloadManager > startOperation: operation is nil")
        return;
    }
    
    if (self.requrestOperationsDownloading.count < self.maxRunningTaskCount) {
        // 开始下载
        if ([operation isPaused]) {
            [operation resume];
        }
        else {
            [operation start];
        }
        
        [self.requrestOperationsDownloading addObject:operation];
        [self.requrestOperationsQueue removeObject:operation];
    }
    else {
        // 加入到队列
        [self.requrestOperationsQueue addObject:operation];
    }
    
    [self.requrestOperationsPaused removeObject:operation];
}
- (void)pauseOperation:(RFFileDownloadOperation *)operation {
    if (!operation) {
        dout_warning(@"RFDownloadManager > pauseOperation: operation is nil")
        return;
    }
    if (![operation isPaused]) {
        [operation pause];
        [self startNextQueuedOperation];
    }
    
    [self.requrestOperationsPaused addObject:operation];
    [self.requrestOperationsQueue removeObject:operation];
    [self.requrestOperationsDownloading removeObject:operation];
}
- (void)cancelOperation:(RFFileDownloadOperation *)operation {
    if (!operation) {
        dout_warning(@"RFDownloadManager > cancelOperation: operation is nil")
        return;
    }
    [operation cancel];
    
    [self.requrestURLs removeObject:operation.request.URL];
    [self.requrestOperationsDownloading removeObject:operation];
    [self.requrestOperationsQueue removeObject:operation];
    [self.requrestOperationsPaused removeObject:operation];
}
- (void)startNextQueuedOperation {
    if (self.requrestOperationsQueue.count > 0) {
        RFFileDownloadOperation *operationNext = self.requrestOperationsQueue[0];
        [self startOperation:operationNext];
    }
}

- (void)startOperationWithURL:(NSURL *)url {
    [self startOperation:[self findOperationWithURL:url]];
}
- (void)pauseOperationWithURL:(NSURL *)url {
    [self pauseOperation:[self findOperationWithURL:url]];
}
- (void)cancelOperationWithURL:(NSURL *)url {
    [self cancelOperation:[self findOperationWithURL:url]];
}

- (RFFileDownloadOperation *)findOperationWithURL:(NSURL *)url {
    RFFileDownloadOperation *operation = nil;
    
    for (operation in self.requrestOperationsDownloading) {
        if ([operation.request.URL.path isEqualToString:url.path]) {
            return operation;
        }
    }
    
    if (!operation) {
        for (operation in self.requrestOperationsQueue) {
            if ([operation.request.URL.path isEqualToString:url.path]) {
                return operation;
            }
        }
    }
    
    if (!operation) {
        for (operation in self.requrestOperationsPaused) {
            if ([operation.request.URL.path isEqualToString:url.path]) {
                return operation;
            }
        }
    }
    
    return nil;
}


@end

