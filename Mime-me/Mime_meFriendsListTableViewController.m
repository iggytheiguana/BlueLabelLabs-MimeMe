//
//  Mime_meFriendsListTableViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meFriendsListTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+UIImageCategory.h"
#import "Mime_meAppDelegate.h"
#import "Macros.h"
#import "Contact.h"
#import "JSONKit.h"
#import "Mime_meFriendsPickerViewController.h"

@interface Mime_meFriendsListTableViewController ()

@end

@implementation Mime_meFriendsListTableViewController
@synthesize tbl_friends         = m_tbl_friends;
@synthesize btn_back            = m_btn_back;
@synthesize v_headerContainer   = m_v_headerContainer;
@synthesize contacts            = m_contacts;
@synthesize allContacts         = m_allContacts;
@synthesize contactSearch       = m_contactSearch;
@synthesize letters             = m_letters;
@synthesize lettersDeepCopy     = m_lettersDeepCopy;


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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_friends = nil;
    self.btn_back = nil;
    self.v_headerContainer = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
//    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.contacts objectAtIndex:section] count];
    
//    NSInteger count = [self.contacts count];
//    
//    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self.contacts count];
    
    if (indexPath.row < count) {
        // Set friend
        static NSString *CellIdentifier = @"Friend";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 8.0;
            cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            cell.imageView.layer.borderWidth = 1.0;
            
        }
        
//        Contact *friend = [self.contacts objectAtIndex:indexPath.row];
        Contact *friend = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        // Mark the row as selected if this friend is already in our list selected contacts
        Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
        if ([friendsPickerViewController.selectedFriendsArray indexOfObject:friend] != NSNotFound) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = friend.name;
        
        cell.imageView.backgroundColor = [UIColor lightGrayColor];
        cell.imageView.image = [UIImage imageNamed:@"logo-MimeMe.png"];
//        cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(40, 40)];
        
//        ImageManager* imageManager = [ImageManager instance];
//        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:mime.objectid forKey:kMIMEID];
//        
//        if (mime.thumbnailurl != nil && ![mime.thumbnailurl isEqualToString:@""]) {
//            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
//            callback.fireOnMainThread = YES;
//            UIImage* image = [imageManager downloadImage:mime.thumbnailurl withUserInfo:nil atCallback:callback];
//            [callback release];
//            if (image != nil) {
//                
//                cell.imageView.image = [image imageScaledToSize:CGSizeMake(50, 50)];
//                
//                [self.view setNeedsDisplay];
//            }
//            else {
//                cell.imageView.backgroundColor = [UIColor lightGrayColor];
//                cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(50, 50)];
//            }
//        }
        
        return cell;
    }
    else {
        // Set Invite Friends rows
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
    BOOL showSection = [[self.contacts objectAtIndex:section] count] != 0;
    
    //only show the section title if there are rows in the section
    return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
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
    
    NSInteger count = [self.contacts count];
    
    if (indexPath.row < count) {
        // Mark row selected
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Toggle the checkmark accessory on the cell
        cell.accessoryType = cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
        Contact *friend = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        // Add or remove the contact from the list of selected contacts
        Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [friendsPickerViewController.selectedFriendsArray addObject:friend];
        }
        else {
            [friendsPickerViewController.selectedFriendsArray removeObject:friend];
        }
        
//        // Add or remove the contact from the list of selected contacts
//        Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
//        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//            [friendsPickerViewController.selectedFriendsArray addObject:[self.contacts objectAtIndex:indexPath.row]];
//        }
//        else {
//            [friendsPickerViewController.selectedFriendsArray removeObject:[self.contacts objectAtIndex:indexPath.row]];
//        }
    }
    
}

#pragma mark - UIButton Handlers
- (IBAction) onBackButtonPressed:(id)sender {
    Mime_meFriendsPickerViewController *friendsPickerViewController = (Mime_meFriendsPickerViewController *)self.delegate;
    [friendsPickerViewController.tbl_friends reloadData];
    
    // Go back to friends picker
    [self.navigationController popViewControllerAnimated:YES];
    
}

//#pragma mark - Custom Search Methods
//- (void)resetSearch {
//    UILocalizedIndexedCollation
//    NSMutableDictionary* allPagesCopy = [self.allPages mutableDeepCopy];
//    self.pagesSearch = allPagesCopy;
//    
//    NSMutableArray* monthKeyArray = [[NSMutableArray alloc] init];
//    [monthKeyArray addObjectsFromArray:self.monthsDeepCopy];
//    self.months = monthKeyArray;
//    [monthKeyArray release];
//}
//
//- (void)handleSearchForTerm:(NSString *)searchTerm {
//    NSMutableArray* sectionsToRemove = [[NSMutableArray alloc] init];
//    [self resetSearch];
//    
//    NSString* pageTitle = nil;
//    
//    for (NSString* key in self.months) {
//        NSMutableArray* array = [self.pagesSearch valueForKey:key];
//        NSMutableArray* toRemove = [[NSMutableArray alloc] init];
//        
//        for (Page* page in array) {
//            pageTitle = page.displayname;
//            if ([pageTitle rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound)
//                [toRemove addObject:page];
//        }
//        
//        if ([array count] == [toRemove count])
//            [sectionsToRemove addObject:key];
//        
//        [array removeObjectsInArray:toRemove];
//        [toRemove release];
//    }
//    
//    
//    [self.months removeObjectsInArray:sectionsToRemove];
//    [sectionsToRemove release];
//    [self.tbl_tOCTableView reloadData];
//}
//
//#pragma mark - Search Bar Delegate Methods
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSString *searchTerm = [searchBar text];
//    
//    [self.sb_searchBar setShowsCancelButton:NO animated:YES];
//    [self.btn_backgroundButton setEnabled:NO];
//    [self.sb_searchBar resignFirstResponder];
//    //self.tbl_tOCTableView.allowsSelection = YES;
//    //self.tbl_tOCTableView.scrollEnabled = YES;
//    [self handleSearchForTerm:searchTerm];
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
//    if ([searchTerm length] == 0) {
//        [self resetSearch];
//        [self.tbl_tOCTableView reloadData];
//        return;
//    }
//    [self handleSearchForTerm:searchTerm];
//}
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [self.sb_searchBar setShowsCancelButton:YES animated:YES];
//    [self.btn_backgroundButton setEnabled:YES];
//    //self.tbl_tOCTableView.allowsSelection = NO;
//    //self.tbl_tOCTableView.scrollEnabled = NO;
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self.sb_searchBar setShowsCancelButton:NO animated:YES];
//    [self.btn_backgroundButton setEnabled:NO];
//    self.sb_searchBar.text = @"";
//    [self resetSearch];
//    [self.tbl_tOCTableView reloadData];
//    [self.sb_searchBar resignFirstResponder];
//    //self.tbl_tOCTableView.allowsSelection = YES;
//    //self.tbl_tOCTableView.scrollEnabled = YES;
//}

#pragma mark - Static Initializers
+ (Mime_meFriendsListTableViewController*)createInstance {
    Mime_meFriendsListTableViewController* instance = [[Mime_meFriendsListTableViewController alloc]initWithNibName:@"Mime_meFriendsListTableViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
