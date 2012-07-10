//
//  LoginViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "Callback.h"
#import "Mime_meAppDelegate.h"
#import "EventManager.h"
#import "Macros.h"
#import "ImageManager.h"
#import "User.h"
#import "GetAuthenticatorResponse.h"
#import "Response.h"
#import "NSStringGUIDCategory.h"
#import "SignUpViewController.h"
#import "Mime_meMenuViewController.h"

#define kMaximumBusyWaitTimeFacebookLogin       30
#define kMaximumBusyWaitTimePutAuthenticator    30
#define kMaximumBusyWaitTimeEmailLogin          30

@implementation LoginViewController
@synthesize sv_scrollView       = m_sv_scrollView;
@synthesize btn_login           = m_btn_login;
@synthesize btn_newUser         = m_btn_newUser;
@synthesize btn_loginTwitter    = m_btn_loginTwitter;
@synthesize btn_loginFacebook   = m_btn_loginFacebook;
@synthesize tf_email            = m_tf_email;
@synthesize tf_password         = m_tf_password;
@synthesize lbl_error           = m_lbl_error;
@synthesize btn_forgotPW        = m_btn_forgotPW;
@synthesize fbPictureRequest    = m_fbPictureRequest;
@synthesize fbProfileRequest    = m_fbProfileRequest;
@synthesize shouldGetTwitter    = m_shouldGetTwitter;
@synthesize shouldGetFacebook   = m_shouldGetFacebook;
@synthesize onFailureCallback   = m_onFailCallback;
@synthesize onSuccessCallback   = m_onSuccessCallback;
@synthesize tf_active           = m_tf_active;
@synthesize twitterEngine       = __twitterEngine;

#pragma mark - Properties
- (SA_OAuthTwitterEngine*) twitterEngine {
    if (__twitterEngine != nil) {
        return __twitterEngine;
    }
    ApplicationSettings* settingsObjects = [[ApplicationSettingsManager instance] settings];
    
        NSString* consumerKey = settingsObjects.twitter_consumerkey;
        NSString* consumerSecret = settingsObjects.twitter_consumersecret;
    
    if (consumerKey != nil && 
        consumerSecret != nil)
    {
        __twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
        __twitterEngine.consumerKey = consumerKey;
        __twitterEngine.consumerSecret = consumerSecret;
    }

    return __twitterEngine;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void) dismissWithResult:(BOOL)result 
{
    //[self.parentViewController dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    if (result) 
    {
        //authentication action completed successfully
        if (self.onSuccessCallback != nil) {
            //fire success callback
            Response* response = [[Response alloc]init];
            response.didSucceed = [NSNumber numberWithBool:YES];
            self.onSuccessCallback.fireOnMainThread = YES;
            [self.onSuccessCallback fireWithResponse:response];
            [response release];
        }
    }
    else {
        //authentication action failed
        if (self.onFailureCallback != nil) {
            //fire fail callback
            Response* response = [[Response alloc]init];
            response.didSucceed = [NSNumber numberWithBool:NO];
            self.onFailureCallback.fireOnMainThread = YES;
            [self.onFailureCallback fireWithResponse:response];
            [response release];
        }
        
    }
}


- (void) checkStatusAndDismiss {
    //called when authentication is complete
    
    BOOL result = YES;
    
    AuthenticationContext* userContext = [[AuthenticationManager instance]contextForLoggedInUser];
    if (userContext != nil)
    {
        if (self.shouldGetFacebook && ![userContext hasFacebook]) 
        {
            //we still need to get facebook credentials
            [self performSelectorOnMainThread:@selector(beginFacebookAuthentication) withObject:nil waitUntilDone:NO];
        }
        
        if (self.shouldGetTwitter && ![userContext hasTwitter]) {
            //twitter authentication failed or hasnt happened, we begin twitter auth
            [self performSelectorOnMainThread:@selector(beginTwitterAuthentication) withObject:nil waitUntilDone:NO];
        }
        else 
        {
            [self dismissWithResult:result];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add rounded corners to view
    [self.view.layer setCornerRadius:8.0f];
    
    // Add rounded corners to custom buttons
    self.btn_loginFacebook.layer.cornerRadius = 8;
    self.btn_loginTwitter.layer.cornerRadius = 8;
    self.btn_login.layer.cornerRadius = 8;
    self.btn_newUser.layer.cornerRadius = 8;
    
    // Add border to custom buttons
    [self.btn_loginFacebook.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.btn_loginFacebook.layer setBorderWidth: 1.0];
    [self.btn_loginTwitter.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.btn_loginTwitter.layer setBorderWidth: 1.0];
    [self.btn_login.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.btn_login.layer setBorderWidth: 1.0];
    [self.btn_newUser.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.btn_newUser.layer setBorderWidth: 1.0];
    
    // Add mask on custom buttons
    [self.btn_loginFacebook.layer setMasksToBounds:YES];
    [self.btn_loginTwitter.layer setMasksToBounds:YES];
    [self.btn_login.layer setMasksToBounds:YES];
    [self.btn_newUser.layer setMasksToBounds:YES];
    
    // Set text shadow of custom buttons
    [self.btn_loginFacebook.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    [self.btn_loginTwitter.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    [self.btn_login.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [self.btn_newUser.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    // Set highlight state background color of custom buttons
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *lightGreyImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.btn_login setBackgroundImage:lightGreyImg forState:UIControlStateHighlighted];
    [self.btn_newUser setBackgroundImage:lightGreyImg forState:UIControlStateHighlighted];
    [self.btn_login setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [self.btn_newUser setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    // Register for keyboard notifications to slide view up when typing
    [self registerForKeyboardNotifications];
    
    // Enable the gesture recognizer on the view to handle a single tap to hide the keyboard
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick:)] autorelease];
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    [oneFingerTap setCancelsTouchesInView:NO];
    // Add the gesture to the view
    [self.sv_scrollView addGestureRecognizer:oneFingerTap];
    
    // Hide Login Error label
    self.lbl_error.hidden = YES;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.sv_scrollView = nil;
    self.btn_login = nil;
    self.btn_loginFacebook = nil;
    self.btn_loginTwitter = nil;
    self.btn_newUser = nil;
    self.tf_email = nil;
    self.tf_password = nil;
    self.lbl_error = nil;
    self.tf_active = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //we could be returning from the dismissing of modal view controller (create user)
    //we check if the user is authenticated, if so we begin out shut down procedure
    [self checkStatusAndDismiss];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (IBAction) hideKeyboard:(id)sender
{
    [self.tf_active resignFirstResponder];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) beginTwitterAuthentication {
    //we check to see if the user has supplied their Twitter accessToken, if not, then we move to the next page
    //and display a twitter authn screen
    NSString* activityName = @"UILoginView.beginTwitterAuthentication:";
   
    
        NSString* message = [NSString stringWithFormat:@"Beginning twitter authentication"];
        LOG_LOGINVIEWCONTROLLER(0,@"%@%@",activityName,message);
        
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: self.twitterEngine delegate: self];
        
        if (controller) 
            //display twitter view controller for authentication
            [self presentModalViewController: controller animated: YES];
        else {
            //user is already authenticated with Twitter
            [self.twitterEngine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
            LOG_LOGINVIEWCONTROLLER(0, @"%@ user already logged into twitter, skipping authentication",activityName);
            [self dismissWithResult:YES];
        }
}

-(void) beginFacebookAuthentication {
    //  NSString* activityName = @"UILoginView.beginFacebookAuthentication:";
    //now we need to grab their facebook authentication data, and then log them into our app    
    NSArray *permissions = [NSArray arrayWithObjects:@"offline_access",@"email", @"publish_actions",@"publish_stream",@"user_about_me", nil];
    Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    
    [facebook authorize:permissions delegate:self];
    
}

#pragma mark - FBRequestDelegate
- (void) request:(FBRequest *)request didLoad:(id)result {
    NSString* activityName = @"LoginViewController.request:didLoad:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    ResourceContext* resourceContext = [ResourceContext instance];
    
    if (request == self.fbProfileRequest) {
        LOG_LOGINVIEWCONTROLLER(0, @"%@%@",activityName,@"Facebook profile downloaded for logged in user");
        NSString* facebookIDString = [result valueForKey:ID];
        NSNumber* facebookID = [facebookIDString numberValue];
        NSString* displayName = [result valueForKey:NAME];
        NSString* email = [result valueForKey:EMAIL];
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onGetAuthenticationContextDownloaded:)];
        
        //we need to determine whether we are signing in or adding faceboko credentials to a login
        AuthenticationContext* authenticationContext = [authenticationManager contextForLoggedInUser];
        if (authenticationContext == nil) 
        {
            
            LOG_LOGINVIEWCONTROLLER(0, @"%@:Requesting new authenticator from service withName:%@, withEmail:%@, withFacebookAccessToken:%@",activityName,displayName,email,facebook.accessToken);
            [resourceContext getAuthenticatorToken:facebookID withName:displayName withEmail:email withFacebookAccessToken:facebook.accessToken withFacebookTokenExpiry:facebook.expirationDate withDeviceToken:appDelegate.deviceToken onFinishNotify:callback];
            [callback release];
        }
        else
        {
            //user is signed in, adding facebook to their credentials
            LOG_LOGINVIEWCONTROLLER(0, @"%@:Adding facebook token to logged in user account withName:%@, withEmail:%@, withFacebookAccessToken:%@",activityName,displayName,email,facebook.accessToken);
            [resourceContext updateAuthenticatorWithFacebook:facebookIDString withAccessToken:facebook.accessToken
                                              withExpiryDate:facebook.expirationDate onFinishNotify:callback];
            [callback release];
        }
        
    }
    else if (request == self.fbPictureRequest) {
        User* userObject = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
        
        AuthenticationContext* currentContext = [authenticationManager contextForLoggedInUser];
        
        if (userObject != nil && currentContext != nil) {
            UIImage* image = [UIImage imageWithData:result];
            LOG_LOGINVIEWCONTROLLER(0,@"%@Download of Facebook profile complete, saving photo to phone",activityName);
            //we need to save this image to the local file system
            ImageManager* imageManager = [ImageManager instance];
            NSString* path = [imageManager saveImage:image withFileName:currentContext.facebookuserid];
            
            //save the path on the user object and commit            
//            userObject.thumbnailurl = path;
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
        }
    }
}

- (void) request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSString* activityName = @"UILoginView.fbRequestDidFailWithError:";
    LOG_SECURITY(0, @"%@ facebook request failed with error:%@",activityName,[error localizedDescription]);
}


#pragma mark - FBSessionDelegate
- (void) fbDidLogin {
    NSString* activityName = @"UILoginView.fbDidLogin:";
    Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    Facebook* facebook = appDelegate.facebook;
    
    //this method is called upon the completion of the authorize operation
    NSString* message = [NSString stringWithFormat:@"Facebook login successful, accessToken:%@, expiryDate:%@",facebook.accessToken,facebook.expirationDate];    
    LOG_LOGINVIEWCONTROLLER(0,@"%@%@",activityName,message);
    
    //show the progress bar
    [self showProgressBar:@"Logging in..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimeFacebookLogin]];
    
    //the user has authorized our app, now we get his user object to complete authentication
    self.fbProfileRequest = [facebook requestWithGraphPath:@"me" andDelegate:self];
    
    
    LOG_LOGINVIEWCONTROLLER(0,@"%@%@",activityName,@"requesting user profile details from Facebook");
    
    
}

- (void) fbDidNotLogin:(BOOL)cancelled {
    //authenticate with facebook failed
    NSString* activityName = @"UILoginView.fbDidNotLogin:";
    LOG_SECURITY(0, @"%@user did not complete facebook authentication page",activityName);
    
    
}


- (void) saveAuthenticatorResponse:(GetAuthenticatorResponse*)response {
    NSString* activityName = @"UILoginView.saveAuthenticatorResponse:";
    ResourceContext* resourceContext = [ResourceContext instance];
    if ([response.didSucceed boolValue] == YES) {
        AuthenticationManager* authenticationManager = [AuthenticationManager instance];
        
        AuthenticationContext* newContext = response.authenticationcontext;
        User* returnedUser = response.user;
        
        Resource* existingUser = [resourceContext resourceWithType:USER withID:returnedUser.objectid];
        
        //save the user object that is returned to us in the database
        if (existingUser != nil) {
            [existingUser refreshWith:returnedUser];
        }
        else {
            //need to insert the new user into the resource context
            [resourceContext insert:returnedUser];
        }
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
        
        BOOL contextSavedToKeyChain = [authenticationManager saveAuthenticationContextToKeychainForUser:newContext.userid withAuthenticationContext:newContext];
        
        
        
        if (contextSavedToKeyChain) {
            [authenticationManager loginUser:newContext.userid withAuthenticationContext:newContext isSavedLogin:NO];
            [self checkStatusAndDismiss];
       
        }
        else {
            //unable to login user due to inability to save the credential to key chain
            //raise global error
            LOG_LOGINVIEWCONTROLLER(1,@"%@Unable to save user credential to key chain, login failure",activityName);
            self.lbl_error.hidden = NO;
        }
    }
    else {
        LOG_LOGINVIEWCONTROLLER(1,@"%@Login with Bahndr servers failed",activityName);
        self.lbl_error.hidden = NO;
    }
    
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSString* activityName = @"UILoginView.storeCachedTwitterOAuthData:";
    NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
    
    //now we need to update the user's object and twitter information
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSArray* components = [data componentsSeparatedByString:@"&"];
    if ([components count] == 4) {
        
        NSString* oAuthToken = [[[components objectAtIndex:0]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* oAuthTokenSecret = [[[components objectAtIndex:1]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* twitterUserName = [[[components objectAtIndex:3]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* tID = [[[components objectAtIndex:2]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSNumber* twitterID = [tID numberValue];
        
        //need to dismiss the Twitter view controller here
        [self dismissModalViewControllerAnimated:YES];
        
        AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];
        if (authenticationContext == nil)
        {
            //user is not logged in
            [self showProgressBar:@"Logging in..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimePutAuthenticator]];
            Callback* callback = [[Callback alloc] initWithTarget:self withSelector:@selector(onGetAuthenticationContextDownloaded:)];
            
            Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)[UIApplication sharedApplication].delegate;
            NSString* deviceToken = appDelegate.deviceToken;
            
            [resourceContext getAuthenticatorTokenWithTwitter:twitterID 
                                              withTwitterName:twitterUserName 
                                              withAccessToken:oAuthToken 
                                        withAccessTokenSecret:oAuthTokenSecret 
                                               withExpiryDate:@""  
                                              withDeviceToken:deviceToken 
                                               onFinishNotify:callback];
            [callback release];
        }
        else
        {
            //user logged in
            //display progress indicator
            [self showProgressBar:@"Communicating with Twitter..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimePutAuthenticator]];
            
            Callback* callback = [[Callback alloc] initWithTarget:self withSelector:@selector(onGetAuthenticationContextDownloaded:)];
            
            [resourceContext updateAuthenticatorWithTwitter:twitterUserName 
                                            withAccessToken:oAuthToken 
                                      withAccessTokenSecret:oAuthTokenSecret 
                                             withExpiryDate:@"" 
                                             onFinishNotify:callback];
            [callback release];

        }
        
    }
    else {
        //error condition
        //need to dismiss the Twitter view controller here
        LOG_LOGINVIEWCONTROLLER(1, @"%@Twitter login view controller returned the wrong number of result components: %d",activityName,[components count]);
        [self dismissModalViewControllerAnimated:YES];
        [self dismissWithResult:NO];
    }
    
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
    NSString* activityName = @"UILoginView.cachedTwitterOAuthDataForUsername:";
    LOG_LOGINVIEWCONTROLLER(0, @"%@ called for username %@",activityName,username);
    return nil;
}
- (void) twitterOAuthConnectionFailedWithData: (NSData *) data 
{
    NSString* activityName = @"UILoginView.twitterOAuthConnectionFailedWithData:";
    LOG_LOGINVIEWCONTROLLER(1,@"%@Twitter connection failed",activityName);
    
}


#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.tf_active = textField;
    self.lbl_error.hidden = YES;
}

#pragma mark - Keyboard Handlers
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.sv_scrollView.contentInset = contentInsets;
    self.sv_scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    //if (!CGRectContainsPoint(aRect, self.tf_active.frame.origin)) {
    //CGPoint scrollPoint = CGPointMake(0.0, self.tf_active.frame.origin.y+(self.tf_active.frame.size.height*1.5)-kbSize.height);
    
    CGPoint scrollPoint = CGPointMake(0.0, self.tf_active.frame.origin.y-(self.tf_active.frame.size.height*2.0));
    [self.sv_scrollView setContentOffset:scrollPoint animated:YES];
    //}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [UIView beginAnimations:@"keyboardWillBeHiddenAnimation" context:nil];
    [UIView setAnimationDuration:0.35];
    
    self.sv_scrollView.contentInset = contentInsets;
    self.sv_scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

// Handles keyboard Return button pressed while editing a textfield to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [textField resignFirstResponder];
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

// Hides Keyboard when user touches screen outside of editable text view or field
- (IBAction)backgroundClick:(id)sender
{
    [self.tf_active resignFirstResponder];
}

#pragma mark - IBAction handlers
- (void)onCancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) onLoginButtonPressed:(id)sender
{
   //pressed when user is logging in with email/password
    NSString* email = self.tf_email.text;
    NSString* password = self.tf_password.text;
    
    self.lbl_error.hidden = YES;
    
    if (email != nil &&
        password != nil &&
        ![email isEqualToString: @""] &&
        ![password isEqualToString: @""])
    {
    
        Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
        NSString* deviceToken = appDelegate.deviceToken;
        ResourceContext* resourceContext = [ResourceContext instance];
    
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onGetAuthenticationContextDownloaded:)];
        callback.fireOnMainThread = YES;
        
        //show the progress bar
        [self showProgressBar:@"Logging in..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimeEmailLogin]];
        
        [resourceContext getAuthenticatorTokenWithEmail:email withPassword:password withDeviceToken:deviceToken onFinishNotify:callback];
        
        [callback release];
    }
    else {
        self.lbl_error.hidden = NO;
    }
    
}

- (IBAction) onFacebookButtonPressed:(id)sender
{
    //let us begin the facebook authentication process
    [self beginFacebookAuthentication];
}

- (IBAction) onTwitterButtonPressed:(id)sender
{
    [self beginTwitterAuthentication];
}

- (IBAction) onNewUserButtonPressed:(id)sender
{
    //lets load up the signup controller in modal view
    SignUpViewController* signUpViewController = [SignUpViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:signUpViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (IBAction) onForgotPWButtonPressed:(id)sender {
    NSURL *passwordResetURL = [NSURL URLWithString:@"http://www.bahndr.com/User/ResetPassword"];
    
    [[UIApplication sharedApplication] openURL:passwordResetURL];
}


#pragma mark - Async call backs
- (void) onAuthenticationFailed:(Callback*)callback
{
//   NSString* activityName = @"LoginViewController.onAuthenticationFailed:";
    self.lbl_error.hidden = NO; 
}

- (void) onUserLoggedIn:(CallbackResult *)result
{
//    NSString* activityName = @"LoginViewController.onUserLoggedIn:";
    
//    // Successful user login, launch menu
//    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
//    
//    [UIView animateWithDuration:0.75
//                     animations:^{
//                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
//                     }];
//    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
    
}

- (void) onGetAuthenticationContextDownloaded:(CallbackResult*)result 
{
    //NSString* activityName = @"UILoginView.onGetAuthenticationContextDownloaded:";
    GetAuthenticatorResponse* response = (GetAuthenticatorResponse*)result.response;
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([response.didSucceed boolValue] == YES)
    {
        BOOL loginResult = [authenticationManager processAuthenticationResponse:result];
        if (loginResult)
        {
            [self checkStatusAndDismiss];
        }
    }
    else 
    {
        self.lbl_error.hidden = NO;
    }
    
    //dismiss the progress bar
   // [self.parentViewController hideProgressBar];
    [self saveAuthenticatorResponse:response];
    
}

#pragma mark - Static Initializers
+ (LoginViewController*)createAuthenticationInstance:(BOOL)shouldGetFacebook 
                                    shouldGetTwitter:(BOOL)shouldGetTwitter
                                   onSuccessCallback:(Callback*)onSuccessCallback 
                                   onFailureCallback:(Callback*)onFailureCallback
{
    LoginViewController* retVal = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    retVal.onSuccessCallback = onSuccessCallback;
    retVal.onFailureCallback = onFailureCallback;
    retVal.shouldGetTwitter = shouldGetTwitter;
    retVal.shouldGetFacebook = shouldGetFacebook;
    [retVal autorelease];
    return retVal;

}

+ (LoginViewController*)createInstance:(BOOL)shouldGetFacebook 
                      shouldGetTwitter:(BOOL)shouldGetTwitter
                     onSuccessCallback:(Callback*)onSuccessCallback 
                     onFailureCallback:(Callback*)onFailureCallback;
{
    LoginViewController* retVal = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    retVal.onSuccessCallback = onSuccessCallback;
    retVal.onFailureCallback = onFailureCallback;
    retVal.shouldGetTwitter = shouldGetTwitter;
    retVal.shouldGetFacebook = shouldGetFacebook;
    [retVal autorelease];
    return retVal;
}

@end
