//
//  Mime_meFriendsListTableViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meFriendsListTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meAppDelegate.h"
#import "Macros.h"
#import "Contact.h"
#import "JSONKit.h"
#import "Mime_meFriendsPickerViewController.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "UIImage+UIImageCategory.h"
#import "UserState.h"

#define kCONTACTID @"contactid"
#define kTABLEVIEW @"tableview"

@interface Mime_meFriendsListTableViewController ()

@end

@implementation Mime_meFriendsListTableViewController
@synthesize tbl_friends             = m_tbl_friends;
@synthesize btn_back                = m_btn_back;
@synthesize v_headerContainer       = m_v_headerContainer;
@synthesize contacts                = m_contacts;
@synthesize filteredContacts        = m_filteredContacts;
@synthesize searchDisplayController = m_searchDisplayController;


#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<Mime_meFriendsListTableViewControllerDelegate>)del
{
    m_delegate = del;
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
    
    // Add rounded corners to top part of header view
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.v_headerContainer.bounds 
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(8.0, 8.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.v_headerContainer.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.v_headerContainer.layer.mask = maskLayer;
    [self.v_headerContainer.layer setOpaque:NO];
    
    // Initializt the array of filtered contacts for the search controller
	self.filteredContacts = [[NSMutableArray alloc] init];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_friends = nil;
    self.btn_back = nil;
    self.v_headerContainer = nil;
    self.searchDisplayController = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
	else
	{
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredContacts count];
    }
	else
	{
        return [[self.contacts objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        count = [self.filteredContacts count];
    }
    else
    {
        count = [[self.contacts objectAtIndex:indexPath.section] count];
    }
    
    if (indexPath.row < count) {
        // Set contact
        static NSString *CellIdentifier = @"Contact";
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
        
        Contact *contact = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            contact = [self.filteredContacts objectAtIndex:indexPath.row];
        }
        else
        {
            contact = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        
        // Mark the row as selected if this friend is already in our list selected contacts
        Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
        if ([friendsPickerViewController.selectedFriendsArray indexOfObject:contact] != NSNotFound) {
            cell.accessoryView = nil;   // remove the state label
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            BOOL match = NO;
            
            // We need to search the selected Friends array and try to,
            // match on facebookid or email since the array might be from user defaults
            Contact *savedContact;
            for (Contact *defaultContact in friendsPickerViewController.selectedFriendsArray) {
                if ([contact.facebookid isEqualToNumber:defaultContact.facebookid] ||
                    [contact.email isEqualToString:defaultContact.email]) {
                    // We have a match
                    match = YES;
                    
                    savedContact = defaultContact;
                    
                    break;
                }
            }
            
            if (match == YES) {
                // Swap the old saved default contact for this new instance
                [friendsPickerViewController.selectedFriendsArray addObject:contact];
                [friendsPickerViewController.selectedFriendsArray removeObject:savedContact];
                
                // Mark this contact selected
                cell.accessoryView = nil;   // remove the state label
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                // Mark user who have MimeMe installed already or who have already been sent invites
                
                // Set up the state label for this contact
                UILabel *lbl_new = [[UILabel alloc] initWithFrame:CGRectMake(260.0f, 0.0f, 50.0f, 36.0f)];
                lbl_new.backgroundColor = [UIColor clearColor];
                lbl_new.numberOfLines = 0;
                lbl_new.font =[UIFont systemFontOfSize:11.0f];
                lbl_new.adjustsFontSizeToFitWidth = YES;
                lbl_new.textColor = [UIColor blueColor];
                lbl_new.textAlignment = UITextAlignmentCenter;
                
                ResourceContext *resourceContext = [ResourceContext instance];
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:FB_USER_ID ascending:YES];
                NSArray *users = [resourceContext resourcesWithType:USER withValueEqual:[contact.facebookid stringValue] forAttribute:FB_USER_ID sortBy:[NSArray arrayWithObject:sortDescriptor]];
                
                if ([users count] > 0) {
                    User *user = (User *)[users objectAtIndex:0];
                    
                    if (user != nil) {
                        if ([user.state intValue] == kMIMEMEUSER) {
                            // Mark user as "Already on Mime-Me"
                            lbl_new.text = @"On\nMime-Me!";
                            lbl_new.textColor = [UIColor greenColor];
                        }
                        else if ([user.state intValue] == kINVITED) {
                            // Mark user as "Invited!"
                            lbl_new.text = @"Invited!";
                            lbl_new.textColor = [UIColor lightGrayColor];
                        }
                        else {
                            // Mark user as ready for invite
                            lbl_new.text = @"Invite to\nMime-Me!";
                            lbl_new.textColor = [UIColor blueColor];
                        }
                    }
                    else {
                        // Mark user as ready for invite
                        lbl_new.text = @"Invite to\nMime-Me!";
                        lbl_new.textColor = [UIColor blueColor];
                    }
                }
                else {
                    // Mark user as ready for invite
                    lbl_new.text = @"Invite to\nMime-Me!";
                    lbl_new.textColor = [UIColor blueColor];
                }
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.accessoryView = lbl_new;
                [lbl_new release];
            }
        }
    
        cell.textLabel.text = contact.name;
    
        // Display contact image
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:contact.objectID, kCONTACTID, tableView, kTABLEVIEW, nil];
        
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
        
        return cell;
    }
    else {
        // Default row
        static NSString *CellIdentifier = @"Default";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"No friends!";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // Search controller tableview will not show sections
        return nil;
    }
    else {
        BOOL showSection = [[self.contacts objectAtIndex:section] count] != 0;
        
        //only show the section title if there are rows in the section
        return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // Search controller tableview will not show sections
        return nil;
    }
    else {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // Search controller tableview will not show sections
        return NAN;
    }
    else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
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
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        count = [self.filteredContacts count];
    }
    else
    {
        count = [[self.contacts objectAtIndex:indexPath.section] count];
    }
    
    if (indexPath.row < count) {
        // Mark row selected
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Toggle the checkmark accessory on the cell
        cell.accessoryView = nil;   // remove the state label
        cell.accessoryType = cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
        Contact *friend = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            friend = [self.filteredContacts objectAtIndex:indexPath.row];
        }
        else
        {
            friend = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        
        // Add or remove the contact from the list of selected contacts
        Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [friendsPickerViewController.selectedFriendsArray addObject:friend];
        }
        else {
            [friendsPickerViewController.selectedFriendsArray removeObject:friend];
            
            // Mark user who have MimeMe installed already or who have already been sent invites
            
            // Set up the state label for this contact
            UILabel *lbl_new = [[UILabel alloc] initWithFrame:CGRectMake(260.0f, 0.0f, 50.0f, 36.0f)];
            lbl_new.backgroundColor = [UIColor clearColor];
            lbl_new.numberOfLines = 0;
            lbl_new.font =[UIFont systemFontOfSize:11.0f];
            lbl_new.adjustsFontSizeToFitWidth = YES;
            lbl_new.textColor = [UIColor blueColor];
            lbl_new.textAlignment = UITextAlignmentCenter;
            
            ResourceContext *resourceContext = [ResourceContext instance];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:FB_USER_ID ascending:YES];
            NSArray *users = [resourceContext resourcesWithType:USER withValueEqual:[friend.facebookid stringValue] forAttribute:FB_USER_ID sortBy:[NSArray arrayWithObject:sortDescriptor]];
            
            if ([users count] > 0) {
                User *user = (User *)[users objectAtIndex:0];
                
                if (user != nil) {
                    if ([user.state intValue] == kMIMEMEUSER) {
                        // Mark user as "Already on Mime-Me"
                        lbl_new.text = @"On\nMime-Me!";
                        lbl_new.textColor = [UIColor greenColor];
                    }
                    else if ([user.state intValue] == kINVITED) {
                        // Mark user as "Invited!"
                        lbl_new.text = @"Invited!";
                        lbl_new.textColor = [UIColor lightGrayColor];
                    }
                    else {
                        // Mark user as ready for invite
                        lbl_new.text = @"Invite to\nMime-Me!";
                        lbl_new.textColor = [UIColor blueColor];
                    }
                }
                else {
                    // Mark user as ready for invite
                    lbl_new.text = @"Invite to\nMime-Me!";
                    lbl_new.textColor = [UIColor blueColor];
                }
            }
            else {
                // Mark user as ready for invite
                lbl_new.text = @"Invite to\nMime-Me!";
                lbl_new.textColor = [UIColor blueColor];
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = lbl_new;
            [lbl_new release];
        }
    }
}

#pragma mark - UIButton Handlers
- (IBAction) onBackButtonPressed:(id)sender {
    Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
    [friendsPickerViewController.tbl_friends reloadData];
    
    // Go back to friends picker
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Search Methods
- (void)filterContentForSearchText:(NSString*)searchText
{
	// Update the filtered array based on the search text.
    
	[self.filteredContacts removeAllObjects]; // First clear the filtered array.
	
	// Search the main list for contacts whose name matches searchText; add items that match to the filtered array.
	for (NSArray *section in self.contacts) {
        for (Contact *contact in section) {
            if ([contact.name rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound) {
                // Match found
                [self.filteredContacts addObject:contact];
            }
        }
    }
}

#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark UISearchBar Delegate Methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tbl_friends reloadData];
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meFriendsListTableViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    NSManagedObjectID *contactID = [userInfo valueForKey:kCONTACTID];
    UITableView *tableView = [userInfo valueForKey:kTABLEVIEW];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            // We need to find the right image view for the contact from the filtered list of contacts
            NSInteger contactIndex = 0;
            for (Contact *contact in self.filteredContacts) {
                
                if ([contact.objectID isEqual:contactID]) {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:contactIndex inSection:0]];
                    
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
        else
        {
            // We need to find the right image view for the contact from the full list of contacts
            NSInteger sectionIndex = 0;
            for (NSArray *section in self.contacts) {
                
                NSInteger contactIndex = 0;
                for (Contact *contact in section) {
                    
                    if ([contact.objectID isEqual:contactID]) {
                        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:contactIndex inSection:sectionIndex]];
                        
                        //we only draw the image if this view hasnt been repurposed for another photo
                        LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
                        
                        UIImage *image = [response.image imageScaledToSize:CGSizeMake(40, 40)];
                        
                        [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                        
                        [self.view setNeedsDisplay];
                        
                        break;
                    }
                    
                    contactIndex++;
                }
                
                sectionIndex++;
            }
        }
    }
}

#pragma mark - Static Initializers
+ (Mime_meFriendsListTableViewController*)createInstance {
    Mime_meFriendsListTableViewController* instance = [[Mime_meFriendsListTableViewController alloc]initWithNibName:@"Mime_meFriendsListTableViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
