//
//  Mime_meShareMimeViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meViewMimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime.h"
#import "MimeAnswer.h"
#import "MimeAnswerState.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "UIImage+UIImageCategory.h"
#import "Macros.h"
#import "ViewMimeCase.h"
#import "DateTimeHelper.h"
#import "Mime_meAppDelegate.h"
#import "Favorite.h"
#import "SocialSharingManager.h"

#define kMIMEID @"mimeid"
#define kCREATORTID @"creatorid"

@interface Mime_meViewMimeViewController ()

@end

@implementation Mime_meViewMimeViewController
@synthesize mimeID              = m_mimeID;
@synthesize mimeAnswerID        = m_mimeAnswerID;
@synthesize creatorID           = m_creatorID;
@synthesize imageSize           = m_imageSize;
@synthesize viewMimeCase        = viewMimeCase;

@synthesize iv_photo            = m_iv_photo;
@synthesize v_background        = m_v_background;

@synthesize v_customNavContainer = m_v_customNavContainer;
@synthesize btn_back            = m_btn_back;
@synthesize iv_profilePicture   = m_iv_profilePicture;
@synthesize lbl_title           = m_lbl_title;
@synthesize btn_gemCount        = m_btn_gemCount;

// sentContainer
@synthesize v_confirmationView  = m_v_confirmationView;

// answerContainer
@synthesize v_answerView        = m_v_answerView;

@synthesize didUseHint          = m_didUseHint;


#pragma mark - View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showMimePhoto {
    // Set the Mime image on the image view
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:mime.objectid forKey:kMIMEID];
    
    if (mime.imageurl != nil && ![mime.imageurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        callback.fireOnMainThread = YES;
        UIImage* image = [imageManager downloadImage:mime.imageurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            self.imageSize = image.size;
            
            if (self.imageSize.height > self.imageSize.width) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
            }
            else {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            }
            self.iv_photo.image = image;
            self.iv_photo.backgroundColor = [UIColor blackColor];
            
            [self.view setNeedsDisplay];
        }
        else {
            self.iv_photo.contentMode = UIViewContentModeCenter;
            self.iv_photo.backgroundColor = [UIColor lightGrayColor];
            self.iv_photo.image = [UIImage imageNamed:@"logo-MimeMe.png"];
        }
    }
}

- (void)showProfilePicture {
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime *)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    // Set up the profile picture of the sender
    self.iv_profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_profilePicture.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iv_profilePicture.layer.borderWidth = 1.0;
    
//    ImageManager* imageManager = [ImageManager instance];
//    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:mime.objectid forKey:kCREATORTID];
//    
//    if (mime.imageurl != nil && ![mime.imageurl isEqualToString:@""]) {
//        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
//        callback.fireOnMainThread = YES;
//        UIImage* image = [imageManager downloadImage:mime.imageurl withUserInfo:nil atCallback:callback];
//        [callback release];
//        if (image != nil) {
//            
//            self.iv_profilePicture.image = [image imageScaledToSize:CGSizeMake(42, 42)];
//            
//            [self.view setNeedsDisplay];
//        }
//        else {
            self.iv_profilePicture.backgroundColor = [UIColor lightGrayColor];
            self.iv_profilePicture.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(42, 42)];
//        }
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add rounded corners to view
    [self.view.layer setCornerRadius:8.0f];
    [self.view.layer setMasksToBounds:YES];
    
    // Add drop shadow to the custom nav container
    [self.v_customNavContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.v_customNavContainer.layer setShadowOpacity:0.7f];
    [self.v_customNavContainer.layer setShadowRadius:2.0f];
    [self.v_customNavContainer.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [self.v_customNavContainer.layer setMasksToBounds:NO];
    
    // Setup Gem Count button, disable it for now
    [self.btn_gemCount setEnabled:NO];
    self.btn_gemCount.titleLabel.text = [self.loggedInUser.numberofpoints stringValue];
    
    // Create gesture recognizer for the photo image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showConfirmationView)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_photo addGestureRecognizer:oneFingerTap];
    
    //enable gesture events on the photo
    [self.iv_photo setUserInteractionEnabled:YES];
    
    // Hide the background view and back button until we need them
    switch (self.viewMimeCase) {
        case kVIEWSENTMIME:
            self.v_background.hidden = YES;
            self.btn_back.hidden = YES;
            break;
        default:
            self.v_background.hidden = YES;
            self.btn_back.hidden = NO;
            break;
    }
    
    // Setup notification for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    // Display the Mime photo onto the image view
    [self showMimePhoto];
    
    // Display the profile picture of the sender
    [self showProfilePicture];
    
    // Set up the remainder of the view based on the case
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    if (self.viewMimeCase == kVIEWSENTMIME) {
        self.lbl_title.text = [NSString stringWithFormat:@"Mime created by %@", mime.creatorname];
        
        NSString *confirmationTitle = @"Mime sent";
        
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        int editorMinimum = [settings.gems_for_new_mime intValue];
        
        NSString *subtitle = [NSString stringWithFormat:@"You earned %d gems!", editorMinimum];
        
        self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:confirmationTitle withSubtitle:subtitle forMimeWithID:self.mimeID];
        self.v_confirmationView.delegate = self;
        self.v_confirmationView.hidden = YES;
        self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.v_confirmationView];
        
    }
    else if (self.viewMimeCase == kVIEWANSWERMIME) {
        self.lbl_title.text = [NSString stringWithFormat:@"You are guessing a mime from %@", mime.creatorname];
        
        MimeAnswer *mimeAnswer = (MimeAnswer*)[resourceContext resourceWithType:MIMEANSWER withID:self.mimeAnswerID];
        
        int pointsAwarded = [mimeAnswer.pointsawarded intValue];
        
        NSString *title = @"Congratulations!";
        NSString *subtitle = [NSString stringWithFormat:@"You guessed right and earned %d gems", pointsAwarded];
        
        self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:title withSubtitle:subtitle forMimeWithID:self.mimeID];
        self.v_confirmationView.delegate = self;
        self.v_confirmationView.hidden = YES;
        self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.v_answerView = [Mime_meUIAnswerView createInstanceWithFrame:[Mime_meUIAnswerView frameForAnswerView] withWord:mime.word];
        self.v_answerView.delegate = self;
        self.v_answerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:self.v_answerView];
        
        // Update the view count on this Mime
        NSUInteger numTimesViewed = [mime.numberoftimesviewed integerValue];
        mime.numberoftimesviewed = [NSNumber numberWithInteger:(numTimesViewed + 1)];
        
    }
    else if (self.viewMimeCase == kVIEWSCRAPBOOKMIME) {
        self.lbl_title.text = [NSString stringWithFormat:@"Mime created by %@", mime.creatorname];
        
        NSString *from = [NSString stringWithFormat:@"from %@", mime.creatorname];
        NSDate  *dateCreated = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        NSString *dateCreatedStr = [DateTimeHelper formatMediumDate:dateCreated];
        
        self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:from withSubtitle:dateCreatedStr forMimeWithID:self.mimeID];
        self.v_confirmationView.delegate = self;
        self.v_confirmationView.hidden = YES;
        self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.v_confirmationView];
        
        self.v_answerView = [Mime_meUIAnswerView createInstanceWithFrame:[Mime_meUIAnswerView frameForAnswerView] withWord:mime.word];
        self.v_answerView.delegate = self;
        self.v_answerView.tf_answer.text = mime.word;
        self.v_answerView.tf_answer.enabled = NO;
        self.v_answerView.btn_clue.enabled = NO;
        self.v_answerView.btn_clue.hidden = YES;
        self.v_answerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:self.v_answerView];
        
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.iv_photo = nil;
    self.v_background = nil;
    self.v_confirmationView = nil;
    self.v_answerView = nil;
    
    self.v_customNavContainer = nil;
    self.btn_back = nil;
    self.iv_profilePicture = nil;
    self.lbl_title = nil;
    self.btn_gemCount = nil;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set up the view based on the case
    if (self.viewMimeCase == kVIEWSENTMIME) {
        
        [self showConfirmationView];
        
    }
    else if (self.viewMimeCase == kVIEWANSWERMIME) {
        
    }
    else if (self.viewMimeCase == kVIEWSCRAPBOOKMIME) {
        
    }
    
    // Adjust layout based on orientation
//    [self didRotate];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Landscape Photo Rotation Event Handler
- (void) didRotate {
//    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        self.iv_photo.frame = CGRectMake(0, 0, 480, 320);
//        self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
//    }
//    else {
//        self.iv_photo.frame = CGRectMake(0, 0, 320, 480);
//        if (self.imageSize.height > self.imageSize.width) {
//            self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
//        }
//        else {
//            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
//        }
//    }
//    [self.view setNeedsDisplay];
}

#pragma mark - UI Event Handlers
- (void)showConfirmationView {
    [self.v_confirmationView show];
    
    [self.view bringSubviewToFront:self.v_customNavContainer];
    [self.view bringSubviewToFront:self.btn_back];
}

#pragma mark UIButton Handlers
//- (void)showHUDForMimeGuessCancelled {
//    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
//    UIProgressHUDView* progressView = appDelegate.progressView;
//    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
//    progressView.delegate = self;
//    
//    // Indeterminate Progress bar
//    NSString* message = @"Loading...";
//    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
//    
//    // Save
//    ResourceContext *resourceContext = [ResourceContext instance];
//    
//    // Start a new undo group here
//    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
//    
//    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
//}

- (IBAction) onBackButtonPressed:(id)sender {
//    [self showHUDForMimeGuessCancelled];
    
    // Save and updated counts
    ResourceContext *resourceContext = [ResourceContext instance];
    
    // Start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Mime_meUIConfirmationView Delegate Methods
- (IBAction) onCloseButtonPressed:(id)sender {
    
}

- (IBAction) onOkButtonPressed:(id)sender {
    if (self.viewMimeCase == kVIEWSENTMIME) {
        Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
        
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                         }];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
    }
    else if (self.viewMimeCase == kVIEWANSWERMIME) {
        [self onBackButtonPressed:nil];
    }
    else if (self.viewMimeCase == kVIEWSCRAPBOOKMIME) {
        [self onBackButtonPressed:nil];
    }
}

- (void)showHUDForSaveFavorite {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    // Indeterminate Progress bar
    NSString* message = @"Saving favorite...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
//    // Determinate Progress bar
//    NSNumber* maxTimeToShowOnProgress = settings.http_timeout_seconds;
//    NSNumber* heartbeat = [NSNumber numberWithInt:5];
//    
//    //we need to construc the appropriate success, failure and progress messages for the submission
//    NSString* failureMessage = @"Oops, please try again.";
//    NSString* successMessage = @"Favorite saved!";
//    
//    NSMutableArray* progressMessage = [[[NSMutableArray alloc]init]autorelease];
//    [progressMessage addObject:@"Saving favorite..."];
//    
//    [self showDeterminateProgressBarWithMaximumDisplayTime:maxTimeToShowOnProgress withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
    
    // Save
    ResourceContext *resourceContext = [ResourceContext instance];
    
    // Start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    
}

- (IBAction) onFavoriteButtonPressed:(id)sender {
    // Create new Favorite object for this mime
    [Favorite createFavoriteWithMimeID:self.mimeID];
    
    // Mark this mime as a favorite
    ResourceContext *resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    mime.isfavorite = [NSNumber numberWithBool:YES];
    
    // Save
    [self showHUDForSaveFavorite];
}

- (void)composeShareEmail {
    // Get version information about the app and phone to prepopulate in the email
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the email subject
    [picker setSubject:[NSString stringWithFormat:@"Check out my mime on %@!", appName]];
    
    NSString *messageHeader = [NSString stringWithFormat:@"I'm playing this new game, %@, on my iPhone. Its so much fun. Check out my mime and try to guess the right answer!<br><br>My username is %@.", appName, self.loggedInUser.username];
    [picker setMessageBody:messageHeader isHTML:YES];
    
    // Present the mail composition interface
    [self presentModalViewController:picker animated:YES];
    [picker release]; // Can safely release the controller now.
}

- (IBAction) onEmailButtonPressed:(id)sender {
    [self composeShareEmail];
}

- (IBAction) onFacebookButtonPressed:(id)sender {   
    //we check to ensure the user is logged in to Facebook first
    AuthenticationContext* loggedInContext = [[AuthenticationManager instance]contextForLoggedInUser];
    if (loggedInContext == nil ||
        loggedInContext.hasFacebook == NO) 
    {
        //user is not logged in, must log in first and also ensure they have a facebook account
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onFacebookButtonPressed:)  fireOnMainThread:YES];
        [self authenticateAndGetFacebook:YES getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
        
    }
    else {
        Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate *)[[UIApplication sharedApplication] delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        progressView.delegate = self;
        
        NSString* message = @"Sharing to Facebook...";
        
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
       
        [sharingManager shareMimeOnFacebook:self.mimeID onFinish:nil trackProgressWith:progressView];
            
        [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    }
}

- (IBAction) onTwitterButtonPressed:(id)sender {   
    //we check to ensure the user is logged in to Facebook first
    AuthenticationContext* loggedInContext = [[AuthenticationManager instance]contextForLoggedInUser];
    if (loggedInContext == nil ||
        loggedInContext.hasTwitter == NO) 
    {
        //user is not logged in, must log in first and also ensure they have a facebook account
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onTwitterButtonPressed:)  fireOnMainThread:YES];
        [self authenticateAndGetFacebook:NO getTwitter:YES onSuccessCallback:onSuccessCallback onFailureCallback:nil];
        
    }
    else {
        Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate *)[[UIApplication sharedApplication] delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        progressView.delegate = self;
        
        NSString* message = @"Sharing to Twitter...";
        
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        
        [sharingManager shareMimeOnTwitter:self.mimeID onFinish:nil trackProgressWith:progressView];
        
        [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    }
}

#pragma mark Mime_meUIAnswerView Delegate Methods
- (void)showHUDForSendAnswer {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    // Determinate Progress bar
    NSNumber* maxTimeToShowOnProgress = settings.http_timeout_seconds;
    NSNumber* heartbeat = [NSNumber numberWithInt:5];
    
    //we need to construct the appropriate success, failure and progress messages for the submission
    NSString* failureMessage = @"Oops, please try again.";
    NSString* successMessage = @"Success!";
    
    NSMutableArray* progressMessage = [[[NSMutableArray alloc]init]autorelease];
    [progressMessage addObject:@"Correct! Sending answer..."];
    
    [self showDeterminateProgressBarWithMaximumDisplayTime:maxTimeToShowOnProgress withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
    
    // Save
    ResourceContext *resourceContext = [ResourceContext instance];
    
    // Start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    
}

- (void) onSubmittedCorrectAnswer:(BOOL)isCorrect {
    // User submitted an answer
    
    ResourceContext *resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    if (isCorrect == YES) {
        // submitted answer is correct, update attempt and answer count properties on the mime object
        
        mime.hasanswered = [NSNumber numberWithBool:YES];
        
        NSUInteger numAttempts = [mime.numberofattempts integerValue];
        mime.numberofattempts = [NSNumber numberWithInteger:(numAttempts + 1)];
        
        NSUInteger numTimesAnswered = [mime.numbertimesanswered integerValue];
        mime.numbertimesanswered = [NSNumber numberWithInteger:(numTimesAnswered + 1)];
        
        if (self.mimeAnswerID == nil) {
            // We need to create a MimeAnswer object if this mime was loaded from the recent mimes or staff picked sections
            MimeAnswer *newMimeAnswer = [MimeAnswer createMimeAnswerWithMimeID:self.mimeID withTargetFacebookID:self.loggedInUser.fb_user_id withTargetEmail:self.loggedInUser.email withTargetName:self.loggedInUser.username];
            
            self.mimeAnswerID = newMimeAnswer.objectid;
        }
        
        // Update the MimeAnswer properties
        MimeAnswer *mimeAnswer = (MimeAnswer*)[resourceContext resourceWithType:MIMEANSWER withID:self.mimeAnswerID];
        
        mimeAnswer.state = [NSNumber numberWithInt:kANSWERED];
        mimeAnswer.didusehint = [NSNumber numberWithBool:self.didUseHint];
        
        // Increment the users gem total for the newly created Mime
        int pointsAwarded = [mimeAnswer.pointsawarded intValue];
        int newGemTotal = [self.loggedInUser.numberofpoints intValue] + pointsAwarded;
        self.loggedInUser.numberofpoints = [NSNumber numberWithInt:newGemTotal]; 
        
        // Show the hud and save
        [self showHUDForSendAnswer];
    }
    else {
        // incorrect answer, update attempt count
        
        NSUInteger numAttempts = [mime.numberofattempts integerValue];
        mime.numberofattempts = [NSNumber numberWithInteger:(numAttempts + 1)];
    }
}

- (IBAction) onSlideButtonPressed:(id)sender {
    
}

- (IBAction) onClueButtonPressed:(id)sender {
    // Flag that the user did use a hint.
    // We will update the didUseHint property on the MimeAnswer object at save
    self.didUseHint = YES;
    
    // Decrement the users gem total for use of a clue
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    int gemsForClue = [settings.gems_for_clue intValue];
    int newGemTotal = [self.loggedInUser.numberofpoints intValue] - gemsForClue;
    self.loggedInUser.numberofpoints = [NSNumber numberWithInt:newGemTotal];
}

- (IBAction) onFlagButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Is something about this mime offensive?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Flag for review"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        
        //display progress view on the submission of a flag
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        NSString* message = @"Flagging for review...";
        NSString* successMessage = @"Mime is flagged for review";
        NSString* failureMessage = @"Ooops, something went wrong. Please flag again.";
        
        
        [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:[NSArray arrayWithObject:message]];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        //we start a new undo group here
        [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        
        Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
        
        mime.numberofflags = [NSNumber numberWithInt:([mime.numberofflags intValue] + 1)];
        
        Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate *)[[UIApplication sharedApplication] delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        progressView.delegate = self;
        
        //now we need to commit to the store
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    }
}

#pragma mark - MailComposeController Delegate
// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meViewMimeViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    for (Request* request in progressView.requests) {
        NSArray* changedAttributes = request.changedAttributesList;
        //list of all changed attributes
        
        if ([changedAttributes containsObject:NUMBEROFFLAGS]) {
            if (progressView.didSucceed) {
                // Flag sent sucessfully
                LOG_REQUEST(0, @"%@ Mime flag sent successful", activityName);
                
            }
            else {
                // Send flag failed
                LOG_REQUEST(1, @"%@ Mime flag sent failure", activityName);
                
                // Undo save
                LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
                ResourceContext* resourceContext = [ResourceContext instance];
                [resourceContext.managedObjectContext.undoManager undo];
                
                NSError* error = nil;
                [resourceContext.managedObjectContext save:&error];
            }
        }
        else if ([changedAttributes containsObject:STATE]) {
            // Sent answer
            if (progressView.didSucceed) {
                // Answer sent sucessfully
                LOG_REQUEST(0, @"%@ Mime answer sent successful", activityName);
                
                // Remove the Answer view and back button
                [self.v_answerView removeFromSuperview];
                [self.btn_back removeFromSuperview];
                
                // Add the Confirmation view
                [self.view addSubview:self.v_confirmationView];
                
                [self showConfirmationView];
            }
            else {
                // Send answer failed
                LOG_REQUEST(1, @"%@ Mime answer sent failure", activityName);
                
                //we need to undo the operation that was last performed
                LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
                ResourceContext* resourceContext = [ResourceContext instance];
                [resourceContext.managedObjectContext.undoManager undo];
                
                NSError* error = nil;
                [resourceContext.managedObjectContext save:&error];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            // Saved favorite
            if (progressView.didSucceed) {
                // Favorite saved sucessfully
                LOG_REQUEST(0, @"%@ Mime favorite saved successful", activityName);
                
            }
            else {
                // Favorite save failed
                LOG_REQUEST(1, @"%@ Mime favorite save failure", activityName);
                
                // Undo save
                LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
                ResourceContext* resourceContext = [ResourceContext instance];
                [resourceContext.managedObjectContext.undoManager undo];
                
                NSError* error = nil;
                [resourceContext.managedObjectContext save:&error];
                
                [self.v_confirmationView.btn_favorite setEnabled:YES];
            }
        }
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meShareMimeViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
    NSNumber* userID = [userInfo valueForKey:kCREATORTID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    if ([mimeID isEqualToNumber:self.mimeID]) {
        // Mime image downloaded
        if ([response.didSucceed boolValue] == YES) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
            
            self.imageSize = response.image.size;
            
            if (self.imageSize.height > self.imageSize.width) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
            }
            else {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            }
            
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.backgroundColor = [UIColor blackColor];
            
            [self.view setNeedsDisplay];
        }
        else {
            self.iv_photo.contentMode = UIViewContentModeCenter;
            self.iv_photo.backgroundColor = [UIColor lightGrayColor];
            self.iv_photo.image = [UIImage imageNamed:@"logo-MimeMe.png"];
            LOG_IMAGE(1,@"%@Image failed to download",activityName);
        }
    }
    else if ([userID isEqualToNumber:mime.creatorid]) {
        // Mime image downloaded
        if ([response.didSucceed boolValue] == YES) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            
            UIImage *scaledImage = [response.image imageScaledToSize:CGSizeMake(42, 42)];
            
            [self.iv_profilePicture performSelectorOnMainThread:@selector(setImage:) withObject:scaledImage waitUntilDone:NO];
            
            [self.view setNeedsDisplay];
        }
        else {
            self.iv_profilePicture.backgroundColor = [UIColor lightGrayColor];
            self.iv_profilePicture.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(42, 42)];
            LOG_IMAGE(1,@"%@Image failed to download",activityName);
        }
    }
    
//    if ([response.didSucceed boolValue] == YES) {
//        if ([mimeID isEqualToNumber:self.mimeID]) {
//            //we only draw the image if this view hasnt been repurposed for another photo
//            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
//            
//            self.imageSize = response.image.size;
//            
//            if (self.imageSize.height > self.imageSize.width) {
//                self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
//            }
//            else {
//                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
//            }
//            
//            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
//            self.iv_photo.backgroundColor = [UIColor blackColor];
//            
//            [self.view setNeedsDisplay];
//        }
//        
//    }
//    else {
//        self.iv_photo.contentMode = UIViewContentModeCenter;
//        self.iv_photo.backgroundColor = [UIColor lightGrayColor];
//        self.iv_photo.image = [UIImage imageNamed:@"logo-MimeMe.png"];
//        LOG_IMAGE(1,@"%@Image failed to download",activityName);
//    }
    
}


#pragma mark - Static Initializers
+ (Mime_meViewMimeViewController*)createInstanceForCase:(int)viewMimeCase withMimeID:(NSNumber *)mimeID withMimeAnswerIDorNil:(NSNumber *)mimeAnswerID {
    Mime_meViewMimeViewController* instance = [[Mime_meViewMimeViewController alloc]initWithNibName:@"Mime_meViewMimeViewController" bundle:nil];
    [instance autorelease];
    instance.viewMimeCase = viewMimeCase;
    instance.mimeID = mimeID;
    instance.mimeAnswerID = mimeAnswerID;
    return instance;
}

@end
