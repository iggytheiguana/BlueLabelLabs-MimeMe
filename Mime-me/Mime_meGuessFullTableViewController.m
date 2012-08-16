//
//  Mime_meGuessFullTableViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meGuessFullTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meCreateMimeViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Mime_meAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "Mime.h"
#import "MimeType.h"
#import "MimeAnswer.h"
#import "MimeAnswerState.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"
#import "Mime_meViewMimeViewController.h"


#define kMIMEFRC @"mimefrc"

#define kMIMEANSWERID @"mimeanswerid"
#define kMIMEID @"mimeid"

#define kMAXROWS 200

@interface Mime_meGuessFullTableViewController ()

@end

@implementation Mime_meGuessFullTableViewController
@synthesize frc_mimes           = __frc_mimes;
@synthesize mimeCloudEnumerator = m_mimeCloudEnumerator;
@synthesize nv_navigationHeader = m_nv_navigationHeader;
@synthesize tbl_mimes           = m_tbl_mimes;
@synthesize tc_friendsHeader    = m_tc_friendsHeader;
@synthesize tc_recentHeader     = m_tc_recentHeader;
@synthesize tc_staffPicksHeader = m_tc_staffPicksHeader;
@synthesize mimeType            = m_mimeType;
@synthesize gad_bannerView      = m_gad_bannerView;


#pragma mark - Properties
- (NSFetchedResultsController*)frc_mimes {
    NSString* activityName = @"Mime_meGuessFullTableViewController.frc_mimes:";
    if (__frc_mimes != nil) {
        return __frc_mimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSEntityDescription *entityDescription;
    NSPredicate* predicate;
    
    if (self.mimeType == kFROMFRIENDMIME) {
        entityDescription = [NSEntityDescription entityForName:MIMEANSWER inManagedObjectContext:app.managedObjectContext];
        
        NSNumber* unansweredStateObj = [NSNumber numberWithInt:kUNANSWERED];
        predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@", TARGETUSERID, self.loggedInUser.objectid, STATE, unansweredStateObj];
    }
    else if (self.mimeType == kRECENTMIME) {
        entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
        
        NSNumber* hasAnsweredObj = [NSNumber numberWithBool:NO];
        predicate = [NSPredicate predicateWithFormat:@"%K!=%@ AND %K=%@", CREATORID, self.loggedInUser.objectid, HASANSWERED, hasAnsweredObj];
    }
    else if (self.mimeType == kSTAFFPICKEDMIME) {
        entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
        
        NSNumber* hasAnsweredObj = [NSNumber numberWithBool:NO];
        NSNumber* isStaffPickObj = [NSNumber numberWithBool:YES];
        predicate = [NSPredicate predicateWithFormat:@"%K!=%@ AND %K=%@ AND %K=%@", CREATORID, self.loggedInUser.objectid, ISSTAFFPICK, isStaffPickObj, HASANSWERED, hasAnsweredObj];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:kMAXROWS];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_mimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MEGUESSFULLTABLEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_mimes;
    
}

#pragma mark - Enumerators
- (void)showHUDForMimeEnumerators {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
//    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Updating...";
    NSNumber *maxDisplayTime = [NSNumber numberWithDouble:5.0];
//    NSNumber *maxDisplayTime = settings.http_timeout_seconds
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:maxDisplayTime showFinishedMessage:NO];
    
}

- (void) enumerateMimes {    
    if (self.mimeCloudEnumerator != nil && [self.mimeCloudEnumerator canEnumerate]) {
        [self.mimeCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.mimeCloudEnumerator = nil;
        
        if (self.mimeType == kFROMFRIENDMIME) {
            NSNumber* unansweredStateObj = [NSNumber numberWithInt:kUNANSWERED];
            self.mimeCloudEnumerator = [CloudEnumerator enumeratorForMimeAnswersWithTarget:self.loggedInUser.objectid withState:unansweredStateObj];
        }
        else if (self.mimeType == kRECENTMIME) {
            self.mimeCloudEnumerator = [CloudEnumerator enumeratorForMostRecentMimes];
        }
        else if (self.mimeType == kSTAFFPICKEDMIME) {
            self.mimeCloudEnumerator = [CloudEnumerator enumeratorForStaffPickedMimes];
        }
        
        self.mimeCloudEnumerator.delegate = self;
        self.mimeCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:kMAXROWS];
        [self.mimeCloudEnumerator enumerateUntilEnd:nil];
    }
    
    [self showHUDForMimeEnumerators];
}

#pragma mark - Helper Methods
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

- (void)initializeGADBannerView {
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    self.gad_bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Move the view into position at the bottom of the screen
    self.gad_bannerView.frame = CGRectMake(0.0, 430.0, 320.0, 50.0);
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    self.gad_bannerView.adUnitID = kGADPublisherID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.gad_bannerView.rootViewController = self;
    [self.view addSubview:self.gad_bannerView];
    
    // Initiate a generic request to load it with an ad.
    [self.gad_bannerView loadRequest:[GADRequest request]];
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
    navigationHeader.btn_back.hidden = NO;
    navigationHeader.btn_gemCount.hidden = YES;
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
    
    // Initialize Google AdMob Banner view
    [self initializeGADBannerView];
    
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
    self.gad_bannerView = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_guess setHighlighted:YES];
    [self.nv_navigationHeader.btn_guess setUserInteractionEnabled:NO];
    
    // Enumerate for Mimes
    [self enumerateMimes];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [[self.frc_mimes fetchedObjects]count] + 1;     // Add 1 to the count to include 1. Header
    
    return rows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime;
    
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo;
    
    if (self.mimeType == kFROMFRIENDMIME) {
        // From Friends section
        MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        // Get the Mime object associated with this MimeAnswer
        mime = (Mime*)[resourceContext resourceWithType:MIME withID:mimeAnswer.mimeid]; 
        
        NSString *creatorName = mimeAnswer.creatorname;
        cell.textLabel.text = creatorName;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mimeAnswer.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimes, kMIMEFRC, mimeAnswer.objectid, kMIMEANSWERID, nil];
    }
    else if (self.mimeType == kRECENTMIME) {
        // Recent Mimes section
        mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        cell.textLabel.text = mime.creatorname;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
    }
    else if (self.mimeType == kSTAFFPICKEDMIME) {
        // Staff Picked Mimes section
        mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        cell.textLabel.text = mime.creatorname;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
    }
    
    // Set the mime image
    if (mime.thumbnailurl != nil && ![mime.thumbnailurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        callback.fireOnMainThread = YES;
        UIImage* image = [imageManager downloadImage:mime.thumbnailurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            
            cell.imageView.image = [image imageScaledToSize:CGSizeMake(50, 50)];
        }
        else {
            cell.imageView.backgroundColor = [UIColor lightGrayColor];
            cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(50, 50)];
        }
        
        [self.view setNeedsDisplay];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // Set the header
            
            if (self.mimeType == kFROMFRIENDMIME) {
                CellIdentifier = @"FromFriends";
            }
            else if (self.mimeType == kRECENTMIME) {
                CellIdentifier = @"MostRecent";
            }
            else if (self.mimeType == kSTAFFPICKEDMIME) {
                CellIdentifier = @"StaffPicks";
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                
                if (self.mimeType == kFROMFRIENDMIME) {
                    cell = self.tc_friendsHeader;
                }
                else if (self.mimeType == kRECENTMIME) {
                    cell = self.tc_recentHeader;
                }
                else if (self.mimeType == kSTAFFPICKEDMIME) {
                    cell = self.tc_staffPicksHeader;
                }
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            // Set the mime
            
            NSInteger count = [[self.frc_mimes fetchedObjects]count];
            
            if (indexPath.row > 0 && indexPath.row <= count) {
                // Set mime
                CellIdentifier = @"Mime";
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
                
                [self configureCell:cell atIndexPath:indexPath];
                
                return cell;
            }
            else {
                // Set None row
                CellIdentifier = @"NoMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    if (self.mimeType == kFROMFRIENDMIME) {
                        cell.textLabel.text = @"No mimes from friends!";
                    }
                    else if (self.mimeType == kRECENTMIME) {
                        cell.textLabel.text = @"No recent mimes!";
                    }
                    else if (self.mimeType == kSTAFFPICKEDMIME) {
                        cell.textLabel.text = @"No staff picks!";
                    }
                    else {
                        cell.textLabel.text = @"No mimes to guess!";
                    }
                    
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
    else {
        // Set None row
        CellIdentifier = @"NoMimes";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            if (self.mimeType == kFROMFRIENDMIME) {
                cell.textLabel.text = @"No mimes from friends!";
            }
            else if (self.mimeType == kRECENTMIME) {
                cell.textLabel.text = @"No recent Mimes!";
            }
            else if (self.mimeType == kSTAFFPICKEDMIME) {
                cell.textLabel.text = @"No staff picks!";
            }
            else {
                cell.textLabel.text = @"No mimes to guess!";
            }
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            cell.textLabel.textColor = [UIColor lightGrayColor];
            
            cell.userInteractionEnabled = NO;
        }
        
        return cell;
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
    NSUInteger rows = [[self.frc_mimes fetchedObjects]count];
    
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
    
    if (self.mimeType == kFROMFRIENDMIME) {
        // Friends mime selected
        NSInteger count = [[self.frc_mimes fetchedObjects] count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mimeAnswer.mimeid withMimeAnswerIDorNil:mimeAnswer.objectid];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
    }
    else if (self.mimeType == kRECENTMIME) {
        // Recent mime selected
        NSInteger count = [[self.frc_mimes fetchedObjects] count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
    }
    else if (self.mimeType == kSTAFFPICKEDMIME) {
        // Staff Pick mime selected
        NSInteger count = [[self.frc_mimes fetchedObjects] count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_mimes beginUpdates];
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_mimes endUpdates];
//}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meGuessFullTableViewController.controller.didChangeObject:";
    
//    UITableView *tableView = self.tbl_mimes;
    
    if (type == NSFetchedResultsChangeDelete)
    {
        LOG_MIME_MEGUESSFULLTABLEVIEWCONTROLLER(0,@"%@ Received NSFetechedResultsChangeDelete notification",activityName);
    }
    
//    NSInteger section = 0;
    
    if (controller == self.frc_mimes) {
        LOG_MIME_MEGUESSFULLTABLEVIEWCONTROLLER(0, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
//            switch(type) {
//                    
//                case NSFetchedResultsChangeInsert:
//                    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(newIndexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    break;
//                    
//                case NSFetchedResultsChangeDelete:
//                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    break;
//                    
//                case NSFetchedResultsChangeUpdate:
//                    [self configureCell:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]]
//                            atIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]];
//                    break;
//                    
//                case NSFetchedResultsChangeMove:
//                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(newIndexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    break;
//            }
            
            [self.tbl_mimes reloadData];
        }
    }
    else {
        LOG_MIME_MEGUESSFULLTABLEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    
    [self hideProgressBar];
    
    if (enumerator == self.mimeCloudEnumerator) {
        
    }
}

#pragma mark - MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meGuessFullTableViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    //    Request* request = [progressView.requests objectAtIndex:0];
    //    //now we have the request
    //    NSArray* changedAttributes = request.changedAttributesList;
    //    //list of all changed attributes
    //    //we take the first one and base our messaging off that
    //    NSString* attributeName = [changedAttributes objectAtIndex:0];
    
    if (progressView.didSucceed) {
        //enumeration was sucessful
        LOG_REQUEST(0, @"%@ Mime and MimeAnswer enumeration was successful", activityName);
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(1, @"%@ Mime and MimeAnswer enumeration failure", activityName);
        
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meGuessFullTableViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
//    NSFetchedResultsController *frc = (NSFetchedResultsController *)[userInfo valueForKey:kMIMEFRC];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        
        UITableViewCell *cell;
        
        if (self.mimeType == kFROMFRIENDMIME) {
            
            NSNumber* mimeAnswerID = [userInfo valueForKey:kMIMEANSWERID];
            
            NSInteger count = [[self.frc_mimes fetchedObjects] count];
            for (int i = 0; i < count; i++) {
                MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:i];
                if ([mimeAnswer.objectid isEqualToNumber:mimeAnswerID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        else if (self.mimeType == kRECENTMIME) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = [[self.frc_mimes fetchedObjects] count];
            for (int i = 0; i < count; i++) {
                Mime *mime = [[self.frc_mimes fetchedObjects] objectAtIndex:i];
                if ([mime.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        else if (self.mimeType == kSTAFFPICKEDMIME) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = [[self.frc_mimes fetchedObjects] count];
            for (int i = 0; i < count; i++) {
                Mime *mime = [[self.frc_mimes fetchedObjects] objectAtIndex:i];
                if ([mime.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        
        //we only draw the image if this view hasnt been repurposed for another photo
        LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
        
        UIImage *image = [response.image imageScaledToSize:CGSizeMake(50, 50)];
        
        [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        
        [self.view setNeedsDisplay];
    }    
}


#pragma mark - Static Initializers
+ (Mime_meGuessFullTableViewController*)createInstanceForMimeType:(NSInteger)mimeType {
    Mime_meGuessFullTableViewController* instance = [[Mime_meGuessFullTableViewController alloc]initWithNibName:@"Mime_meGuessFullTableViewController" bundle:nil];
    [instance autorelease];
    instance.mimeType = mimeType;
    return instance;
}

@end
