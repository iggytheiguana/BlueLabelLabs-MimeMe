//
//  BaseViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "Mime_meAppDelegate.h"
#import "CallbackResult.h"
#import "Macros.h"
#import "UICameraActionSheet.h"
#import "ImageManager.h"
#import "UIStrings.h"
#import "LoginViewController.h"

#define kSELECTOR       @"selector"
#define kTARGETOBJECT   @"targetobject"
#define kPARAMETER      @"parameter"

@implementation BaseViewController

@synthesize authenticationManager = __authenticationManager;
@synthesize loggedInUser = __loggedInUser;
@synthesize feedManager           = __feedManager;
@synthesize eventManager          = __eventManager;
@synthesize loginView             = m_loginView;

#pragma mark - Properties
- (EventManager*) eventManager {
    if (__eventManager != nil) {
        return __eventManager;
    }
    __eventManager = [EventManager instance];
    return __eventManager;
}

- (FeedManager*)feedManager {
    if (__feedManager != nil) {
        return __feedManager;
    }
    __feedManager = [FeedManager instance];
    return __feedManager;
}

- (AuthenticationManager*) authenticationManager {
    if (__authenticationManager != nil) {
        return __authenticationManager;
    }
    __authenticationManager = [AuthenticationManager instance];
    return __authenticationManager;
}

- (User*) loggedInUser {    
    if ([self.authenticationManager isUserAuthenticated]) {    
        //retrieves the current logged in user
        ResourceContext* resourceContext = [ResourceContext instance];
        return (User*)[resourceContext resourceWithType:USER withID:self.authenticationManager.m_LoggedInUserID];
    } else {
        return nil;
    }
}

- (void) commonInit {
    

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Frames
- (CGRect) frameForLoginView {
    return CGRectMake(0, 0, 320, 460);
}



- (void)dealloc
{
    //[self.loginView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Callback* loginCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUserLoggedIn:)];
    Callback* logoutCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUserLoggedOut:)];    
    Callback* showProgressBarCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onShowProgressView:)];
    Callback* hideProgressBarCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onHideProgressView:)];    
    Callback* failedAuthenticationCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onAuthenticationFailed:)];    
    Callback* unknownRequestFailureCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUnknownRequestFailure:)];
    Callback* applicationDidBecomeActiveCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onApplicationDidBecomeActive:)];
    Callback* applicationWentToBackgroundCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onApplicationWentToBackground:)];
    
    //we configure each callback to callback on the main thread
    loginCallback.fireOnMainThread = YES;
    logoutCallback.fireOnMainThread = YES;
    showProgressBarCallback.fireOnMainThread = YES;
    hideProgressBarCallback.fireOnMainThread = YES;
    failedAuthenticationCallback.fireOnMainThread = YES;
    unknownRequestFailureCallback.fireOnMainThread = YES;
    applicationDidBecomeActiveCallback.fireOnMainThread = YES;
    applicationWentToBackgroundCallback.fireOnMainThread = YES;
    
    [self.eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
    [self.eventManager registerCallback:logoutCallback forSystemEvent:kUSERLOGGEDOUT];
    [self.eventManager registerCallback:showProgressBarCallback forSystemEvent:kSHOWPROGRESS];
    [self.eventManager registerCallback:hideProgressBarCallback forSystemEvent:kHIDEPROGRESS];
    [self.eventManager registerCallback:failedAuthenticationCallback forSystemEvent:kAUTHENTICATIONFAILED];
    [self.eventManager registerCallback:unknownRequestFailureCallback forSystemEvent:kUNKNOWNREQUESTFAILURE];
    [self.eventManager registerCallback:applicationDidBecomeActiveCallback forSystemEvent:kAPPLICATIONBECAMEACTIVE];
    [self.eventManager registerCallback:applicationWentToBackgroundCallback forSystemEvent:kAPPLICATIONWENTTOBACKGROUND];
    
    [unknownRequestFailureCallback release];
    [failedAuthenticationCallback release];
    [loginCallback release];
    [logoutCallback release];
    [showProgressBarCallback release];
    [hideProgressBarCallback release];
    [applicationDidBecomeActiveCallback release];
    [applicationWentToBackgroundCallback release];

    CGRect frameForLoginView = [self frameForLoginView];
    UILoginView* lv = [[UILoginView alloc] initWithFrame:frameForLoginView withParent:self];
    self.loginView = lv;
    [lv release];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* activityName = @"BaseViewController.viewWillAppear:";
    
    // Refresh the notification feed
    Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
    BOOL isEnumeratingFeed = [[FeedManager instance] tryRefreshFeedOnFinish:callback];
    if (isEnumeratingFeed) 
    {
        LOG_BASEVIEWCONTROLLER(0, @"%@Refreshing user's notification feed", activityName);
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    //NSString* activityName = @"BaseViewController.viewWillDisappear:";
    [super viewWillDisappear:animated];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loginView = nil;
    
    //we need to de-register from all events we may have subscribed too
    EventManager* eventManager = [EventManager instance];
    [eventManager unregisterFromAllEvents:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Progress bar management
- (void) showDeterminateProgressBarWithMaximumDisplayTime: (NSNumber*)maximumTimeInSeconds
                      withHeartbeat:(NSNumber*)heartbeatInSeconds 
                   onSuccessMessage:(NSString*)successMessage 
                   onFailureMessage:(NSString*)failureMessage 
                 inProgressMessages:(NSArray*)progressMessages
{
    
    
    NSString* activityName = @"BaseViewController.showDeterminateProgressBar:";
    
    Mime_meAppDelegate* delegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;
    
    
    //first check if this view controller is the top level visible controller
   // if (self.navigationController.visibleViewController == self) {
       
        [progressView removeAllSubviews];
        
        [self.view addSubview:progressView];
        
        progressView.customView = nil;
        progressView.mode = MBProgressHUDModeDeterminate;
        
        
        
        LOG_BASEVIEWCONTROLLER(0, @"%@showing progress bar", activityName);
        
        if (heartbeatInSeconds != nil) 
        {
            [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds withHeartbeatInterval:heartbeatInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
        }
        else 
        {
            [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
        }
    //}

}

- (void) showDeterminateProgressBarWithMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds 
                   onSuccessMessage:(NSString*)successMessage 
                   onFailureMessage:(NSString*)failureMessage 
                 inProgressMessages:(NSArray*)progressMessages 
{
    [self showDeterminateProgressBarWithMaximumDisplayTime:maximumTimeInSeconds withHeartbeat:nil onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessages];
    
}
- (void) showProgressBar:(NSString *)message 
          withCustomView:(UIView *)view 
  withMaximumDisplayTime:(NSNumber *)maximumTimeInSeconds 
{
    NSString* activityName = @"BaseViewController.showProgressBar:";
    
    Mime_meAppDelegate* delegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;

    
    //first check if this view controller is the top level visible controller
   // if (self.navigationController.visibleViewController == self) {
        progressView.labelText = message;
        [progressView removeAllSubviews];
        
        
        [self.view addSubview:progressView];
        
        if (view != nil) {
            progressView.customView = view;
            progressView.mode = MBProgressHUDModeCustomView;
        }
        else {
            progressView.customView = nil;
            progressView.mode = MBProgressHUDModeIndeterminate;
        }
        
        //progressView.maximumDisplayTime = maximumTimeInSeconds;
        
       // [progressView hide:NO];
        LOG_BASEVIEWCONTROLLER(0, @"%@showing progress bar", activityName);
        NSArray* progressMessages = [NSArray arrayWithObject:message];
        NSString* successMessage = @"Success!";
        NSString* failureMessage = @"Oops, try again?";
        [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
        
    //}
}

- (void)showProgressBar:(NSString*)message 
         withCustomView:(UIView*)view 
 withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds
    showFinishedMessage:(BOOL)showFinishedMessage {
    
    NSString* activityName = @"BaseViewController.showProgressBar:";
    
    Mime_meAppDelegate* delegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;
    
    
    //first check if this view controller is the top level visible controller
    // if (self.navigationController.visibleViewController == self) {
    progressView.labelText = message;
    [progressView removeAllSubviews];
    
    
    [self.view addSubview:progressView];
    
    if (view != nil) {
        progressView.customView = view;
        progressView.mode = MBProgressHUDModeCustomView;
    }
    else {
        progressView.customView = nil;
        progressView.mode = MBProgressHUDModeIndeterminate;
    }
    
    //progressView.maximumDisplayTime = maximumTimeInSeconds;
    
    // [progressView hide:NO];
    LOG_BASEVIEWCONTROLLER(0, @"%@showing progress bar", activityName);
    NSArray* progressMessages = [NSArray arrayWithObject:message];
    
    NSString* successMessage = message;
    NSString* failureMessage = message;
    if (showFinishedMessage == YES) {
        successMessage = @"Success!";
        failureMessage = @"Oops, try again?";
    }
    
    [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
    
    //}
    
}

- (void) hideProgressBar {
    NSString* activityName = @"BaseViewController.hideProgressBar:";
    Mime_meAppDelegate* delegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;
    
    if (self.navigationController.visibleViewController == self) {
        LOG_BASEVIEWCONTROLLER(0, @"%@Hiding progress bar and removing it from this view",activityName);
        [progressView removeFromSuperview];
        //[progressView hide:YES];
        if (!progressView.isHidden) {
            [progressView hide:YES];
        }
        progressView.delegate = nil;
        delegate.progressView = nil;

    }
}


#pragma mark - Instance Methods 
- (BOOL) isViewControllerActive {
    //returns a boolean indicating whether this instance is the currently shown view in the application
    return  ( [self isViewLoaded] && self.view.window);
}

- (void) clearDisplayedLoginView {
    NSString* activityName = @"BaseViewController.clearDisplayedLoginView:";
    //if the login view is showing, we remove it from the super view so we dont lock the screen potentially.
    if (self.loginView.superview != nil &&
        self.loginView.superview == self.view) {
        
        LOG_BASEVIEWCONTROLLER(0,@"%@Detected login view controller is still showing, clearing the loginview",activityName);
        //remove from superview
        [self.loginView removeFromSuperview];
        

    }
}


- (void) authenticateAndGetFacebook:(BOOL)getFaceobook 
                         getTwitter:(BOOL)getTwitter 
                  onSuccessCallback:(Callback*)successCallback 
                  onFailureCallback:(Callback*)failCallback 
{
    LoginViewController* loginViewController = [LoginViewController createAuthenticationInstance:getFaceobook shouldGetTwitter:getTwitter onSuccessCallback:successCallback onFailureCallback:failCallback];
   
//    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
//    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController hidesBottomBarWhenPushed];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:loginViewController] animated:NO];
//    [navigationController release];
    
}

- (void) authenticate:(BOOL)facebook 
          withTwitter:(BOOL)twitter 
     onFinishSelector:(SEL)sel 
       onTargetObject:(id)targetObject 
           withObject:(id)parameter 
{
    NSMutableDictionary* userInfo = nil;
    if (targetObject != nil) {
        userInfo = [[NSMutableDictionary alloc]init ];
        //we stuff in the callback parameters into the user info, we will
        //use these when dealing with the callback
        NSValue* selectorValue = [NSValue valueWithPointer:sel];
        [userInfo setValue:selectorValue forKey:kSELECTOR];
        [userInfo setValue:targetObject forKey:kTARGETOBJECT];
        [userInfo setValue:parameter forKey:kPARAMETER];
    }
    
    Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginComplete:) withContext:userInfo];
    Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:) withContext:userInfo];
    
    [userInfo release];
    
    [self.view addSubview:self.loginView];
    [self.loginView authenticate:facebook withTwitter:twitter onSuccessCallback:onSucccessCallback onFailCallback:onFailCallback];
    [onSucccessCallback release];
    [onFailCallback release];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* activityName = @"BaseViewController.alertView:clickedButtonAtIndex:";
    
    AuthenticationManager* authnManager = [AuthenticationManager instance];
    AuthenticationContext* authnContext = [authnManager contextForLoggedInUser];
    
    if (alertView.delegate == self && [authnContext.isfirsttime boolValue]) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            // user selected cancel button
            
        }
        else {
            // user selected the action button, now we call the callback passed in originally
            if (alertView.targetObject != nil &&
                [alertView.targetObject respondsToSelector:alertView.onFinishSelector]) {
                LOG_BASEVIEWCONTROLLER(0,@"%@Resuming callback method",activityName);
                [alertView.targetObject performSelectorOnMainThread:alertView.onFinishSelector withObject:alertView.withObject waitUntilDone:NO];
            }
            else {
                LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
            }
        }
    }
}

#pragma mark - Async Handlers
//this method handles a Login attempt that is either cancelled or returned unsuccessfully
//any view controller subclass can use this as the target for their onFailCallback passed to the
//UILoginView.h
- (void) onLoginFailed:(CallbackResult *)result {
    NSString* activityName = @"BaseViewController.onAuthenticateFailed:";
    
    //need to display an error message to the user
    //TODO: create generic error emssage display
    LOG_BASEVIEWCONTROLLER(1, @"%@Authentication failed, cannot complete initial request",activityName);
}

- (void) onSaveComplete:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onSaveComplete:";
    
    LOG_BASEVIEWCONTROLLER(0, @"%@Save completed successfully",activityName);
}

- (void) onUnknownRequestFailure:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onUnknownRequestFailure:";
    LOG_BASEVIEWCONTROLLER(0,@"%@Unknown request failure",activityName);
}

- (void) onAuthenticationFailed:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onAuthenticationFailed:";
    
    LOG_BASEVIEWCONTROLLER(0, @"%@Authentication Failed",activityName);
    
    AuthenticationManager* authenticationmanager = [AuthenticationManager instance];
    [authenticationmanager logoff];
    [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:nil onFailureCallback:nil];
    //we handle an authentication failed by requiring they authenticate again against facebook
//    if ( [self isViewLoaded] && self.view.window) {
//        // we only process if this view controller is on top
//        LOG_BASEVIEWCONTROLLER(0, @"%@Processing Authentication Failed Event",activityName);
//        AuthenticationManager* authnManager = [AuthenticationManager instance];
//        [authnManager logoff];
//        [self authenticate:YES withTwitter:NO onFinishSelector:nil onTargetObject:nil withObject:nil];
//    }
}

- (void) onApplicationWentToBackground:(CallbackResult*)result {
    //this event is raiseda nytime the application to have moved into the background state
    NSString* activityName = @"BaseViewController.onApplicationWentToBackground:";
    if ([self isViewControllerActive]) {
        LOG_BASEVIEWCONTROLLER(0, @"%@Detected application entered background",activityName);
        
       // [self clearDisplayedLoginView];
    }
}

- (void) onApplicationDidBecomeActive:(CallbackResult*)result {
    //this event is raised anytime the application is detected to have moved back into the active state
    NSString* activityName = @"BaseViewController.onApplicationDidBecomeActive:";
    if ([self isViewControllerActive]) {
        LOG_BASEVIEWCONTROLLER(0,@"%@Detected application became active",activityName);
    
        [self clearDisplayedLoginView];
    }
    
}

- (void) onLoginComplete:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onLoginComplete:";
        
    Response* response = result.response;
    
    if (response.didSucceed) {
        LOG_BASEVIEWCONTROLLER(0,@"%@Login completed successfully",activityName);
        
        /*// unpack the userInfo
        NSDictionary* userInfo = result.context;
        
        SEL selector = nil;
        id target = nil;
        id parameter = nil;
        
        if (userInfo != nil) {
            NSValue* selectorValue = [userInfo valueForKey:kSELECTOR];
            selector =  [selectorValue pointerValue];
            target =  [userInfo valueForKey:kTARGETOBJECT];
            parameter =  [userInfo valueForKey:kPARAMETER];
        }
        
        AuthenticationManager* authnManager = [AuthenticationManager instance];
        AuthenticationContext* authnContext = [authnManager contextForLoggedInUser];
        
        if ([authnContext.isfirsttime boolValue]) {
            LOG_BASEVIEWCONTROLLER(0,@"%@First time user is loggin in",activityName);
            UICustomAlertView *alert = [[UICustomAlertView alloc]
                                        initWithTitle:@"Welcome!"
                                        message:[NSString stringWithFormat:@"Hello %@ %@! We've set up an account for you. Would you like to visit your profile and account settings, or continue from where you left off?", self.loggedInUser.firstname, self.loggedInUser.lastname]
                                        delegate:self
                                        onFinishSelector:selector
                                        onTargetObject:target
                                        withObject:parameter
                                        cancelButtonTitle:@"Profile"
                                        otherButtonTitles:@"Continue", nil];
            
            [alert show];
            [alert release];
        }
        else {
            // we call the callback passed in originally
            if (target != nil &&
                [target respondsToSelector:selector]) {
                LOG_BASEVIEWCONTROLLER(0,@"%@Resuming original method",activityName);
                [target performSelectorOnMainThread:selector withObject:parameter waitUntilDone:NO];
            }
            else {
                LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
            }
        }*/
        
        /*//now we call the callback passed in originally
        if (target != nil &&
            [target respondsToSelector:selector]) {
            LOG_BASEVIEWCONTROLLER(0,@"%@Resuming original method",activityName);
            [target performSelectorOnMainThread:selector withObject:parameter waitUntilDone:NO];
        }
        else {
            LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
        }*/
    }
    else {
        LOG_BASEVIEWCONTROLLER(0,@"%@Login failed",activityName);

    }
}

- (void) onPhotoTakenWithThumbnailImage:(UIImage *)thumbnailImage withFullImage:(UIImage *)image {
    
}

- (void) onUserLoggedIn:(CallbackResult*)result {
    
}

- (void) onUserLoggedOut:(CallbackResult*)result {
    
}

- (void) onShowProgressView:(CallbackResult*)result {
    NSDictionary* userInfo = result.context;
    NSString* message = [userInfo valueForKey:kMessage];
    UIView* customView = [userInfo valueForKey:kCustomView];
    NSNumber* maximumTimeInSeconds = [userInfo valueForKey:kMaximumTimeInSeconds];
    [self showProgressBar:message withCustomView:customView withMaximumDisplayTime:maximumTimeInSeconds];
}

- (void) onHideProgressView:(CallbackResult*)result {
    [self hideProgressBar];
}

#pragma mark - Feed Event Handlers
- (void) onFeedRefreshComplete:(CallbackResult*)result 
{
    // Update notifications
    
}


@end
