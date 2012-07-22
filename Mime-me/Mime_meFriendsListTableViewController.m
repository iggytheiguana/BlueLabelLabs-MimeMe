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
#import "FacebookFriend.h"
#import "JSONKit.h"

@interface Mime_meFriendsListTableViewController ()

@end

@implementation Mime_meFriendsListTableViewController
@synthesize tbl_friends         = m_tbl_friends;
@synthesize btn_back            = m_btn_back;
@synthesize v_headerContainer   = m_v_headerContainer;
@synthesize facebookFriends     = m_facebookFriends;

#pragma mark - Enumerators
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
    
    [self enumerateFacebookFriends];
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
    NSInteger count = [self.facebookFriends count];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self.facebookFriends count];
    
    NSInteger row = indexPath.row;
    
    if (indexPath.row >= 0 && indexPath.row < count) {
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
        
        FacebookFriend *friend = [self.facebookFriends objectAtIndex:indexPath.row];
        
//        cell.textLabel.text = [NSString stringWithFormat:@"%d", row];
        cell.textLabel.text = [friend.facebookid stringValue];
        
        cell.imageView.backgroundColor = [UIColor lightGrayColor];
        cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(50, 50)];
        
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
//    NSUInteger rows = [[self.frc_mimes fetchedObjects]count];
//    
//    if (indexPath.row == 0) {
//        // Header
//        return 50;
//    }
//    else if (indexPath.row > rows) {
//        // Last row
//        return 50;
//    }
//    else {
//        return 60;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger count = 20;
    
    if (indexPath.row > 0 && indexPath.row <= count) {
        // Mark row selected
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
    }
    
}

#pragma mark - UIButton Handlers
- (IBAction) onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
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
           
        }
    }
    self.facebookFriends = facebookFriendsList;
    [facebookFriendsList release];
    
    [self.tbl_friends reloadData];
}

#pragma mark - Static Initializers
+ (Mime_meFriendsListTableViewController*)createInstance {
    Mime_meFriendsListTableViewController* instance = [[Mime_meFriendsListTableViewController alloc]initWithNibName:@"Mime_meFriendsListTableViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
