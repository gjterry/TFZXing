//
//  DataStack.m
//  xiaoxi
//
//  Created by BB9z on 13-1-9.
//  Copyright (c) 2013年 edoctor. All rights reserved.
//



#import "DataStack.h"

@implementation DataStack

+ (instancetype)sharedInstance {
	static DataStack *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        __weak __typeof__(self) selfRef = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [selfRef save];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [selfRef save];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (NSURL *)dataBaseURL {
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [baseURL URLByAppendingPathComponent:@".cache"];
}

- (NSFetchRequest *)fetchRequestTemplateForName:(NSString *)name {
    return [[self.managedObjectModel fetchRequestTemplateForName:name] copy];
}

- (void)save {
    if ([self.context hasChanges]) {
        [self.context save];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Core Data Stack
- (NSManagedObjectContext *)context {
    if (!_context) {
        if (self.persistentStoreCoordinator) {
            _context = [[NSManagedObjectContext alloc] init];
            [_context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        }
    }
    return _context;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"momd"];
        RFAssert(modelURL, @"Model地址需要修改");
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSDictionary *option = @{
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption : @YES
        };
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.dataBaseURL options:option error:&error]) {
                ///需要进行数据迁移
            dout_error(@"%@", error)
        }
    }
    NSLog(@"%d",self.managedObjectModel.entities.count);
    return _persistentStoreCoordinator;
}

@end

@implementation NSManagedObjectContext (DataStack)
- (BOOL)save {
    NSError *e = nil;
    [self save:&e];
    if (e) {
        dout_error(@"%@", e);
        return NO;
    }
    return YES;
}

@end

@implementation NSManagedObject (DataStack)

- (void)destroy {
    [self.managedObjectContext deleteObject:self];
}

@end
