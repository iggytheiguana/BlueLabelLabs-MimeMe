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
#import "UIPromptAlertView.h"
#import "Attributes.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "Mime_meAppDelegate.h"

#define kMAXUSERNAMELENGTH 15
#define kMAXPASSWORDLENGTH 20

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
    return 5;   // Add 1 to account for header
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    NSString *CellIdentifier;
    
    if (indexPath.row == 0) {
        // Set the header
        CellIdentifier = @"SettingsHeader";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = self.tc_settingHeader;
            
            cell.userInteractionEnabled = NO;
        }
        
        return cell;
    }
    else if (indexPath.row == 1) {
        CellIdentifier = @"GemBalance";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"Gem Balance";
            
            cell.userInteractionEnabled = NO;
            
        }
        
        // TODO: Replace string with user gem balance property
        cell.detailTextLabel.text = [self.loggedInUser.numberofpoints stringValue];
        
        return cell;
        
    }
    else if (indexPath.row == 2) {
        CellIdentifier = @"ChangeUserName";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"Change Username";
            
        }
        
        cell.detailTextLabel.text = self.loggedInUser.username;
        
        return cell;
        
    }
    else if (indexPath.row == 3) {
        CellIdentifier = @"ChangePassword";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = @"Change Password";
            cell.detailTextLabel.text = @"••••••••";
            
        }
        
        return cell;
        
    }
    else {
        CellIdentifier = @"Logout";
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
        if (indexPath.row == 2) {
            // Change username
            UIPromptAlertView* alert = [[UIPromptAlertView alloc]
                                        initWithTitle:@"Change Username"
                                        message:@"\n\nPlease enter your preferred username."
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Change", nil];
            [alert setMaxTextLength:kMAXUSERNAMELENGTH];
            [alert show];
            [alert release];
        }
        else if (indexPath.row == 3) {
            // Change Password
            
        }
        else if (indexPath.row == 4) {
            // Logout
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

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIPromptAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString* enteredText = [alertView enteredText];
        
        // Change the current logged in user's username
        self.loggedInUser.username = enteredText;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        //we start a new undo group here
        [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        
        //after this point, the platforms should automatically begin syncing the data back to the cloud
        //we now show a progress bar to monitor this background activity
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        Mime_meAppDelegate* delegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = delegate.progressView;
        progressView.delegate = self;
        
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        
        NSString* progressIndicatorMessage = [NSString stringWithFormat:@"Checking availability..."];
        
        [self showProgressBar:progressIndicatorMessage withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    }
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meSettingsViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    Request* request = [progressView.requests objectAtIndex:0];
    //now we have the request
    NSArray* changedAttributes = request.changedAttributesList;
    //list of all changed attributes
    //we take the first one and base our messaging off that
    NSString* attributeName = [changedAttributes objectAtIndex:0];
    
    if (progressView.didSucceed) {
        //we need to determine what operation succeeded
        if ([progressView.requests count] > 0) 
        {
            if ([attributeName isEqualToString:USERNAME]) {
                // Username change was successful
                LOG_REQUEST(0, @"%@ Username change successful", activityName);
                
                [self.tbl_settings reloadData];
                
            }
        }
    }
    else {
        NSString* duplicateUsername = self.loggedInUser.username;
        
        //we need to undo the operation that was last performed
        LOG_REQUEST(1, @"%@ Rolling back actions due to request failure", activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        NSString* title = nil;
        NSString* message = nil;
        
        //we need to determine what operation failed
        if ([progressView.requests count] > 0) 
        {
            if ([attributeName isEqualToString:USERNAME]) 
            {
                // Username change failed
                LOG_REQUEST(1, @"%@ Username change successful", activityName);
                
                title = @"Change Username";
                message = [NSString stringWithFormat:@"\n\n\"%@\" is not available. Please try another username.",duplicateUsername];
                
                // Show the Change Username alert view again
                UIPromptAlertView* alert = [[UIPromptAlertView alloc]
                                            initWithTitle:title
                                            message:[NSString stringWithFormat:message]
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Change", nil];
                [alert setMaxTextLength:kMAXUSERNAMELENGTH];
                [alert show];
                [alert release];
            }
        }
    }    
}


#pragma mark - Static Initializers
+ (Mime_meSettingsViewController*)createInstance {
    Mime_meSettingsViewController* instance = [[Mime_meSettingsViewController alloc]initWithNibName:@"Mime_meSettingsViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
