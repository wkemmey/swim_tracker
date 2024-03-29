#import "DetailViewController.h"
#import "Item.h"
#import "ImageStore.h"
#import "ItemStore.h"
#import "EventTypePicker.h"
#import "DistanceTypePicker.h"
#import "PoolTypePicker.h"


@implementation DetailViewController
@synthesize item;
@synthesize dismissBlock;

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] 
                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                         target:self 
                                         action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];            
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] 
                    initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                         target:self 
                                         action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
        }
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem:"
                                 userInfo:nil];
    return nil;
}


- (void)setItem:(Item *)i
{
    item = i;
    [[self navigationItem] setTitle:[item itemName]];
}

- (IBAction)save:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}

- (IBAction)cancel:(id)sender
{
    // If the user cancelled, then remove the Item from the store
    [[ItemStore sharedStore] removeItem:item];

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //[nameField setText:[item itemName]];
    [timeField setText:[item time]];
    //[valueField setText:[NSString stringWithFormat:@"%d", [item valueInDollars]]];

    // Create a NSDateFormatter that will turn a date into a simple date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    // Use filtered NSDate object to set dateLabel contents
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[item dateCreated]];
    [dateLabel setText:[dateFormatter stringFromDate:date]];

    NSString *imageKey = [item imageKey];
    if (imageKey) {
        // Get image for image key from image store
        UIImage *imageToDisplay =
        [[ImageStore sharedStore] imageForKey:imageKey];
        // Use that image to put on the screen in imageView
        [imageView setImage:imageToDisplay];
    } else {
        // Clear the imageView
        [imageView setImage:nil];
    }
    
    // event type
    NSString *eventTypeLabel = [[item eventType] valueForKey:@"label"];
    if(!eventTypeLabel)
        eventTypeLabel = @"None";
    [eventTypeButton setTitle:[NSString stringWithFormat:@"Event: %@", eventTypeLabel]
                     forState:UIControlStateNormal];

    // distance type
    NSString *distanceTypeLabel = [[item distanceType] valueForKey:@"label"];
    if(!distanceTypeLabel)
        distanceTypeLabel = @"None";
    [distanceTypeButton setTitle:[NSString stringWithFormat:@"Distance: %@", distanceTypeLabel]
                     forState:UIControlStateNormal];

    // pool type
    NSString *poolTypeLabel = [[item poolType] valueForKey:@"label"];
    if(!poolTypeLabel)
        poolTypeLabel = @"None";
    [poolTypeButton setTitle:[NSString stringWithFormat:@"Pool Type: %@", poolTypeLabel]
                     forState:UIControlStateNormal];
    
    // Change the navigation item to display name of item
    // should really check to be sure both of these are set; could get "None None"
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@ %@", distanceTypeLabel, eventTypeLabel]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (io == UIInterfaceOrientationPortrait);
    } 
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *clr = nil;  
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1];
    } else {
        clr = [UIColor groupTableViewBackgroundColor];
    }
    [[self view] setBackgroundColor:clr];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES; 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Clear first responder
    [[self view] endEditing:YES];

    // "Save" changes to item
    [item setItemName:@"fix this"];
    [item setTime:[timeField text]];
}

- (IBAction)takePicture:(id)sender 
{
    if([imagePickerPopover isPopoverVisible]) {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
        return;
    }   

    NSString *oldKey = [item imageKey];
    // Did the item already have an image?
    if (oldKey) {
        // Delete the old image
        [[ImageStore sharedStore] deleteImageForKey:oldKey];
    }
    
    UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
    
    // If our device has a camera, we want to take a picture, otherwise, we
    // just pick from photo library
    if ([UIImagePickerController
            isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];

    // Place image picker on the screen
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Create a new popover controller that will display the imagePicker
        imagePickerPopover = [[UIPopoverController alloc] 
                initWithContentViewController:imagePicker];
    
        [imagePickerPopover setDelegate:self];
    
        // Display the popover controller, sender 
        // is the camera bar button item
        [imagePickerPopover presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    imagePickerPopover = nil;
}

- (IBAction)backgroundTapped:(id)sender 
{
    [[self view] endEditing:YES];
    NSLog(@"%@", [self presentingViewController]);
}

- (IBAction)showEventTypePicker:(id)sender {
    [[self view] endEditing:YES];
    
    EventTypePicker *eventTypePicker = [[EventTypePicker alloc] init];
    [eventTypePicker setItem:item];
    
    [[self navigationController] pushViewController:eventTypePicker
                                           animated:YES];
}

- (IBAction)showDistanceTypePicker:(id)sender {
    [[self view] endEditing:YES];
    
    DistanceTypePicker *distanceTypePicker = [[DistanceTypePicker alloc] init];
    [distanceTypePicker setItem:item];
    
    [[self navigationController] pushViewController:distanceTypePicker
                                           animated:YES];
}

- (IBAction)showPoolTypePicker:(id)sender {
    [[self view] endEditing:YES];
    
    PoolTypePicker *poolTypePicker = [[PoolTypePicker alloc] init];
    [poolTypePicker setItem:item];
    
    [[self navigationController] pushViewController:poolTypePicker
                                           animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    [item setThumbnailDataFromImage:image];
    
    // Create a CFUUID object - it knows how to create unique identifier strings
    CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);

    // Create a string from unique identifier
    CFStringRef newUniqueIDString =
            CFUUIDCreateString (kCFAllocatorDefault, newUniqueID);

    // Use that unique ID to set our item's imageKey
    NSString *key = (__bridge NSString *)newUniqueIDString;
    [item setImageKey:key];
    
    
    // Store image in the ImageStore with this key
    [[ImageStore sharedStore] setImage:image
                                         forKey:[item imageKey]];

    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
            
    // Put that image onto the screen in our image view
    [imageView setImage:image];

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // If on the phone, the image picker is presented modally. Dismiss it.
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {    
        // If on the ipad, the image picker is in the popover. Dismiss the popover.
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }

}

@end
