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
#import "Contact.h"
#import "Mime.h"
#import "Contact.h"
#import "JSONKit.h"
#import <AddressBook/AddressBook.h>

@interface Mime_meFriendsPickerViewController ()

@end

@implementation Mime_meFriendsPickerViewController
@synthesize nv_navigationHeader     = m_nv_navigationHeader;
@synthesize btn_go                  = m_btn_go;
@synthesize tbl_friends             = m_tbl_friends;
@synthesize tc_selectedHeader       = m_tc_selectedHeader;
@synthesize tc_addContactsHeader    = m_tc_addContactsHeader;
@synthesize mimeID                  = m_mimeID;
@synthesize facebookFriendsArray    = m_facebookFriendsArray;
@synthesize phoneContactsArray      = m_phoneContactsArray;
@synthesize selectedFriendsArray    = m_selectedFriendsArray;
@synthesize selectedFriendsArrayCopy = m_selectedFriendsArrayCopy;


#pragma mark - Enumerators
- (void)showHUDForFacebookFriendsEnumerator {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Getting Facebook Friends...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateFacebookFriends {
    //this method will call the Facebook delegate to enumerate the user's friends
    
    NSString* activityName = @"Mime_meListTableViewController.enumerateFacebookFriends:";
    Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)([UIApplication sharedApplication].delegate);
    Facebook* facebook = appDelegate.facebook;
    if (facebook.isSessionValid)
    {
        LOG_MIME_FRIENDLISTTABLEVIEWCONTROLLER(0,@"%@ Beginning to enumerate Facebook friends for user",activityName);
        [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
    }
    else {
        //error condition
        LOG_MIME_FRIENDLISTTABLEVIEWCONTROLLER(1,@"%@ Facebook session is not valid, need reauthentication",activityName);
    }
    
    [self showHUDForFacebookFriendsEnumerator];
}

#pragma mark - Helpers
-(NSArray *)partitionContacts:(NSArray *)array collationStringSelector:(SEL)selector {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

- (void)showFacebookFriends {
    if (self.facebookFriendsArray == nil) {
        // We don't yet have the facebook friends, enumerate
        [self enumerateFacebookFriends];
        
    }
    else {
        // Replace the selected friedns array with the copy that has any deselected friends removed
        self.selectedFriendsArray = self.selectedFriendsArrayCopy;
        
        // Launch the friends list with the Facebook friends list loaded
        Mime_meFriendsListTableViewController *friendsListTableViewController = [Mime_meFriendsListTableViewController createInstance];
        friendsListTableViewController.delegate = self;
        //                friendsListTableViewController.contacts = self.facebookFriendsArray;
        friendsListTableViewController.contacts = [self partitionContacts:self.facebookFriendsArray collationStringSelector:@selector(name)];
        
        [self.navigationController pushViewController:friendsListTableViewController animated:YES];
    }
}

- (void)showPhoneContacts {
    if (self.phoneContactsArray == nil) {
        // Build the array of contacts form the address book
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef addressBookData = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        NSMutableArray* contactsList = [NSMutableArray arrayWithCapacity:nPeople];
        
        for (CFIndex i = 0; i < nPeople; i++) {
            ABRecordRef aRecord = CFArrayGetValueAtIndex(addressBookData, i);
            
            // Get contact name
            NSString *firstName = [(NSString *)ABRecordCopyValue(aRecord, kABPersonFirstNameProperty) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (!firstName)
                firstName = @" ";
            
            NSString *lastName = [(NSString *)ABRecordCopyValue(aRecord, kABPersonLastNameProperty) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (!lastName)
                lastName = @" ";
            
            NSString *name = [[NSString stringWithFormat:@"%@ %@", firstName, lastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            // Get contact email
            NSString *email = nil;
            CFStringRef defaultEmail;
            ABMultiValueRef emails = ABRecordCopyValue(aRecord, kABPersonEmailProperty);
            
            if (ABMultiValueGetCount(emails) > 0) {
                defaultEmail = ABMultiValueCopyValueAtIndex(emails, 0);
                email = [(NSString *)defaultEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            
            if (name && email) {
                // If we have a name and email, create the contact and add it to the contact array
                Contact* contact = [Contact createContactWithName:name withEmail:email];
                [contactsList addObject:contact];
                
                NSLog([NSString stringWithFormat:@"%@ %@", name, email]);
            }
        }
        
        CFRelease(addressBookData);
        CFRelease(addressBook);
        
        self.phoneContactsArray = contactsList;
        
    }
    
    // Launch the friends list with the Facebook friends list loaded
    Mime_meFriendsListTableViewController *friendsListTableViewController = [Mime_meFriendsListTableViewController createInstance];
    friendsListTableViewController.delegate = self;
    friendsListTableViewController.contacts = [self partitionContacts:self.phoneContactsArray collationStringSelector:@selector(name)];
    
    [self.navigationController pushViewController:friendsListTableViewController animated:YES];
    
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
    navigationHeader.btn_settings.hidden = YES;
    navigationHeader.btn_mime.hidden = YES;
    navigationHeader.btn_guess.hidden = YES;
    navigationHeader.btn_scrapbook.hidden = YES;
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
    
    // Add the Go button to the navigation header
    [self.nv_navigationHeader addSubview:self.btn_go];
    
    // Initialize the array of selected friends
    self.selectedFriendsArray = [[NSMutableArray alloc] init];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    self.btn_go = nil;
    self.tbl_friends = nil;
    self.tc_selectedHeader = nil;
    self.tc_addContactsHeader = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If we've already selected friends, make sure the list is sorted alphabetically and make a copy
    if (self.selectedFriendsArray != nil) {
        NSSortDescriptor *contactNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:contactNameDescriptor];
        NSMutableArray *sortedSelectedFriendsArray = [NSMutableArray arrayWithArray:[self.selectedFriendsArray sortedArrayUsingDescriptors:sortDescriptors]];
        
        self.selectedFriendsArray = sortedSelectedFriendsArray;
        
        self.selectedFriendsArrayCopy = [self.selectedFriendsArray mutableCopy];
    }
    
    [self.tbl_friends reloadData];
    
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
        // Add friends section
        count = 3;
    }
    else {
        // Friends selected section
        count = [self.selectedFriendsArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. Public option
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // Add friends section
        
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
    else {
        // Friends selected section
        
        if (indexPath.row == 0) {
            // Set the header
            static NSString *CellIdentifier = @"SelectedHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_selectedHeader;
                
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
                
            }
            
            Contact *friend = [self.selectedFriendsArray objectAtIndex:(indexPath.row - 2)];
            
            cell.textLabel.text = friend.name;
            
            // Mark the row as selected if this friend is already in our list selected contacts
            if ([self.selectedFriendsArrayCopy indexOfObject:friend] != NSNotFound) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
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
        // Add friends section
        
        if (indexPath.row == 1) {
            // Launch Facebook Friends
            
            [self showFacebookFriends];
            
        }
        else {
            // Launch Address Book
            
            [self showPhoneContacts];
            
        }
    }
    else {
        // Friends selected section, mark row selected or deselected
        
        NSInteger count = [self.selectedFriendsArray count] + 2;    // Add 2 to account for Header and Public option
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Toggle the checkmark accessory on the cell
        cell.accessoryType = cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
        if (indexPath.row == 1) {
            // Public row
            
        }
        else if (indexPath.row > 1 && indexPath.row <= count) {
            // Friend row
            
            Contact *friend = [self.selectedFriendsArray objectAtIndex:(indexPath.row - 2)];    // Subtract 2 to account for Header and Public option
            
            // Add or remove the friend from the list of selected contacts
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                [self.selectedFriendsArrayCopy addObject:friend];
            }
            else {                
                [self.selectedFriendsArrayCopy removeObject:friend];
            }
        }
    }
    
}

#pragma mark - UIButton Handlers
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
    
}

- (IBAction) onGoButtonPressed:(id)sender {
    // Create MimeAnswer objects for each tableview row selected
    
    // First check if "Public" has been seleced
    UITableViewCell *cell = [self.tbl_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        NSLog(@"Pubic");
        
        // Mark the Mime as public
        ResourceContext* resourceContext = [ResourceContext instance];
        Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
        
        mime.ispublic = [NSNumber numberWithBool:YES];
    }
    
    NSInteger count = [self.tbl_friends numberOfRowsInSection:0];
    
    // Now iterate through each row of friends and create a MimeAnswer for each friend row selected
    for (int i = 2; i < count; i++) {
        UITableViewCell *cell = [self.tbl_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            // Create a MimeAnswer for friend target
            Contact *friend = [self.selectedFriendsArray objectAtIndex:(i - 2)];
                   
            [MimeAnswer createMimeAnswerWithMimeID:self.mimeID withTargetFacebookID:friend.facebookid withTargetEmail:friend.email];
        }
    }
    
    // Save
    [self showHUDForMimeUpload];
    
}

#pragma mark - MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meCreateMimeViewController.hudWasHidden";
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

#pragma mark - Facebook Session Delegate methods
- (void) request:(FBRequest *)request didLoad:(id)result
{
    NSString* activityName = @"Mime_meFriendsPickerViewController.request:didLoad:";
    NSMutableArray* facebookFriendsList = [[NSMutableArray alloc] init];
    //completion of request
    if (result != nil)
    {
        NSArray* friendsList = [(NSDictionary*)result objectForKey:@"data"];
        LOG_MIME_FRIENDPICKERVIEWCONTROLLER(0,@"%@ Enumerated %d Facebook friends for user",activityName,[friendsList count]);
        
        for (int i = 0; i < [friendsList count];i++)
        {
            NSDictionary* friendJSON = [friendsList objectAtIndex:i];
            
            Contact* facebookFriend = [Contact createInstanceFromJSON:friendJSON];
            [facebookFriendsList addObject:facebookFriend];
            
        }
    }
    
//    NSSortDescriptor *contactNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:contactNameDescriptor];
//    NSMutableArray *sortedFacebookFriendsList = [NSMutableArray arrayWithArray:[facebookFriendsList sortedArrayUsingDescriptors:sortDescriptors]];
//    
//    self.facebookFriendsArray = sortedFacebookFriendsList;
    
     self.facebookFriendsArray = facebookFriendsList;
    
//    [sortedFacebookFriendsList release];
//    [facebookFriendsList release];
    
    // Hide the progress bar and move to the frields list view controller
    [self hideProgressBar];
    
    Mime_meFriendsListTableViewController *friendsListTableViewController = [Mime_meFriendsListTableViewController createInstance];
    friendsListTableViewController.delegate = self;
//    friendsListTableViewController.contacts = self.facebookFriendsArray;
    friendsListTableViewController.contacts = [self partitionContacts:self.facebookFriendsArray collationStringSelector:@selector(name)];
    
    [self.navigationController pushViewController:friendsListTableViewController animated:YES];
}

#pragma mark - Static Initializers
+ (Mime_meFriendsPickerViewController*)createInstanceWithMimeID:(NSNumber *)mimeID {
    Mime_meFriendsPickerViewController* instance = [[Mime_meFriendsPickerViewController alloc]initWithNibName:@"Mime_meFriendsPickerViewController" bundle:nil];
    [instance autorelease];
    instance.mimeID = mimeID;
    return instance;
}

@end
