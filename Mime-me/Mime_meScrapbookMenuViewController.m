//
//  Mime_meScrapbookMenuViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meScrapbookMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meGuessMenuViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Mime_meAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "Mime.h"
#import "MimeAnswer.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"
#import "Mime_meViewMimeViewController.h"
#import "Mime_meScrapbookFullTableViewController.h"


#define kSENTMIMESFRC @"sentmimesfrc"
#define kFAVORITEMIMESFRC @"favoritemimesfrc"
#define kGUESSEDMIMESFRC @"guessedmimesfrc"
#define kMIMEID @"mimeid"
#define kMIMEANSWERID @"mimeanswerid"

#define kMAXROWS 3

@interface Mime_meScrapbookMenuViewController ()

@end

@implementation Mime_meScrapbookMenuViewController
@synthesize frc_sentMimes           = __frc_sentMimes;
@synthesize frc_favoriteMimes       = __frc_favoriteMimes;
@synthesize frc_guessedMimes        = __frc_guessedMimes;

@synthesize nv_navigationHeader     = m_nv_navigationHeader;
@synthesize tbl_scrapbook           = m_tbl_scrapbook;
@synthesize tc_sentHeader           = m_tc_sentHeader;
@synthesize tc_favoritesHeader      = m_tc_favoritesHeader;
@synthesize tc_guessedHeader        = m_tc_guessedHeader;


#pragma mark - Properties
- (NSFetchedResultsController*)frc_sentMimes {
    NSString* activityName = @"Mime_meScrapbookMenuViewController.frc_sentMimes:";
    if (__frc_sentMimes != nil) {
        return __frc_sentMimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_sentMimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_sentMimes;
    
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
    [self.view.layer setMasksToBounds:YES];
    
    // Add the navigation header
    Mime_meUINavigationHeaderView *navigationHeader = [[Mime_meUINavigationHeaderView alloc]initWithFrame:[Mime_meUINavigationHeaderView frameForNavigationHeader]];
    navigationHeader.delegate = self;
    navigationHeader.btn_back.hidden = YES;
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    self.tbl_scrapbook = nil;
    self.tc_sentHeader = nil;
    self.tc_favoritesHeader = nil;
    self.tc_guessedHeader = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_scrapbook setHighlighted:YES];
    [self.nv_navigationHeader.btn_scrapbook setUserInteractionEnabled:NO];
    
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
        // Sent section
        count = [[self.frc_sentMimes fetchedObjects]count] + 2;     // Add 2 to the count to include 1. Header, and 2. More
        rows = MIN(count, kMAXROWS + 2);   // Maximize the number of rows per section
    }
    else if (section == 1) {
        // Favorites section
        count = 0 + 2;  // Add 2 to the count to include 1. Header, and 2. More
        rows = MIN(count, kMAXROWS + 2);   // Maximize the number of rows per section
    }
    else {
        // Guessed section
        count = 0 + 2;  // Add 2 to the count to include 1. Header, and 2. More
        rows = MIN(count, kMAXROWS + 2);   // Maximize the number of rows per section
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // From Friends section
        
        NSInteger count = MIN([[self.frc_sentMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of mimes to show
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"SentHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_sentHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set sent mime
                    static NSString *CellIdentifier = @"SentMime";
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
                    
                    Mime *mime = [[self.frc_sentMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
                    
                    cell.textLabel.text = mime.word;
                    
                    NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
                    cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
                    
                    ImageManager* imageManager = [ImageManager instance];
                    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_sentMimes, kSENTMIMESFRC, mime.objectid, kMIMEID, nil];
                    
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
                    
                    return cell;
                }
                else {
                    // Set More row
                    static NSString *CellIdentifier = @"MoreSentMimes";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More sent mimes";
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
                // Set no sent mimes row
                static NSString *CellIdentifier = @"NoSentMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No sent mimes!";
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
    if (indexPath.section == 1) {
        // Favorite Mimes section
        
//        NSInteger count = MIN([self.recentArray count], kMAXROWS);    // Maximize the number of mimes to show to 3
        NSInteger count = 0;
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"FavoritesHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_favoritesHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Favorite mime
                    static NSString *CellIdentifier = @"FavoriteMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
//                        cell.textLabel.text = [self.recentArray objectAtIndex:(indexPath.row - 1)];
                        cell.textLabel.text = @"Favorite Mime";
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
                else {
                    // Set More row
                    static NSString *CellIdentifier = @"MoreFavorites";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More favorite mimes";
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
                // Set no favorite mimes row
                static NSString *CellIdentifier = @"NoFavoriteMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No favorite mimes!";
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
        // Staff Picks section
        
//        NSInteger count = MIN([self.staffPicksArray count], kMAXROWS);    // Maximize the number of mimes to show to 3
        NSInteger count = 0;
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"GuessedHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_guessedHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Guessed mime
                    static NSString *CellIdentifier = @"GuessedMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
//                        cell.textLabel.text = [self.staffPicksArray objectAtIndex:(indexPath.row - 1)];
                        cell.textLabel.text = @"Guessed Mime";
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
                else {
                    // Set More row
                    static NSString *CellIdentifier = @"MoreGuessedMimes";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More guessed mimes";
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
                // Set no guessed mimes row
                static NSString *CellIdentifier = @"NoGuessedMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No guessed mimes!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
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
        // Sent section
        count = [[self.frc_sentMimes fetchedObjects]count];
        rows = MIN(count, kMAXROWS);
    }
    else if (indexPath.section == 1) {
        // Favorites section
        count = 0;
        rows = MIN(count, kMAXROWS);
    }
    else {
        // Guessed section
        count = 0;
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
        // Sent mime selected
        NSInteger count = MIN([[self.frc_sentMimes fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_sentMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kANSWERMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meScrapbookFullTableViewController *fullTableViewController = [Mime_meScrapbookFullTableViewController createInstance];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
//    else if (indexPath.section == 1) {
//        // Recent mime selected
//        NSInteger count = [self.recentArray count];
//        
//        if (indexPath.row > 0 && indexPath.row <= count) {
//            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstance];
//            
//            [self.navigationController pushViewController:fullTableViewController animated:YES];
//        }
//    }
//    else {
//        // Staff Pick mime selected
//        NSInteger count = [self.staffPicksArray count];
//        
//        if (indexPath.row > 0 && indexPath.row <= count) {
//            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstance];
//            
//            [self.navigationController pushViewController:fullTableViewController animated:YES];
//        }
//    }
    
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meGuessMenuViewController.controller.didChangeObject:";
    if (controller == self.frc_sentMimes) {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
    }
    else {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meGuessMenuViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    NSFetchedResultsController *frc = (NSFetchedResultsController *)[userInfo valueForKey:kSENTMIMESFRC];
    NSNumber* mimeID = [userInfo valueForKey:kMIMEANSWERID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if (frc == self.frc_sentMimes) {
            NSInteger count = MIN([[self.frc_sentMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of friends to show
            for (int i = 0; i < count; i++) {
                Mime *mime = [[self.frc_sentMimes fetchedObjects] objectAtIndex:i];
                if ([mime.objectid isEqualToNumber:mimeID]) {
                    UITableViewCell *cell = [self.tbl_scrapbook cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    //we only draw the image if this view hasnt been repurposed for another photo
                    LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
                    
                    UIImage *image = [image imageScaledToSize:CGSizeMake(50, 50)];
                    
                    [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                    
                    [self.view setNeedsDisplay];
                    
                    break;
                }
            }
        }
    }    
}


#pragma mark - Static Initializers
+ (Mime_meScrapbookMenuViewController*)createInstance {
    Mime_meScrapbookMenuViewController* instance = [[Mime_meScrapbookMenuViewController alloc]initWithNibName:@"Mime_meScrapbookMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
