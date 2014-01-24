
#import "RFCoreDataAutoFetchTableViewPlugin.h"
#import <objc/runtime.h>


static void *const RFCoreDataAutoFetchTableViewPluginKVOContext = (void *)&RFCoreDataAutoFetchTableViewPluginKVOContext;

@interface RFCoreDataAutoFetchTableViewPlugin ()
@property (RF_STRONG, readwrite, nonatomic) NSFetchedResultsController *fetchController;

@property (nonatomic, retain) NSMutableArray *customDataArray;
@end

@implementation RFCoreDataAutoFetchTableViewPlugin

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        [self willChangeValueForKey:@keypath(self, tableView)];
        tableView.coreDataAutoFetchTableViewPlugin = self;
        tableView.dataSource = self;
        _tableView = tableView;
        [self didChangeValueForKey:@keypath(self, tableView)];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, fetchedResultsController = %@, master = %@, tableView = %p>", [self class], self, self.fetchController, self.master, self.tableView];
}

#pragma mark -
- (void)afterInit {
//    [super setup];
//    [super afterInit];
    [self registObservers];
    [self setupFetchController];
}

- (void)setupFetchController {
    if (self.managedObjectContext && self.request) {
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request
                                                                   managedObjectContext:self.managedObjectContext
                                                                     sectionNameKeyPath:self.fetchSectionNameKeyPath
                                                                              cacheName:self.fetchCacheName];
        self.fetchController.delegate = self;
        if (self.fetchedDataInCustomMode) {
            self.customDataArray = [NSMutableArray arrayWithCapacity:0];
        }
        [self performFetch];
    }
}

- (void)performFetch {
    if (self.fetchController) {
        NSLog(@"performFetch");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *e = nil;
            BOOL success = [self.fetchController performFetch:&e];
            if (e || !success) {
                dout_error(@"RFCoreDataAutoFetchTableViewPlugin fetch error:%@", e);
            }
            
            if (self.fetchedDataInCustomMode) {
                [self.fetchController.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionaryWithCapacity:0];
                    [sectionDict setObject:[NSString stringWithFormat:@"%d",idx] forKey:@"index"];
                    id <NSFetchedResultsSectionInfo> sectionInfo  = self.fetchController.sections[idx];
                    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:0];
                    [[sectionInfo objects]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        id o = [self.master RFCoreDataAutoFetchTablePlugin:self canAddManagedObject:obj];
                        if (o)
                            [tmp addObject:o];
                    }];
                    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTablePlugin:sortingSource:)]) {
                        tmp = [NSMutableArray arrayWithArray:[self.master RFCoreDataAutoFetchTablePlugin:self sortingSource:tmp]];
                    }
                    [sectionDict setObject:tmp forKey:@"data"];
                    [self.customDataArray addObject:sectionDict];
                }];
            }
            [self.tableView reloadData];
        });
    }
}


- (void)registObservers {
    [self addObserver:self forKeyPath:@keypath(self, request) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, request.predicate) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, request.sortDescriptors) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, managedObjectContext) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, request) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, request.predicate) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, request.sortDescriptors) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, managedObjectContext) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == RFCoreDataAutoFetchTableViewPluginKVOContext && object == self) {
        if ([keyPath isEqualToString:@keypath(self, request)]) {
            if (self.managedObjectContext) {
                [self setupFetchController];
            }
            return;
        }
        
        if ([keyPath isEqualToString:@keypath(self, request.predicate)] ||
            [keyPath isEqualToString:@keypath(self, request.sortDescriptors)]) {
            [self performFetch];
            return;
        }
        
        if ([keyPath isEqualToString:@keypath(self, managedObjectContext)]) {
            if (self.request) {
                [self setupFetchController];
            }
            return;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSManagedObject *)fetchedObjectAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fetchedDataInCustomMode) {
      return  self.customDataArray[indexPath.section][@"data"][indexPath.row];
    }
    return [self.fetchController objectAtIndexPath:[self indexPathForFetchedObjectAtTableIndexPath:indexPath]];
}

- (NSIndexPath *)indexPathForFetchedObjectAtTableIndexPath:(NSIndexPath *)indexPath {
    NSInteger countBefore = [self numberOfRowsBeforeFetchedRowsInSection:indexPath.section];
    if (indexPath.row >= countBefore) {
        return [NSIndexPath indexPathForRow:indexPath.row-countBefore inSection:indexPath.section];
    }
    return nil;
}

- (NSUInteger)numberOfRowsBeforeFetchedRowsInSection:(NSInteger)section {
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsBeforeFetchedRowsInSection:)]) {
        return [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsBeforeFetchedRowsInSection:section];
    }
    return 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:shouldCloseSectionInSection:)]) {
        if ([self.master RFCoreDataAutoFetchTableViewPlugin:self shouldCloseSectionInSection:section]) {
            return 0;
        }
    }
    NSInteger extraCount = 0;
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsBeforeFetchedRowsInSection:)]) {
        extraCount += [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsBeforeFetchedRowsInSection:section];
    }
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsAfterFetchedRowsInSection:)]) {
        extraCount += [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsAfterFetchedRowsInSection:section];
    }
    
    if (self.fetchedDataInCustomMode) {
           NSInteger count = [self.customDataArray[section][@"data"]count];
        
        return count + extraCount;
    }else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController sections][section];
        
        return [sectionInfo numberOfObjects] + extraCount;
    }
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    RFAssert(self.master, @"RFCoreDataAutoFetchTableViewPlugin must have a master.");
    if (self.fetchedDataInCustomMode) {
        cell = [self.master RFCoreDataAutoFetchTableViewPlugin:self
                                         cellForRowAtIndexPath:indexPath
                                                 managedObject:[self fetchedObjectAtIndexPath:indexPath]];
    }else {
     cell = [self.master RFCoreDataAutoFetchTableViewPlugin:self
                                                          cellForRowAtIndexPath:indexPath
                                                                  managedObject:[self fetchedObjectAtIndexPath:indexPath]];
    }

    RFAssert(cell, @"Master must return a cell.");
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.fetchedDataInCustomMode) {
        return self.customDataArray.count;
    }
    NSInteger count = [[self.fetchController sections] count];
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.fetchedDataInCustomMode) {
        return @"";
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController sections][section];
    return [sectionInfo name];
}


#pragma mark - Other fallback table view data source
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.master respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [self.master tableView:tableView titleForFooterInSection:section];
    }
    return nil;
}

// Default changed to NO.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.master respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [self.master tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.master respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        return [self.master tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return YES;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self.master respondsToSelector:@selector(sectionIndexTitlesForTableView:)]) {
        return [self sectionIndexTitlesForTableView:tableView];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.fetchedDataInCustomMode) {
        
    }
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchController sections]) {
        if ([[sectionInfo indexTitle] isEqualToString:title]) {
            return [[self.fetchController sections] indexOfObject:sectionInfo];
        }
    }
    
    if ([self.master respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)]) {
        return [self.master tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    return NSNotFound;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.master respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.master tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self.master respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.master tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *table = self.tableView;
    
    // Convert from fetch indexPath to table indexPath, add rows before.
    NSInteger countBefore = [self numberOfRowsBeforeFetchedRowsInSection:indexPath.section];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row+countBefore inSection:indexPath.section];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row+countBefore inSection:newIndexPath.section];
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
            [table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeUpdate:
            [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeMove:
            [table moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	UITableView *table = self.tableView;
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[table insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
            
        case NSFetchedResultsChangeUpdate:
            [table reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            douts(@"NSFetchedResultsChangeMove for section")
            dout(@"%@", sectionInfo)
            dout_int(sectionIndex)
            RFAssert(false, @"need implementation");
            break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.master) {
        [self.tableView endUpdates];        
    }

}

@end

static char RFCoreDataAutoFetchTableViewPluginCateogryProperty;

@implementation UITableView (RFCoreDataAutoFetchTableViewPlugin)
@dynamic coreDataAutoFetchTableViewPlugin;

- (RFCoreDataAutoFetchTableViewPlugin *)coreDataAutoFetchTableViewPlugin {
    return objc_getAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty);
}

- (void)setCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)coreDataAutoFetchTableViewPlugin {
    if (self.coreDataAutoFetchTableViewPlugin != coreDataAutoFetchTableViewPlugin) {
        [self willChangeValueForKey:@keypath(self, coreDataAutoFetchTableViewPlugin)];
        objc_setAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty, coreDataAutoFetchTableViewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@keypath(self, coreDataAutoFetchTableViewPlugin)];
    }
}

@end
