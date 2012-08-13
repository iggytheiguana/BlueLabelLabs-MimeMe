//
//  Mime_meScrapbookFullTableViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meScrapbookFullTableViewController.h"
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
#import "Favorite.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"
#import "Mime_meViewMimeViewController.h"

#define kMIMEFRC @"mimefrc"

#define kMIMEID @"mimeid"
#define kMIMEANSWERID @"mimeanswerid"
#define kFAVORITEID @"favoriteid"

#define kMAXROWS 30

@interface Mime_meScrapbookFullTableViewController ()

@end

@implementation Mime_meScrapbookFullTableViewController
@synthesize frc_mimes           = __frc_mimes;
@synthesize mimeCloudEnumerator = m_mimeCloudEnumerator;
@synthesize nv_navigationHeader = m_nv_navigationHeader;
@synthesize tbl_mimes           = m_tbl_mimes;
@synthesize tc_sentHeader       = m_tc_sentHeader;
@synthesize tc_favoritesHeader  = m_tc_favoritesHeader;
@synthesize tc_guessedHeader    = m_tc_guessedHeader;
@synthesize mimeType            = m_mimeType;
@synthesize gad_bannerView      = m_gad_bannerView;

#pragma mark - Properties
- (NSFetchedResultsController*)frc_mimes {
    NSString* activityName = @"Mime_meScrapbookFullTableViewController.frc_mimes:";
    if (__frc_mimes != nil) {
        return __frc_mimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSEntityDescription *entityDescription;
    NSPredicate* predicate;
    
    if (self.mimeType == kSENTMIME) {
        entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
        
        predicate = [NSPredicate predicateWithFormat:@"%K=%@", CREATORID, self.loggedInUser.objectid];
    }
    else if (self.mimeType == kFAVORITEMIME) {
        entityDescription = [NSEntityDescription entityForName:FAVORITE inManagedObjectContext:app.managedObjectContext];
        
        predicate = [NSPredicate predicateWithFormat:@"%K=%@", USERID, self.loggedInUser.objectid];
    }
    else if (self.mimeType == kGUESSEDMIME) {
        entityDescription = [NSEntityDescription entityForName:MIMEANSWER inManagedObjectContext:app.managedObjectContext];
        
        NSNumber* answeredStateObj = [NSNumber numberWithInt:kANSWERED];
        predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@", TARGETUSERID, self.loggedInUser.objectid, STATE, answeredStateObj];
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
        LOG_MIME_MESCRAPBOOKFULLTABLEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
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
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Updating...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateMimes {    
    if (self.mimeCloudEnumerator != nil && [self.mimeCloudEnumerator canEnumerate]) {
        [self.mimeCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.mimeCloudEnumerator = nil;
        
        if (self.mimeType == kSENTMIME) {
            self.mimeCloudEnumerator = [CloudEnumerator enumeratorForSentMimes:self.loggedInUser.objectid];
        }
        else if (self.mimeType == kFAVORITEMIME) {
            self.mimeCloudEnumerator = [CloudEnumerator enumeratorForFavoriteMimes:self.loggedInUser.objectid];
        }
        else if (self.mimeType == kGUESSEDMIME) {
            NSNumber* answeredStateObj = [NSNumber numberWithInt:kANSWERED];
            self.mimeCloudEnumerator = [CloudEnumerator enumeratorForMimeAnswersWithTarget:self.loggedInUser.objectid withState:answeredStateObj];
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
    self.tc_sentHeader = nil;
    self.tc_favoritesHeader = nil;
    self.tc_guessedHeader = nil;
    self.gad_bannerView = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_scrapbook setHighlighted:YES];
    [self.nv_navigationHeader.btn_scrapbook setUserInteractionEnabled:NO];
    
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
    NSInteger rows = [[self.frc_mimes fetchedObjects]count] + 1;     // Add 2 to the count to include 1. Header
    
    return rows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime;
    
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo;
    
    if (self.mimeType == kSENTMIME) {
        // Sent Mimes section
        mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        NSString *wordStr = mime.word;
        cell.textLabel.text = wordStr;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
    }
    else if (self.mimeType == kFAVORITEMIME) {
        // Favorite Mimes section
        Favorite *favorite = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        // Get the Mime object associated with this Favorite
        mime = (Mime*)[resourceContext resourceWithType:MIME withID:favorite.mimeid];
        
        cell.textLabel.text = mime.word;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimes, kMIMEFRC, mime.objectid, kFAVORITEID, nil];
    }
    else if (self.mimeType == kGUESSEDMIME) {
        // Guessed Mimes section
        MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        // Get the Mime object associated with this MimeAnswer
        mime = (Mime*)[resourceContext resourceWithType:MIME withID:mimeAnswer.mimeid];
        
        cell.textLabel.text = mime.word;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimes, kMIMEFRC, mimeAnswer.objectid, kMIMEANSWERID, nil];
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
            
            if (self.mimeType == kSENTMIME) {
                CellIdentifier = @"SentHeader";
            }
            else if (self.mimeType == kFAVORITEMIME) {
                CellIdentifier = @"Favorites";
            }
            else if (self.mimeType == kGUESSEDMIME) {
                CellIdentifier = @"FavoriteHeader";
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                
                if (self.mimeType == kSENTMIME) {
                    cell = self.tc_sentHeader;
                }
                else if (self.mimeType == kFAVORITEMIME) {
                    cell = self.tc_favoritesHeader;
                }
                else if (self.mimeType == kGUESSEDMIME) {
                    cell = self.tc_guessedHeader;
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
                    
                    if (self.mimeType == kSENTMIME) {
                        cell.textLabel.text = @"No sent mimes!";
                    }
                    else if (self.mimeType == kFAVORITEMIME) {
                        cell.textLabel.text = @"No favorite mimes!";
                    }
                    else if (self.mimeType == kGUESSEDMIME) {
                        cell.textLabel.text = @"No guessed mimes!";
                    }
                    else {
                        cell.textLabel.text = @"No mimes in scrapbook!";
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
            
            if (self.mimeType == kSENTMIME) {
                cell.textLabel.text = @"No sent mimes!";
            }
            else if (self.mimeType == kFAVORITEMIME) {
                cell.textLabel.text = @"No favorite mimes!";
            }
            else if (self.mimeType == kGUESSEDMIME) {
                cell.textLabel.text = @"No guessed mimes!";
            }
            else {
                cell.textLabel.text = @"No mimes in scrapbook!";
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
    
    if (self.mimeType == kSENTMIME) {
        // Friends mime selected
        NSInteger count = [[self.frc_mimes fetchedObjects] count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSCRAPBOOKMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
    }
    else if (self.mimeType == kFAVORITEMIME) {
        // Recent mime selected
        NSInteger count = [[self.frc_mimes fetchedObjects] count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Favorite *favorite = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSCRAPBOOKMIME withMimeID:favorite.mimeid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
    }
    else if (self.mimeType == kGUESSEDMIME) {
        // Staff Pick mime selected
        NSInteger count = [[self.frc_mimes fetchedObjects] count];
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSCRAPBOOKMIME withMimeID:mimeAnswer.mimeid withMimeAnswerIDorNil:mimeAnswer.objectid];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
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

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meScrapbookFullTableViewController.controller.didChangeObject:";
    if (controller == self.frc_mimes) {
        LOG_MIME_MESCRAPBOOKFULLTABLEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
            [self.tbl_mimes reloadData];
        }
    }
    else {
        LOG_MIME_MESCRAPBOOKFULLTABLEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
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

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meGuessFullTableViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    //    NSFetchedResultsController *frc = (NSFetchedResultsController *)[userInfo valueForKey:kMIMEFRC];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        
        UITableViewCell *cell;
        
        if (self.mimeType == kSENTMIME) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = [[self.frc_mimes fetchedObjects] count];
            for (int i = 0; i < count; i++) {
                MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:i];
                if ([mimeAnswer.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        else if (self.mimeType == kFAVORITEMIME) {
            
            NSNumber* favoriteID = [userInfo valueForKey:kFAVORITEID];
            
            NSInteger count = [[self.frc_mimes fetchedObjects] count];
            for (int i = 0; i < count; i++) {
                Favorite *favorite = [[self.frc_mimes fetchedObjects] objectAtIndex:i];
                if ([favorite.objectid isEqualToNumber:favoriteID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        else if (self.mimeType == kGUESSEDMIME) {
            
            NSNumber* mimeAnswerID = [userInfo valueForKey:kMIMEANSWERID];
            
            NSInteger count = [[self.frc_mimes fetchedObjects] count];
            for (int i = 0; i < count; i++) {
                MimeAnswer *mimeAnswer = [[self.frc_mimes fetchedObjects] objectAtIndex:i];
                if ([mimeAnswer.objectid isEqualToNumber:mimeAnswerID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:2]];
                    
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
+ (Mime_meScrapbookFullTableViewController*)createInstanceForMimeType:(NSInteger)mimeType {
    Mime_meScrapbookFullTableViewController* instance = [[Mime_meScrapbookFullTableViewController alloc]initWithNibName:@"Mime_meScrapbookFullTableViewController" bundle:nil];
    [instance autorelease];
    instance.mimeType = mimeType;
    return instance;
}

@end
