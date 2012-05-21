#import "ItemCell.h"

@implementation ItemCell
@synthesize poolLabel;
@synthesize timeLabel;
@synthesize thumbnailView;
@synthesize nameLabel;
@synthesize controller;
@synthesize tableView;

- (IBAction)showImage:(id)sender 
{
    NSString *selector = NSStringFromSelector(_cmd);
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    SEL newSelector = NSSelectorFromString(selector);
    
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    if(indexPath) {
        if([controller respondsToSelector:newSelector]) {
            [controller performSelector:newSelector withObject:sender 
                             withObject:indexPath];
        }
    }
}
@end
