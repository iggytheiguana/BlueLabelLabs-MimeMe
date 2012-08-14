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
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "UIImage+UIImageCategory.h"

#define kCONTACTID @"contactid"

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
@synthesize gad_bannerView          = m_gad_bannerView;


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
        LOG_MIME_MEFRIENDLISTTABLEVIEWCONTROLLER(0,@"%@ Beginning to enumerate Facebook friends for user",activityName);
        [facebook requestWithGraphPath:@"me/friends?fields=picture,name,installed" andDelegate:self];
    }
    else {
        //error condition
        LOG_MIME_MEFRIENDLISTTABLEVIEWCONTROLLER(1,@"%@ Facebook session is not valid, need reauthentication",activityName);
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
        friendsListTableViewController.contacts = self.facebookFriendsArray;
        self.selectedFriendsArray = self.selectedFriendsArrayCopy;
        
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
            
            // Get contact image
            NSData  *imgData = (NSData *)ABPersonCopyImageDataWithFormat(aRecord, kABPersonImageFormatThumbnail);
            UIImage *image = [UIImage imageWithData:imgData];
            
            if (name && email) {
                // If we have a name and email, create the contact and add it to the contact array
                Contact* contact = [Contact createContactWithName:name withEmail:email withImage:image];
                [contactsList addObject:contact];
            }
        }
        
        CFRelease(addressBookData);
        CFRelease(addressBook);
        
        self.phoneContactsArray = [self partitionContacts:contactsList collationStringSelector:@selector(name)];
        
    }
    
    // Launch the friends list with the Facebook friends list loaded
    Mime_meFriendsListTableViewController *friendsListTableViewController = [Mime_meFriendsListTableViewController createInstance];
    friendsListTableViewController.delegate = self;
    friendsListTableViewController.contacts = self.phoneContactsArray;
    self.selectedFriendsArray = self.selectedFriendsArrayCopy;
    
    [self.navigationController pushViewController:friendsListTableViewController animated:YES];
    
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
    
    // Add rounded corners to view and tble view
    [self.view.layer setCornerRadius:8.0f];
    [self.tbl_friends.layer setCornerRadius:8.0f];
    
    // Add the navigation header
    Mime_meUINavigationHeaderView *navigationHeader = [[Mime_meUINavigationHeaderView alloc]initWithFrame:[Mime_meUINavigationHeaderView frameForNavigationHeader]];
    navigationHeader.delegate = self;
    navigationHeader.btn_back.hidden = YES;
    navigationHeader.btn_gemCount.hidden = YES;
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
    
    // Initialize Google AdMob Banner view
    [self initializeGADBannerView];
    
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
    self.gad_bannerView = nil;
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
                cell.detailTextLabel.text = @"Share with everyone on Mime-Me!";
                
                // Default to selected
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Friend";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                cell.imageView.layer.masksToBounds = YES;
                cell.imageView.layer.cornerRadius = 8.0;
                cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                cell.imageView.layer.borderWidth = 1.0;
                
                cell.imageView.backgroundColor = [UIColor lightGrayColor];
                cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(40, 40)];
                
            }
            
            Contact *contact = [self.selectedFriendsArray objectAtIndex:(indexPath.row - 2)];
            
            cell.textLabel.text = contact.name;
            
            // Display contact image
            ImageManager* imageManager = [ImageManager instance];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:contact.objectID forKey:kCONTACTID];
            
            if (contact.imageurl != nil && ![contact.imageurl isEqualToString:@""]) {
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                callback.fireOnMainThread = YES;
                UIImage* image = [imageManager downloadImage:contact.imageurl withUserInfo:nil atCallback:callback];
                [callback release];
                if (image != nil) {
                    
                    cell.imageView.image = [image imageScaledToSize:CGSizeMake(40, 40)];
                    
                    [self.view setNeedsDisplay];
                }
                else {
                    cell.imageView.backgroundColor = [UIColor lightGrayColor];
                    cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(40, 40)];
                }
            }
            
            // Mark the row as selected if this friend is already in our list selected contacts
            if ([self.selectedFriendsArrayCopy indexOfObject:contact] != NSNotFound) {
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
            
            // Add or remove the friend from the copied list of selected contacts
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
    
    // Start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
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
    
    // Now create a MimeAnswer object for each contact in the copy of the selected friends array.
    // We use the copy since the user may have deselected a particular contact in the list, and
    // the copy holds the most recent truth.
    
    for (Contact *contact in self.selectedFriendsArrayCopy) {
//        NSLog(contact.name);
        
        // Create a MimeAnswer for friend target
        [MimeAnswer createMimeAnswerWithMimeID:self.mimeID withTargetFacebookID:contact.facebookid withTargetEmail:contact.email withTargetName:contact.name];
    }
    
    // Increment the users gem total for the newly created Mime
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    int gemsForNewMime = [settings.gems_for_new_mime intValue];
    int newGemTotal = [self.loggedInUser.numberofpoints intValue] + gemsForNewMime;
    self.loggedInUser.numberofpoints = [NSNumber numberWithInt:newGemTotal]; 
    
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
        Mime_meViewMimeViewController *shareViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSENTMIME withMimeID:self.mimeID withMimeAnswerIDorNil:nil];
        [self.navigationController pushViewController:shareViewController animated:YES];

        
    }
    else {
        //enumeration failed
        LOG_REQUEST(1, @"%@ Mime and MimeAnswer creation request failure", activityName);
        
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
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
        LOG_MIME_MEFRIENDPICKERVIEWCONTROLLER(0,@"%@ Enumerated %d Facebook friends for user",activityName,[friendsList count]);
        
        for (int i = 0; i < [friendsList count];i++)
        {
            NSDictionary* friendJSON = [friendsList objectAtIndex:i];
            
            Contact* facebookFriend = [Contact createInstanceFromJSON:friendJSON];
            [facebookFriendsList addObject:facebookFriend];
            
        }
    }
    
     self.facebookFriendsArray = [self partitionContacts:facebookFriendsList collationStringSelector:@selector(name)];
    
//    [sortedFacebookFriendsList release];
//    [facebookFriendsList release];
    
    // Hide the progress bar and move to the frields list view controller
    [self hideProgressBar];
    
    Mime_meFriendsListTableViewController *friendsListTableViewController = [Mime_meFriendsListTableViewController createInstance];
    friendsListTableViewController.delegate = self;
    friendsListTableViewController.contacts = self.facebookFriendsArray;
    self.selectedFriendsArray = self.selectedFriendsArrayCopy;
    
    [self.navigationController pushViewController:friendsListTableViewController animated:YES];
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meFriendsPickerViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    NSManagedObjectID *contactID = [userInfo valueForKey:kCONTACTID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        NSArray *array = self.selectedFriendsArray;
    
        NSInteger contactIndex = 0;
        for (Contact *contact in array) {
            
            if ([contact.objectID isEqual:contactID]) {
                UITableViewCell *cell = [self.tbl_friends cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(contactIndex + 1) inSection:1]];
                
                //we only draw the image if this view hasnt been repurposed for another photo
                LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
                
                UIImage *image = [response.image imageScaledToSize:CGSizeMake(40, 40)];
                
                [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                
                [self.view setNeedsDisplay];
                
                break;
            }
            
            contactIndex++;
        }
    }    
}


#pragma mark - Static Initializers
+ (Mime_meFriendsPickerViewController*)createInstanceWithMimeID:(NSNumber *)mimeID {
    Mime_meFriendsPickerViewController* instance = [[Mime_meFriendsPickerViewController alloc]initWithNibName:@"Mime_meFriendsPickerViewController" bundle:nil];
    [instance autorelease];
    instance.mimeID = mimeID;
    return instance;
}

@end
