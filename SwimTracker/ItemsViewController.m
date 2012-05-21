#import "ItemsViewController.h"
#import "ItemStore.h"
#import "Item.h"
#import "ItemCell.h"
#import "ImageStore.h"
#import "ImageViewController.h"

@implementation ItemsViewController

- (id)init 
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle:NSLocalizedString(@"SwimTracker", @"Application title")];

        // Create a new bar button item that will send
        // addNewItem: to ItemsViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] 
                        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                             target:self 
                                             action:@selector(addNewItem:)];

        // Set this bar button item as the right item in the navigationItem
        [[self navigationItem] setRightBarButtonItem:bbi];

        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];        
    }
    return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (io == UIInterfaceOrientationPortrait);
    } 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ItemCell" bundle:nil];
    
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ItemCell"];
}

- (IBAction)addNewItem:(id)sender
{
    // Create a new Item and add it to the store
    Item *newItem = [[ItemStore sharedStore] createItem];

    DetailViewController *detailViewController = 
            [[DetailViewController alloc] initForNewItem:YES];
    
    [detailViewController setItem:newItem];

    [detailViewController setDismissBlock:^{
        [[self tableView] reloadData];
    }];

    UINavigationController *navController = [[UINavigationController alloc] 
                                initWithRootViewController:detailViewController];
        
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];        
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:navController animated:YES completion:nil];
}  
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)tableView:(UITableView *)tableView 
    moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
           toIndexPath:(NSIndexPath *)toIndexPath 
{
    [[ItemStore sharedStore] moveItemAtIndex:[fromIndexPath row]
                                         toIndex:[toIndexPath row]];
}

- (void)tableView:(UITableView *)aTableView 
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:NO];
    
    NSArray *items = [[ItemStore sharedStore] allItems];
    Item *selectedItem = [items objectAtIndex:[indexPath row]];

    // Give detail view controller a pointer to the item object in row
    [detailViewController setItem:selectedItem];
    
    // Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:detailViewController
                                           animated:YES];
}

- (void)tableView:(UITableView *)tableView 
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
     forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ItemStore *ps = [ItemStore sharedStore];
        NSArray *items = [ps allItems];
        Item *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];

        // We also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[ItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *p = [[[ItemStore sharedStore] allItems]
                                    objectAtIndex:[indexPath row]];
    
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];

    [cell setController:self];
    [cell setTableView:tableView];

    // name
    
    NSString *eventTypeLabel = [[p eventType] valueForKey:@"label"];
    if(!eventTypeLabel)
        eventTypeLabel = @"None";
    
    NSString *distanceTypeLabel = [[p distanceType] valueForKey:@"label"];
    if(!distanceTypeLabel)
        distanceTypeLabel = @"None";
    
    [[cell nameLabel] setText:[NSString stringWithFormat:@"%@ %@", distanceTypeLabel, eventTypeLabel]];
    
    // time
    [[cell timeLabel] setText:[p time]];
    
    // pool type
    NSString *poolTypeLabel = [[p poolType] valueForKey:@"label"];
    if(!poolTypeLabel)
        poolTypeLabel = @"None";
    [[cell poolLabel] setText:[NSString stringWithFormat:@"%@", poolTypeLabel]];
    
    [[cell thumbnailView] setImage:[p thumbnail]];

    return cell;
}

- (void)showImage:(id)sender atIndexPath:(NSIndexPath *)ip 
{
    NSLog(@"Going to show the image for %@", ip);

    // Get the item for the index path
    Item *i = [[[ItemStore sharedStore] allItems] objectAtIndex:[ip row]];

    NSString *imageKey = [i imageKey];

    // If there is no image, we don't need to display anything
    UIImage *img = [[ImageStore sharedStore] imageForKey:imageKey];
    if(!img)
        return;
    
    // Make a rectangle that the frame of the button relative to 
    // our table view
    CGRect rect = [[self view] convertRect:[sender bounds] fromView:sender];
    
    // Create a new ImageViewController and set its image
    ImageViewController *ivc = [[ImageViewController alloc] init];
    [ivc setImage:img];
    
    // Present a 600x600 popover 
    imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
    [imagePopover setDelegate:self];
    [imagePopover setPopoverContentSize:CGSizeMake(600, 600)];
    [imagePopover presentPopoverFromRect:rect 
                                  inView:[self view] 
                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                animated:YES];
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [imagePopover dismissPopoverAnimated:YES];
    imagePopover = nil;
}
@end
