//
//  Mime_meFriendsPickerViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meFriendsPickerViewController.h"
#import "Mime_meMenuViewController.h"

@interface Mime_meFriendsPickerViewController ()

@end

@implementation Mime_meFriendsPickerViewController
@synthesize nv_navigationHeader     = m_nv_navigationHeader;
@synthesize btn_go                  = m_btn_go;
@synthesize tbl_friends             = m_tbl_friends;
@synthesize tc_friendsHeader        = m_tc_friendsHeader;
@synthesize tc_addContactsHeader    = m_tc_addContactsHeader;
@synthesize friendsArray            = m_friendsArray;

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
- (IBAction) onHomeButtonPressed:(id)sender {
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
}

- (IBAction) onGoButtonPressed:(id)sender {
    
}


#pragma mark - Static Initializers
+ (Mime_meFriendsPickerViewController*)createInstance {
    Mime_meFriendsPickerViewController* instance = [[Mime_meFriendsPickerViewController alloc]initWithNibName:@"Mime_meFriendsPickerViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
