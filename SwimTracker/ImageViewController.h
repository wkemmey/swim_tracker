#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
{
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIScrollView *scrollView;
}
@property (nonatomic, strong) UIImage *image;
@end
