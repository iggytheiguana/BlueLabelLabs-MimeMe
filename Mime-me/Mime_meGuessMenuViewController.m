//
//  Mime_meGuessMenuViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meGuessMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meCreateMimeViewController.h"
#import "Mime_meGuessFullTableViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Mime_meAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "Mime.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"

#define kMIMEID @"mimeid"
#define kMAXROWS 3
#define kMAXROWSFRIENDS 5

@interface Mime_meGuessMenuViewController ()

@end

@implementation Mime_meGuessMenuViewController
@synthesize frc_mimes           = __frc_mimes;

@synthesize nv_navigationHeader = m_nv_navigationHeader;

@synthesize tbl_mimes           = m_tbl_mimes;
@synthesize tc_friendsHeader    = m_tc_friendsHeader;
@synthesize tc_recentHeader     = m_tc_recentHeader;
@synthesize tc_staffPicksHeader = m_tc_staffPicksHeader;

@synthesize friendsArray        = m_friendsArray;
@synthesize recentArray         = m_recentArray;
@synthesize staffPicksArray     = m_staffPicksArray;

#pragma mark - Properties
- (NSFetchedResultsController*)frc_mimes {
    NSString* activityName = @"Mime_meGuessMenuViewController.frc_mimes:";
    if (__frc_mimes != nil) {
        return __frc_mimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWSFRIENDS + 1)];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_mimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_mimes;
    
}

- (NSString*) getDateStringForMimeDate:(NSDate*)date {
    NSDate* now = [NSDate date];
    NSTimeInterval intervalSinceCreated = [now timeIntervalSinceDate:date];
    NSString* timeSinceCreated = nil;
    if (intervalSinceCreated < 1 ) {
        timeSinceCreated = @"a moment";
    }
    else {
        timeSinceCreated = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
    }
    
    return [NSString stringWithFormat:@"%@ ago",timeSinceCreated];
}

#pragma mark - View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add rounded corners to view
    [self.view.layer setCornerRadius:8.0f];
    
    // Add the navigation header
    Mime_meUINavigationHeaderView *navigationHeader = [[Mime_meUINavigationHeaderView alloc]initWithFrame:[Mime_meUINavigationHeaderView frameForNavigationHeader]];
    navigationHeader.delegate = self;
    navigationHeader.btn_back.hidden = YES;
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
    
    // TEMP: Data arrays for tableview
    self.friendsArray = [NSArray arrayWithObjects:@"Laura", @"Julie", @"Matt", @"David", @"Walter", @"John", nil];
    self.recentArray = [NSArray arrayWithObjects:@"Timmy", nil];
    self.staffPicksArray = [NSArray arrayWithObjects:@"Julie", @"Bobby", @"Jordan", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    
    self.tbl_mimes = nil;
    self.tc_friendsHeader = nil;
    self.tc_recentHeader = nil;
    self.tc_staffPicksHeader = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_guess setHighlighted:YES];
    [self.nv_navigationHeader.btn_guess setUserInteractionEnabled:NO];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    NSInteger rows;
    
    if (section == 0) {
        // From Friends section
        count = [[self.frc_mimes fetchedObjects]count] + 2;     // Add 2 to the count to include 1. Header, and 2. More
        rows = MIN(count, kMAXROWSFRIENDS + 2);   // Maximize the number of rows per section
    }
    else if (section == 1) {
        // Recent section
        count = [self.recentArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. More
        rows = MIN(count, kMAXROWS + 2);   // Maximize the number of rows per section
    }
    else {
        // Staff Picks section
        count = [self.staffPicksArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. More
        rows = MIN(count, kMAXROWS + 2);   // Maximize the number of rows per section
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // From Friends section
        
        NSInteger count = MIN([[self.frc_mimes fetchedObjects]count], kMAXROWSFRIENDS);    // Maximize the number of friends to show
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"FriendsHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_friendsHeader;
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Friend's mime
                    static NSString *CellIdentifier = @"FriendsMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    Mime *mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
                    
                    cell.textLabel.text = mime.creatorname;
                    
                    NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
                    cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
                    
                    ImageManager* imageManager = [ImageManager instance];
                    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:mime.objectid forKey:kMIMEID];
                    
                    if (mime.thumbnailurl != nil && ![mime.thumbnailurl isEqualToString:@""]) {
                        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                        callback.fireOnMainThread = YES;
                        UIImage* image = [imageManager downloadImage:mime.thumbnailurl withUserInfo:nil atCallback:callback];
                        [callback release];
                        if (image != nil) {
                            
                            cell.imageView.image = [image imageScaledToSize:CGSizeMake(50, 50)];
                                                        
                            [self.view setNeedsDisplay];
                        }
                        else {
                            cell.imageView.backgroundColor = [UIColor lightGrayColor];
                            cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(50, 50)];
                        }
                    }
                    
                    return cell;
                }
                else {
                    // Set More row
                    static NSString *CellIdentifier = @"MoreFromFriends";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More from friends";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set Invite Friends rows
                static NSString *CellIdentifier = @"InviteFriends";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"Invite more friends to play!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                return cell;
            }
        }
    }
    if (indexPath.section == 1) {
        // Recent section
        
        NSInteger count = MIN([self.recentArray count], kMAXROWS);    // Maximize the number of recent mimes to show to 3
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"RecentHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_recentHeader;
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Recent mime
                    static NSString *CellIdentifier = @"RecentMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = [self.recentArray objectAtIndex:(indexPath.row - 1)];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
                else {
                    // Set More row
                    static NSString *CellIdentifier = @"MoreFromRecent";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More recent mimes";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set None row
                static NSString *CellIdentifier = @"NoneRecent";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No recent Mimes!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    // Cell properties
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
    else {
        // Staff Picks section
        
        NSInteger count = MIN([self.staffPicksArray count], kMAXROWS);    // Maximize the number of staff pick mimes to show to 3
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"StaffPicksHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_staffPicksHeader;
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Staff Picked mime
                    static NSString *CellIdentifier = @"StaffPickMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = [self.staffPicksArray objectAtIndex:(indexPath.row - 1)];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
                else {
                    // Set More row
                    static NSString *CellIdentifier = @"MoreFromStaffPicks";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More staff picks";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set None row
                static NSString *CellIdentifier = @"NoneStaffPicks";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No staff picks!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    // Cell properties
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger count;
    NSUInteger rows;
    
    if (indexPath.section == 0) {
        count = [[self.frc_mimes fetchedObjects]count];
        rows = MIN(count, kMAXROWSFRIENDS);
    }
    else if (indexPath.section == 1) {
        // Recent section
        count = [self.recentArray count];
        rows = MIN(count, kMAXROWS);
    }
    else {
        // Staff Picks section
        count = [self.staffPicksArray count];
        rows = MIN(count, kMAXROWS);
    }
    
    if (indexPath.row == 0) {
        // Header
        return 50;
    }
    else if (indexPath.row > rows) {
        // Last row
        return 50;
    }
    else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Friends mime selected
        NSInteger count = MIN([[self.frc_mimes fetchedObjects]count], kMAXROWSFRIENDS);    // Maximize the number of friends to show
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
        }
        else {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstance];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        // Recent mime selected
        NSInteger count = [self.recentArray count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstance];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    else {
        // Staff Pick mime selected
        NSInteger count = [self.staffPicksArray count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstance];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    
}

#pragma mark - Mime_meUINavigationHeader Delegate Methods
- (IBAction) onHomeButtonPressed:(id)sender {
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
}

- (IBAction) onMimeButtonPressed:(id)sender {
    Mime_meCreateMimeViewController *mimeViewController = [Mime_meCreateMimeViewController createInstance];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:NO];
}

- (IBAction) onGuessButtonPressed:(id)sender {
    
}

- (IBAction) onScrapbookButtonPressed:(id)sender {
    
}

- (IBAction) onSettingsButtonPressed:(id)sender {
    Mime_meSettingsViewController *settingsViewController = [Mime_meSettingsViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:YES];
                     }];
    
    [self.navigationController pushViewController:settingsViewController animated:NO];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meGuessMenuViewController.controller.didChangeObject:";
    if (controller == self.frc_mimes) {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
    }
    else {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
//    NSString* activityName = @"Mime_meGuessMenuMimeViewController.onImageDownloadComplete:";
//    NSDictionary* userInfo = result.context;
//    NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
//    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
//    
//    if ([response.didSucceed boolValue] == YES) {
//        if ([mimeID isEqualToNumber:self.mimeID]) {
//            //we only draw the image if this view hasnt been repurposed for another photo
//            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
//            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
//            
//            self.imageSize = response.image.size;
//            
//            if (self.imageSize.height > self.imageSize.width) {
//                self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
//            }
//            else {
//                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
//            }
//            
//            [self.view setNeedsDisplay];
//        }
//    }
//    else {
//        self.iv_photo.backgroundColor = [UIColor blackColor];
//        self.iv_photo.image = [UIImage imageNamed:@"logo-MimeMe.png"];
//        LOG_IMAGE(1,@"%@Image failed to download",activityName);
//    }    
}

#pragma mark - Static Initializers
+ (Mime_meGuessMenuViewController*)createInstance {
    Mime_meGuessMenuViewController* instance = [[Mime_meGuessMenuViewController alloc]initWithNibName:@"Mime_meGuessMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
