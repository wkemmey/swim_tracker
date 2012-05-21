#import <Foundation/Foundation.h>

@interface ItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *poolLabel;

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *tableView;
- (IBAction)showImage:(id)sender;

@end
