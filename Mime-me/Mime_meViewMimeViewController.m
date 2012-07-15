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
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "ViewMimeCase.h"
#import "DateTimeHelper.h"
#import "Mime_meAppDelegate.h"

#define kMIMEID @"mimeid"

@interface Mime_meViewMimeViewController ()

@end

@implementation Mime_meViewMimeViewController
@synthesize mimeID              = m_mimeID;
@synthesize mimeAnswerID        = m_mimeAnswerID;
@synthesize imageSize           = m_imageSize;
@synthesize viewMimeCase        = viewMimeCase;

@synthesize iv_photo            = m_iv_photo;
@synthesize iv_logo             = m_iv_logo;
@synthesize btn_back            = m_btn_back;
@synthesize v_background        = m_v_background;

// sentContainer
@synthesize v_confirmationView  = m_v_confirmationView;

// answerContainer
@synthesize v_answerView        = m_v_answerView;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add drop shadow to the back button
    [self.btn_back.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.btn_back.layer setShadowOpacity:0.7f];
    [self.btn_back.layer setShadowRadius:2.0f];
    [self.btn_back.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [self.btn_back.layer setMasksToBounds:NO];
    
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
        case kSENTMIME:
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.iv_photo = nil;
    self.iv_logo = nil;
    self.btn_back = nil;
    self.v_background = nil;
    self.v_confirmationView = nil;
    self.v_answerView = nil;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    MimeAnswer *mimeAnswer = (MimeAnswer*)[resourceContext resourceWithType:MIMEANSWER withID:self.mimeAnswerID];
    
    // Set up the view based on the case
    if (self.viewMimeCase == kSENTMIME) {
        NSString *title = @"Mime sent";
        NSString *subtitle = [NSString stringWithFormat:@"You earned %d gems!", 5];
        
        self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:title withSubtitle:subtitle];
        self.v_confirmationView.delegate = self;
        self.v_confirmationView.hidden = YES;
        self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.v_confirmationView];
        
        [self showConfirmationView];
        
    }
    else if (self.viewMimeCase == kANSWERMIME) {
        int pointsAwarded = [mimeAnswer.pointsawarded intValue];
        NSString *title = @"Congratulations!";
        NSString *subtitle = [NSString stringWithFormat:@"You guessed right and earned %d gems", pointsAwarded];
        
        self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:title withSubtitle:subtitle];
        self.v_confirmationView.delegate = self;
        self.v_confirmationView.hidden = YES;
        self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        NSString *from = [NSString stringWithFormat:@"from %@", mime.creatorname];
        self.v_answerView = [Mime_meUIAnswerView createInstanceWithFrame:[Mime_meUIAnswerView frameForAnswerView] withTitle:from withWord:mime.word];
        self.v_answerView.delegate = self;
        self.v_answerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:self.v_answerView];
        
        // Update the view count on this Mime
        NSUInteger numTimesViewed = [mime.numberoftimesviewed integerValue];
        mime.numberoftimesviewed = [NSNumber numberWithInteger:(numTimesViewed + 1)];
        
    }
    else if (self.viewMimeCase == kSCRAPBOOKMIME) {
        
        NSString *from = [NSString stringWithFormat:@"from %@", mime.creatorname];
        NSDate  *dateCreated = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        NSString *dateCreatedStr = [DateTimeHelper formatMediumDate:dateCreated];
        
        self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:from withSubtitle:dateCreatedStr];
        self.v_confirmationView.delegate = self;
        self.v_confirmationView.hidden = YES;
        self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.v_confirmationView];
        
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
    
    [self.view bringSubviewToFront:self.iv_logo];
    [self.view bringSubviewToFront:self.btn_back];
}

#pragma mark UIButton Handlers
- (void)showHUDForMimeGuessCancelled {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    // Indeterminate Progress bar
    NSString* message = @"Loading...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
    // Save
    ResourceContext *resourceContext = [ResourceContext instance];
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
}

- (IBAction) onBackButtonPressed:(id)sender {
    [self showHUDForMimeGuessCancelled];
}

#pragma mark Mime_meUIConfirmationView Delegate Methods
- (IBAction) onCloseButtonPressed:(id)sender {
    
}

- (IBAction) onOkButtonPressed:(id)sender {
    if (self.viewMimeCase == kSENTMIME) {
        Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
        
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                         }];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
    }
    else if (self.viewMimeCase == kANSWERMIME) {
        [self onBackButtonPressed:nil];
    }
    else if (self.viewMimeCase == kSCRAPBOOKMIME) {
        [self onBackButtonPressed:nil];
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
    
    //we need to construc the appropriate success, failure and progress messages for the submission
    NSString* failureMessage = @"Oops, please try again.";
    NSString* successMessage = @"Success!";
    
    NSMutableArray* progressMessage = [[[NSMutableArray alloc]init]autorelease];
    [progressMessage addObject:@"Sending answer..."];
    
    [self showDeterminateProgressBarWithMaximumDisplayTime:maxTimeToShowOnProgress withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
    
    // Save
    ResourceContext *resourceContext = [ResourceContext instance];
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    
}

- (void) onSubmittedCorrectAnswer:(BOOL)isCorrect {
    // User submitted an answer
    
    ResourceContext *resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    if (isCorrect == YES) {
        // submitted answer is correct, update answer count and save
        
        NSUInteger numTimesAnswered = [mime.numbertimesanswered integerValue];
        mime.numbertimesanswered = [NSNumber numberWithInteger:(numTimesAnswered + 1)];
        
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
    
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meViewMimeViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    Request* request = [progressView.requests objectAtIndex:0];
    //now we have the request
    
    NSArray* changedAttributes = request.changedAttributesList;
    //list of all changed attributes
    
    if ([changedAttributes containsObject:NUMBERTIMESANSWERED]) {
        if (progressView.didSucceed) {
            // Answer sent sucessfully
            LOG_REQUEST(0, @"%@ Mime and MimeAnswer creation request was successful", activityName);
            
            // Remove the Answer view and back button
            [self.v_answerView removeFromSuperview];
            [self.btn_back removeFromSuperview];
            
            // Add the Confirmation view
            [self.view addSubview:self.v_confirmationView];
            
            [self showConfirmationView];
        }
        else {
            // Send answer failed
            LOG_REQUEST(1, @"%@ Mime and MimeAnswer creation request failure", activityName);
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        if (progressView.didSucceed) {
            // Send updated Mime count data sucessfully
            LOG_REQUEST(0, @"%@ Mime attempt count update request was successful", activityName);
        }
        else {
            // Send updated Mime count data failed
            LOG_REQUEST(1, @"%@ Mime attempt count update request failure", activityName);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meShareMimeViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([mimeID isEqualToNumber:self.mimeID]) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            
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
    }
    else {
        self.iv_photo.contentMode = UIViewContentModeCenter;
        self.iv_photo.backgroundColor = [UIColor lightGrayColor];
        self.iv_photo.image = [UIImage imageNamed:@"logo-MimeMe.png"];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
    
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
