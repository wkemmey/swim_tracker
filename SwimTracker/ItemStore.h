#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class Item;

@interface ItemStore : NSObject
{
    NSMutableArray *allItems;
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (ItemStore *)sharedStore;

- (void)removeItem:(Item *)p;

- (NSArray *)allItems;

- (Item *)createItem;

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;

- (NSString *)itemArchivePath;

- (BOOL)saveChanges;

- (NSArray *)allAssetTypes;

- (void)loadAllItems;

@end
