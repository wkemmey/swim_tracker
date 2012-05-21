#import "ImageViewController.h"

@implementation ImageViewController
@synthesize image;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGSize sz = [[self image] size];
    [scrollView setContentSize:sz];
    [imageView setFrame:CGRectMake(0, 0, sz.width, sz.height)];  
    
    [imageView setImage:[self image]];
}

@end
