#import <UIKit/UIKit.h>

@class Item;

@interface DetailViewController : UIViewController
    <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>
{
    __weak IBOutlet UITextField *nameField;
//    __weak IBOutlet UITextField *poolField;
    __weak IBOutlet UITextField *timeField;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIImageView *imageView;

    __weak IBOutlet UIButton *eventTypeButton;
    __weak IBOutlet UIButton *distanceTypeButton;
    __weak IBOutlet UIButton *poolTypeButton;
    UIPopoverController *imagePickerPopover;
}

- (id)initForNewItem:(BOOL)isNew;

@property (nonatomic, strong) Item *item;

@property (nonatomic, copy) void (^dismissBlock)(void);

- (IBAction)takePicture:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)showEventTypePicker:(id)sender;
- (IBAction)showDistanceTypePicker:(id)sender;
- (IBAction)showPoolTypePicker:(id)sender;

@end
