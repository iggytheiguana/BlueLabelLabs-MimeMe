//
//  Mime_meSettingsViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meSettingsViewController.h"
#import "LoginViewController.h"
#import "Macros.h"
#import "Mime_meMenuViewController.h"

@interface Mime_meSettingsViewController ()

@end

@implementation Mime_meSettingsViewController
@synthesize tbl_settings        = m_tbl_settings;
@synthesize tc_settingHeader    = m_tc_settingHeader;
@synthesize btn_close           = m_btn_close;


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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_settings = nil;
    self.tc_settingHeader = nil;
    self.btn_close = nil;
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
    // Return the number of rows in the section.
    return 2;   // Add 1 to account for header
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    if (indexPath.row == 0) {
        // Set the header
        static NSString *CellIdentifier = @"SettingsHeader";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = self.tc_settingHeader;
            
            cell.userInteractionEnabled = NO;
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Logout";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"Logout";
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Scedule reminder section
        
        if (indexPath.row == 1) {
            //Logout
            if ([self.authenticationManager isUserAuthenticated]) {
                [self.authenticationManager logoff];
            }
            
            // User is not logged in, we will need to launch the login screen again
            Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginSuccess:) withContext:nil];        
            Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
            
            LoginViewController* loginViewController = [LoginViewController createAuthenticationInstance:NO shouldGetTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];
            
            [UIView animateWithDuration:0.75
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                             }];
            
//            [self.navigationController setViewControllers:[NSArray arrayWithObject:loginViewController] animated:NO];
            [self.navigationController pushViewController:loginViewController animated:NO];
        }
    }
}

#pragma mark - UIButton Handlers
- (IBAction) onCloseButtonPressed:(id)sender {
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                     }];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Login Callback Handlers
- (void) onLoginFailed:(CallbackResult *)result {
    NSString* activityName = @"PlatformAppDelegate.onLoginFailed:";
    
    //need to display an error message to the user
    //TODO: create generic error emssage display
    LOG_SECURITY(1, @"%@Authentication failed",activityName);
}

- (void) onLoginSuccess:(CallbackResult *)result {
    NSString* activityName = @"PlatformAppDelegate.onLoginSuccess:";
    
    LOG_SECURITY(1, @"%@Authentication successful",activityName);
    
    // Successful user login, launch menu
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                     }];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
    
}

#pragma mark - Static Initializers
+ (Mime_meSettingsViewController*)createInstance {
    Mime_meSettingsViewController* instance = [[Mime_meSettingsViewController alloc]initWithNibName:@"Mime_meSettingsViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
