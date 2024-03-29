#import "ItemStore.h"
#import "Item.h"
#import "ImageStore.h"

@implementation ItemStore

+ (ItemStore *)sharedStore
{
    static ItemStore *sharedStore = nil;
    if(!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
        
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init 
{
    self = [super init];
    if(self) {                
        // Read in SwimTracker.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // NSLog(@"model = %@", model);
        
        NSPersistentStoreCoordinator *psc = 
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?    
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path]; 
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType 
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        [self loadAllItems];        
    }
    return self;
}


- (void)loadAllItems 
{
    if (!allItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Item"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor 
                                sortDescriptorWithKey:@"orderingValue"
                                ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                            NSUserDomainMask, YES);
 
       // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];

    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

- (void)removeItem:(Item *)p
{
    NSString *key = [p imageKey];
    [[ImageStore sharedStore] deleteImageForKey:key];
    [context deleteObject:p];
    [allItems removeObjectIdenticalTo:p];
}

- (NSArray *)allItems
{
    return allItems;
}

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved so we can re-insert it
    Item *p = [allItems objectAtIndex:from];

    // Remove p from array
    [allItems removeObjectAtIndex:from];

    // Insert p in array at new location
    [allItems insertObject:p atIndex:to];

// Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;

    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allItems objectAtIndex:to - 1] orderingValue];
    } else {
        lowerBound = [[allItems objectAtIndex:1] orderingValue] - 2.0;
    }

    double upperBound = 0.0;

    // Is there an object after it in the array?
    if (to < [allItems count] - 1) {
        upperBound = [[allItems objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[allItems objectAtIndex:to - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;

    NSLog(@"moving to order %f", newOrderValue);
    [p setOrderingValue:newOrderValue];
}

- (Item *)createItem
{
    double order;
    if ([allItems count] == 0) {
        order = 1.0;
    } else {
        order = [[allItems lastObject] orderingValue] + 1.0;
    }
    NSLog(@"Adding after %d items, order = %.2f", [allItems count], order);

    Item *p = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                inManagedObjectContext:context];
    
    [p setOrderingValue:order];

    [allItems addObject:p];
   
    return p;
}

- (NSArray *)allDistanceTypes
{
    if (!allDistanceTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] 
                                  objectForKey:@"DistanceType"];
        
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        allDistanceTypes = [result mutableCopy];
    }
    
    // Is this the first time the program is being run?
    if ([allDistanceTypes count] == 0) {
        NSManagedObject *type;
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"DistanceType" 
                                             inManagedObjectContext:context];
        [type setValue:@"25" forKey:@"label"];
        [allDistanceTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"DistanceType"  
                                             inManagedObjectContext:context];
        [type setValue:@"50" forKey:@"label"];
        [allDistanceTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"DistanceType" 
                                             inManagedObjectContext:context];
        [type setValue:@"100" forKey:@"label"];
        [allDistanceTypes addObject:type];
        
    }
    return allDistanceTypes;
}

- (NSArray *)allEventTypes
{
    if (!allEventTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] 
                                  objectForKey:@"EventType"];
        
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        allEventTypes = [result mutableCopy];
    }
    
    // Is this the first time the program is being run?
    if ([allEventTypes count] == 0) {
        NSManagedObject *type;
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"EventType" 
                                             inManagedObjectContext:context];
        [type setValue:@"Freestyle" forKey:@"label"];
        [allEventTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"EventType"  
                                             inManagedObjectContext:context];
        [type setValue:@"Backstroke" forKey:@"label"];
        [allEventTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"EventType" 
                                             inManagedObjectContext:context];
        [type setValue:@"Breaststroke" forKey:@"label"];
        [allEventTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"EventType" 
                                             inManagedObjectContext:context];
        [type setValue:@"Butterfly" forKey:@"label"];
        [allEventTypes addObject:type];
        
    }
    return allEventTypes;
}

- (NSArray *)allPoolTypes
{
    if (!allPoolTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] 
                                  objectForKey:@"PoolType"];
        
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        allPoolTypes = [result mutableCopy];
    }
    
    // Is this the first time the program is being run?
    if ([allPoolTypes count] == 0) {
        NSManagedObject *type;
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"PoolType" 
                                             inManagedObjectContext:context];
        [type setValue:@"SCM" forKey:@"label"];
        [allPoolTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"PoolType"  
                                             inManagedObjectContext:context];
        [type setValue:@"SCY" forKey:@"label"];
        [allPoolTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"PoolType" 
                                             inManagedObjectContext:context];
        [type setValue:@"LCM" forKey:@"label"];
        [allPoolTypes addObject:type];
        
    }
    return allPoolTypes;
}

@end
