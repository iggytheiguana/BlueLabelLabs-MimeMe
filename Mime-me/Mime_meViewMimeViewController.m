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
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "ViewMimeCase.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Create gesture recognizer for the photo image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showContainer)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_photo addGestureRecognizer:oneFingerTap];
    
    //enable gesture events on the photo
    [self.iv_photo setUserInteractionEnabled:YES];
    
    // Hide the background view and back button until we need them
    self.v_background.hidden = YES;
    self.btn_back.hidden = YES;
    
    // Setup notification for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
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
            
            [self.view setNeedsDisplay];
        }
        else {
            self.iv_photo.contentMode = UIViewContentModeCenter;
            self.iv_photo.backgroundColor = [UIColor lightGrayColor];
            self.iv_photo.image = [UIImage imageNamed:@"logo-MimeMe.png"];
        }
    }
    
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
    
    switch (self.viewMimeCase) {
        case kSENTMIME:
            self.v_confirmationView = [Mime_meUIConfirmationView createInstanceWithFrame:[Mime_meUIConfirmationView frameForConfirmationView] withTitle:@"Mime sent" withSubtitle:@"You earned 5 gems!"];
            self.v_confirmationView.delegate = self;
            self.v_confirmationView.hidden = YES;
            self.v_confirmationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:self.v_confirmationView];
            
            break;
            
        case kANSWERMIME:
            self.v_answerView = [[Mime_meUIAnswerView alloc] initWithFrame:[Mime_meUIAnswerView frameForAnswerView]];
            self.v_answerView.delegate = self;
            [self.view addSubview:self.v_answerView];
            break;
            
        case kSCRAPBOOKMIME:
            self.v_answerView = [[Mime_meUIAnswerView alloc] initWithFrame:[Mime_meUIAnswerView frameForAnswerView]];
            self.v_answerView.delegate = self;
            [self.view addSubview:self.v_answerView];
            break;
            
        default:
            break;
    }
    
    [self showContainer];
    
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
////        self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
//        
//        [self.iv_photo setUserInteractionEnabled:NO];
//        [self onCloseButtonPressed:nil];
//    }
//    else {
////        if (self.imageSize.height > self.imageSize.width) {
////            self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
////        }
////        else {
////            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
////        }
//        
//        [self.iv_photo setUserInteractionEnabled:YES];
//        
//        if (self.v_confirmationView.hidden == YES) {
//            // sentContainer not already visible, show it
//            [self showContainer];
//        }
//        
//    }
//    [self showContainer];
}

#pragma mark - UI Event Handlers
- (void)showContainer {
    [self.v_confirmationView show];
    
    [self.view bringSubviewToFront:self.iv_logo];
    [self.view bringSubviewToFront:self.btn_back];
}

#pragma mark Mime_meUIConfirmationView Delegate Methods
- (IBAction) onCloseButtonPressed:(id)sender {
    
}

- (IBAction) onOkButtonPressed:(id)sender {
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                     }];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
}

#pragma mark Mime_meUIAnswerView Delegate Methods
- (IBAction) onDismissButtonPressed:(id)sender {
    
}

- (IBAction) onClueButtonPressed:(id)sender {
    
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
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            
            self.imageSize = response.image.size;
            
            if (self.imageSize.height > self.imageSize.width) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFill;
            }
            else {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            }
            
            [self.view setNeedsDisplay];
        }
    }
    else {
        self.iv_photo.contentMode = UIViewContentModeCenter;
        self.iv_photo.backgroundColor = [UIColor blackColor];
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
