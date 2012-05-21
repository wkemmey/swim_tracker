#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * imageKey;
@property (nonatomic, retain) NSString * time;
@property (nonatomic) NSTimeInterval dateCreated;
@property (nonatomic, strong) UIImage * thumbnail;
@property (nonatomic) double orderingValue;
@property (nonatomic, retain) NSManagedObject *eventType;
@property (nonatomic, retain) NSManagedObject *distanceType;
@property (nonatomic, retain) NSManagedObject *poolType;

- (void)setThumbnailDataFromImage:(UIImage *)image;

@end
