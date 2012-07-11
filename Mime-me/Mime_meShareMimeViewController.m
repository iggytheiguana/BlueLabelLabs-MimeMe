//
//  Mime_meShareMimeViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meShareMimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime.h"
#import "ImageManager.h"

@interface Mime_meShareMimeViewController ()

@end

@implementation Mime_meShareMimeViewController
@synthesize iv_image            = m_iv_image;
@synthesize v_sentContainer     = m_v_sentContainer;
@synthesize v_sentHeader        = m_v_sentHeader;
@synthesize v_background        = m_v_background;
@synthesize btn_close           = m_btn_close;
@synthesize btn_ok              = m_btn_ok;
@synthesize btn_facebook        = m_btn_facebook;
@synthesize btn_twitter         = m_btn_twitter;
@synthesize btn_email           = m_btn_email;
@synthesize btn_scrapbook       = m_btn_scrapbook;
@synthesize mimeID              = m_mimeID;

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
    
    // Add drop shadow to container view
    [self.v_sentContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.v_sentContainer.layer setShadowOpacity:0.7f];
    [self.v_sentContainer.layer setShadowRadius:5.0f];
    [self.v_sentContainer.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [self.v_sentContainer.layer setMasksToBounds:NO];
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.v_sentContainer.layer.bounds].CGPath;
    [self.v_sentContainer.layer setShadowPath:shadowPath];
    
    // Add rounded corners to container view
    [self.v_sentContainer.layer setCornerRadius:8.0f];
    [self.v_sentContainer.layer setOpaque:NO];
    
    // Add rounded corners to top part of header view
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.v_sentHeader.bounds 
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(8.0, 8.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.v_sentHeader.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.v_sentHeader.layer.mask = maskLayer;
    
    // Add rounded corners to share and scrapbook buttons
    [self.btn_facebook.layer setCornerRadius:3.0f];
    [self.btn_facebook.layer setOpaque:NO];
    [self.btn_facebook.layer setMasksToBounds:YES];
    [self.btn_twitter.layer setCornerRadius:3.0f];
    [self.btn_twitter.layer setOpaque:NO];
    [self.btn_twitter.layer setMasksToBounds:YES];
    [self.btn_email.layer setCornerRadius:3.0f];
    [self.btn_email.layer setOpaque:NO];
    [self.btn_email.layer setMasksToBounds:YES];
    [self.btn_scrapbook.layer setCornerRadius:3.0f];
    [self.btn_scrapbook.layer setOpaque:NO];
    [self.btn_scrapbook.layer setMasksToBounds:YES];
    
    // Create gesture recognizer for the photo image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSentContainer)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_image addGestureRecognizer:oneFingerTap];
    
    //enable gesture events on the photo
    [self.iv_image setUserInteractionEnabled:YES];
    
    // Hide the sent container views so we can animate the showing of them
    self.v_sentContainer.hidden = YES;
    self.v_background.hidden = YES;
    
//    // Set the Mime image on the image view
//    ResourceContext* resourceContext = [ResourceContext instance];
//    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
//    
//    ImageManager* imageManager = [ImageManager instance];
//    UIImage* image = [imageManager downloadImage:mime.imageurl withUserInfo:nil atCallback:nil];
//    [self.iv_image setImage:image];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.iv_image = nil;
    self.v_sentContainer = nil;
    self.v_sentHeader = nil;
    self.v_background = nil;
    self.btn_close = nil;
    self.btn_ok = nil;
    self.btn_facebook = nil;
    self.btn_twitter = nil;
    self.btn_email = nil;
    self.btn_scrapbook = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Animate the showing of the sent container views
    [self showSentContainer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIButton Handlers
- (void)showSentContainer {
    // Animate the showing of the sent container views
    if (self.v_sentContainer.hidden == YES) { // swoop in if coming from hidden, otherwise pulse in-place
        self.v_sentContainer.transform = CGAffineTransformMakeScale(0.6, 0.6);
    }
    self.v_sentContainer.hidden = NO;
    self.v_background.hidden = NO;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.v_sentContainer.transform = CGAffineTransformMakeScale(1.05, 1.05);
                         self.v_sentContainer.alpha = 0.8;
                         
                         self.v_background.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:1/15.0
                                          animations:^{
                                              self.v_sentContainer.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                              self.v_sentContainer.alpha = 0.9;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:1/7.5
                                                               animations:^{
                                                                   self.v_sentContainer.transform = CGAffineTransformIdentity;                                                             
                                                                   self.v_sentContainer.alpha = 1.0;
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}

- (IBAction) onCloseButtonPressed:(id)sender {
    // Hide the sent container view and background to show the full screen image
    for (UIView *checkView in [self.view subviews] ) {
        if ((id)checkView == (id)self.v_sentContainer) {
            // Animate the hiding of the views
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.v_sentContainer.alpha = 0.0;
                                 self.v_background.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 self.v_sentContainer.hidden = YES;
                                 self.v_background.hidden = YES;
                             }];
        }
    }
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


#pragma mark - Static Initializers
+ (Mime_meShareMimeViewController*)createInstanceWithMimeID:(NSNumber *)mimeID {
    Mime_meShareMimeViewController* instance = [[Mime_meShareMimeViewController alloc]initWithNibName:@"Mime_meShareMimeViewController" bundle:nil];
    [instance autorelease];
    instance.mimeID = mimeID;
    return instance;
}

@end
