//
//  Mime_meFriendsPickerViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meFriendsPickerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "MimeAnswer.h"
#import "Mime_meViewMimeViewController.h"
#import "ViewMimeCase.h"
#import "Macros.h"
#import "Mime_meAppDelegate.h"
#import "FacebookFriend.h"
#import "JSONKit.h"
@interface Mime_meFriendsPickerViewController ()

@end

@implementation Mime_meFriendsPickerViewController
@synthesize nv_navigationHeader     = m_nv_navigationHeader;
@synthesize btn_go                  = m_btn_go;
@synthesize tbl_friends             = m_tbl_friends;
@synthesize tc_friendsHeader        = m_tc_friendsHeader;
@synthesize tc_addContactsHeader    = m_tc_addContactsHeader;
@synthesize mimeID                  = m_mimeID;
@synthesize friendsArray            = m_friendsArray;
@synthesize facebookFriends         = m_facebookFriends;

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
    navigationHeader.btn_settings.hidden = YES;
    navigationHeader.btn_mime.hidden = YES;
    navigationHeader.btn_guess.hidden = YES;
    navigationHeader.btn_scrapbook.hidden = YES;
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
    
    // Add the Go button to the navigation header
    [self.nv_navigationHeader addSubview:self.btn_go];
    
    // TEMP: Data arrays for tableview
    self.friendsArray = [NSArray arrayWithObjects:@"Laura", @"Julie", @"Matt", @"David", nil];
    
   
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self enumerateFacebookFriends];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    self.btn_go = nil;
    self.tbl_friends = nil;
    self.tc_friendsHeader = nil;
    self.tc_addContactsHeader = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    
    if (section == 0) {
        count = [self.friendsArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. Public option
    }
    else {
        count = 3;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
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
        else if (indexPath.row == 1) {
            static NSString *CellIdentifier = @"Public";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                
                // Cell title
                cell.textLabel.text = @"Public";
                
                // Cell subtitle
                cell.detailTextLabel.text = @"Share with everyone on MimeMe!";
                
                // Default to selected
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Friends";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = [self.friendsArray objectAtIndex:(indexPath.row - 2)];
                
            }
            
            return cell;
        }
    }
    else {
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"AddContactsHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_addContactsHeader;
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else if (indexPath.row == 1) {
            static NSString *CellIdentifier = @"AddContactsFacebook";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = @"Facebook";
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"AddContactsPhone";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = @"Phone Contacts";
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            }
            
            return cell;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSInteger count = [self.friendsArray count] + 1;    // Add 1 to account for Public option
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            // Mark row selected
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.accessoryType = cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
            
        }
    }
    else {
        if (indexPath.row == 1) {
            // Launch Facebook Friends
            
        }
        else {
            // Launch Address Book
            
        }
    }
    
}

#pragma mark - UIButton Handlers
//- (void)sendMimeWithProgressView:(UIProgressHUDView *)progressView {
//    ResourceContext *resourceContext = [ResourceContext instance];
//    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
//}

- (void)showHUDForMimeUpload {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
//    // Indeterminate Progress bar
//    NSString* message = @"Getting more words...";
//    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];

    // Determinate Progress bar
    NSNumber* maxTimeToShowOnProgress = settings.http_timeout_seconds;
    NSNumber* heartbeat = [NSNumber numberWithInt:5];
    
    //we need to construc the appropriate success, failure and progress messages for the submission
    NSString* failureMessage = @"Oops, please try again.";
    NSString* successMessage = @"Success!";
    
    NSMutableArray* progressMessage = [[[NSMutableArray alloc]init]autorelease];
    [progressMessage addObject:@"Sending mime..."];
    
    [self showDeterminateProgressBarWithMaximumDisplayTime:maxTimeToShowOnProgress withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
    
    // Save
    ResourceContext *resourceContext = [ResourceContext instance];
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    
//    [self performSelector:@selector(sendMimeWithProgressView:) withObject:progressView afterDelay:0.5];
    
//    ResourceContext *resourceContext = [ResourceContext instance];
//    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    
}

- (IBAction) onGoButtonPressed:(id)sender {
    // Create MimeAnswer objects for each tableview row selected
    
//    ResourceContext *resourceContext = [ResourceContext instance];
    
    // First check if "Public" has been seleced
    UITableViewCell *cell = [self.tbl_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        // Create a public MimeAnswer
        NSLog(@"Pubic");
        
        // Create a Public MimeAnswer object
        [MimeAnswer createMimeAnswerWithMimeID:self.mimeID withTargetUserID:nil isPublic:YES];
    }
    
    NSInteger count = [self.tbl_friends numberOfRowsInSection:0];
    
    // Now itterate through each row of friends and crate a MimeAnswer for each friend row selected
    for (int i = 2; i < count; i++) {
        UITableViewCell *cell = [self.tbl_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            // Create a MimeAnswer for friend target
            NSLog([self.friendsArray objectAtIndex:(i - 2)]);
            
            [MimeAnswer createMimeAnswerWithMimeID:self.mimeID withTargetUserID:nil isPublic:NO];
        }
    }
    
    // Save
    [self showHUDForMimeUpload];
    
//    // Save
//    [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
//    
//    // Now show the confirmation share screen
//    Mime_meViewMimeViewController *shareViewController = [Mime_meViewMimeViewController createInstanceForCase:kSENTMIME withMimeID:self.mimeID withMimeAnswerIDorNil:nil];
//    [self.navigationController pushViewController:shareViewController animated:YES];
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meCreateMimeViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        //enumeration was sucessful
        LOG_REQUEST(0, @"%@ Mime and MimeAnswer creation request was successful", activityName);
        
        // Now show the confirmation share screen
        Mime_meViewMimeViewController *shareViewController = [Mime_meViewMimeViewController createInstanceForCase:kSENTMIME withMimeID:self.mimeID withMimeAnswerIDorNil:nil];
        [self.navigationController pushViewController:shareViewController animated:YES];

        
    }
    else {
        //enumeration failed
        LOG_REQUEST(1, @"%@ Mime and MimeAnswer creation request failure", activityName);
        
    }
}

//this method will call the Facebook delegate to enumerate the user's friends
- (void) enumerateFacebookFriends
{
    NSString* activityName = @"Mime_meFriendsPickerViewController.enumerateFacebookFriends:";
    Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)([UIApplication sharedApplication].delegate);
    Facebook* facebook = appDelegate.facebook;
    if (facebook.isSessionValid)
    {
        LOG_MIME_FRIENDPICKERVIEWCONTROLLER(0,@"%@ Beginning to enumerate Facebook friends for user",activityName);
        [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
    }
    else {
        //error condition
        LOG_MIME_FRIENDPICKERVIEWCONTROLLER(1,@"%@ Facebook session is not valid, need reauthentication",activityName);
    }
    
}

#pragma mark - Facebook Session Delegate methods
- (void) request:(FBRequest *)request didLoad:(id)result
{
    NSString* activityName = @"Mime_meFriendsPickerViewController.request:didLoad:";
    NSMutableArray* facebookFriendsList = [[NSMutableArray alloc]init];
    //completion of request
    if (result != nil)
    {
        NSArray* friendsList = [(NSDictionary*)result objectForKey:@"data"];
        LOG_MIME_FRIENDPICKERVIEWCONTROLLER(0,@"%@ Enumerated %d Facebook friends for user",activityName,[friendsList count]);
        
        for (int i = 0; i < [friendsList count];i++)
        {
            NSDictionary* friendJSON = [friendsList objectAtIndex:i];
          
            FacebookFriend* facebookFriend = [FacebookFriend createInstanceFromJSON:friendJSON];
            [facebookFriendsList addObject:facebookFriend];
            [facebookFriend release];
        }
    }
    self.facebookFriends = facebookFriendsList;
    [facebookFriendsList release];
}


#pragma mark - Static Initializers
+ (Mime_meFriendsPickerViewController*)createInstanceWithMimeID:(NSNumber *)mimeID {
    Mime_meFriendsPickerViewController* instance = [[Mime_meFriendsPickerViewController alloc]initWithNibName:@"Mime_meFriendsPickerViewController" bundle:nil];
    [instance autorelease];
    instance.mimeID = mimeID;
    return instance;
}

@end
