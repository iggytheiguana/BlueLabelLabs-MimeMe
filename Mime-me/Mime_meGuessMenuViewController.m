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
#import "Mime_meMimeViewController.h"
#import "Mime_meGuessFullTableViewController.h"

@interface Mime_meGuessMenuViewController ()

@end

@implementation Mime_meGuessMenuViewController
@synthesize nv_navigationHeader = m_nv_navigationHeader;

@synthesize tbl_mimes           = m_tbl_mimes;
@synthesize tc_friendsHeader    = m_tc_friendsHeader;
@synthesize tc_recentHeader     = m_tc_recentHeader;
@synthesize tc_staffPicksHeader = m_tc_staffPicksHeader;

@synthesize friendsArray        = m_friendsArray;
@synthesize recentArray         = m_recentArray;
@synthesize staffPicksArray     = m_staffPicksArray;

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
    
    if (section == 0) {
        // From Friends section
        count = [self.friendsArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. More/None
    }
    else if (section == 1) {
        // Recent section
        count = [self.recentArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. More
    }
    else {
        // Staff Picks section
        count = [self.staffPicksArray count] + 2;  // Add 2 to the count to include 1. Header, and 2. More
    }
    
    int rows = MIN(count, 5);   // Maximize the number of rows per section
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // From Friends section
        
        NSInteger count = MIN([self.friendsArray count], 3);    // Maximize the number of friends to show
        
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
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = [self.friendsArray objectAtIndex:(indexPath.row - 1)];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
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
        
        NSInteger count = MIN([self.recentArray count], 3);    // Maximize the number of recent mimes to show to 3
        
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
        
        NSInteger count = MIN([self.staffPicksArray count], 3);    // Maximize the number of staff pick mimes to show to 3
        
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Friends mime selected
        NSInteger count = MIN([self.friendsArray count], 3);    // Maximize the number of friends to show
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
        }
        else {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstance];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    if (indexPath.section == 1) {
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
    Mime_meMimeViewController *mimeViewController = [Mime_meMimeViewController createInstance];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:NO];
}

- (IBAction) onGuessButtonPressed:(id)sender {
    
}

- (IBAction) onScrapbookButtonPressed:(id)sender {
    
}

- (IBAction) onSettingsButtonPressed:(id)sender {
    
}

#pragma mark - Static Initializers
+ (Mime_meGuessMenuViewController*)createInstance {
    Mime_meGuessMenuViewController* instance = [[Mime_meGuessMenuViewController alloc]initWithNibName:@"Mime_meGuessMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
