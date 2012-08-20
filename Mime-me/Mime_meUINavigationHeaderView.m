//
//  Mime_meUINavigationHeaderView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUINavigationHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meCreateMimeViewController.h"
#import "Mime_meGuessMenuViewController.h"
#import "Mime_meScrapbookMenuViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Feed.h"
#import "FeedTypes.h"

@implementation Mime_meUINavigationHeaderView
@synthesize view                = m_view;
@synthesize btn_back            = m_btn_back;
@synthesize btn_home            = m_btn_home;
@synthesize btn_settings        = m_btn_settings;
@synthesize btn_mime            = m_btn_mime;
@synthesize btn_guess           = m_btn_guess;
@synthesize btn_scrapbook       = m_btn_scrapbook;
@synthesize btn_gemCount        = m_btn_gemCount;
@synthesize lbl_mimeNotification        = m_lbl_mimeNotification;
@synthesize lbl_guessNotification       = m_lbl_guessNotification;
@synthesize lbl_scrapbookNotification   = m_lbl_scrapbookNotification;


#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<Mime_meUINavigationHeaderViewDelgate>)del
{
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"Mime_meUINavigationHeaderView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load Mime_meUINavigationHeaderView file.\n");
        }
        
        [self addSubview:self.view];
        
        // Set background pattern
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_header.png"]]];
        
        // Add rounded corners to navigation header
        [self.view.layer setCornerRadius:8.0f];
        [self.view.layer setMasksToBounds:YES];
        
        // Add drop shadow to navigation header
        [self.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.view.layer setShadowOpacity:0.7f];
        [self.view.layer setShadowRadius:2.0f];
        [self.view.layer setShadowOffset:CGSizeMake(0.0f, 3.0f)];
        [self.view.layer setMasksToBounds:NO];
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
        [self.view.layer setShadowPath:shadowPath];
        
        // Setup Gem Count button, disable it for now
        [self.btn_gemCount setEnabled:NO];
        
        // Add rounded corners to notification labels header
        [self.lbl_mimeNotification.layer setCornerRadius:8.0f];
        [self.lbl_mimeNotification.layer setMasksToBounds:YES];
        [self.lbl_mimeNotification.layer setBorderWidth:1.0f];
        [self.lbl_mimeNotification.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.lbl_mimeNotification setHidden:YES];
        
        [self.lbl_guessNotification.layer setCornerRadius:8.0f];
        [self.lbl_guessNotification.layer setMasksToBounds:YES];
        [self.lbl_guessNotification.layer setMasksToBounds:YES];
        [self.lbl_guessNotification.layer setBorderWidth:1.0f];
        [self.lbl_guessNotification.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.lbl_guessNotification setHidden:YES];
        
        [self.lbl_scrapbookNotification.layer setCornerRadius:8.0f];
        [self.lbl_scrapbookNotification.layer setMasksToBounds:YES];
        [self.lbl_scrapbookNotification.layer setMasksToBounds:YES];
        [self.lbl_scrapbookNotification.layer setBorderWidth:1.0f];
        [self.lbl_scrapbookNotification.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.lbl_scrapbookNotification setHidden:YES];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    self.view = nil;
    self.btn_back = nil;
    self.btn_home = nil;
    self.btn_settings = nil;
    self.btn_mime = nil;
    self.btn_guess = nil;
    self.btn_scrapbook = nil;
    self.btn_gemCount = nil;
    self.lbl_mimeNotification = nil;
    self.lbl_guessNotification = nil;
    self.lbl_scrapbookNotification = nil;
    
    [super dealloc];
}

#pragma mark - Notification Handlers
- (void) updateNotifications {
    UIFont* notificationsFont = [UIFont boldSystemFontOfSize:14.0f];
    
    int numNewMimesRecieved = [Feed unopenedNotificationsForFeedEvent:kMIME_RECEIVED];
    int numNewCommentsRecieved = [Feed unopenedNotificationsForFeedEvent:kCOMMENT_RECEIVED];
    int numNewAnswersRecieved = [Feed unopenedNotificationsForFeedEvent:kANSWER_RECEIVED];
    
    if (numNewMimesRecieved > 0) {
        // Move the points banner to fully wrap the number of points label
        NSString *numNewMimesStr = [NSString stringWithFormat:@"%d",numNewMimesRecieved];
        CGSize notificationLabelSize = [numNewMimesStr sizeWithFont:notificationsFont constrainedToSize:CGSizeMake(50, 20) lineBreakMode:UILineBreakModeTailTruncation];
        
        if (notificationLabelSize.width > 20.0f) {
            float deltaX = self.lbl_guessNotification.frame.origin.x + 20.0f - notificationLabelSize.width;
            self.lbl_guessNotification.frame = CGRectMake(self.lbl_guessNotification.frame.origin.x - deltaX,
                                                          self.lbl_guessNotification.frame.origin.y,
                                                          notificationLabelSize.width,
                                                          self.lbl_guessNotification.frame.size.height);
        }
        
        [self.lbl_guessNotification setText:[NSString stringWithFormat:@"%d",numNewMimesRecieved]];
        [self.lbl_guessNotification setHidden:NO];
    }
    else {
        [self.lbl_guessNotification setHidden:YES];
        [self.lbl_guessNotification setText:[NSString stringWithFormat:@"!"]];
    }
    
    if (numNewCommentsRecieved > 0 || numNewAnswersRecieved > 0) {
        int totalScrapbookNotifications = numNewCommentsRecieved + numNewAnswersRecieved;
        [self.lbl_scrapbookNotification setText:[NSString stringWithFormat:@"%d",totalScrapbookNotifications]];
        [self.lbl_scrapbookNotification setHidden:NO];
    }
    else {
        [self.lbl_scrapbookNotification setHidden:YES];
        [self.lbl_scrapbookNotification setText:[NSString stringWithFormat:@"!"]];
    }
}

#pragma mark - UIButton Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    UIViewController *parentViewController = (UIViewController *)self.delegate;
    
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:parentViewController.navigationController.view cache:YES];
                     }];
    [parentViewController.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
    
//    [self.delegate onHomeButtonPressed:sender];
}

- (IBAction) onMimeButtonPressed:(id)sender {
    UIViewController *parentViewController = (UIViewController *)self.delegate;
    
    Mime_meCreateMimeViewController *mimeViewController = [Mime_meCreateMimeViewController createInstance];
    
    [parentViewController.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:NO];
    
//    [self.delegate onMimeButtonPressed:sender];
}

- (IBAction) onGuessButtonPressed:(id)sender {
    UIViewController *parentViewController = (UIViewController *)self.delegate;
    
    Mime_meGuessMenuViewController *guessMenuViewController = [Mime_meGuessMenuViewController createInstance];
    
    [parentViewController.navigationController setViewControllers:[NSArray arrayWithObject:guessMenuViewController] animated:NO];
    
//    [self.delegate onGuessButtonPressed:sender];
}

- (IBAction) onScrapbookButtonPressed:(id)sender {
    UIViewController *parentViewController = (UIViewController *)self.delegate;
    
    Mime_meScrapbookMenuViewController *scrapbookMenuViewController = [Mime_meScrapbookMenuViewController createInstance];
    
    [parentViewController.navigationController setViewControllers:[NSArray arrayWithObject:scrapbookMenuViewController] animated:NO];
    
//    [self.delegate onScrapbookButtonPressed:sender];
}

- (IBAction) onSettingsButtonPressed:(id)sender {
    UIViewController *parentViewController = (UIViewController *)self.delegate;
    
    Mime_meSettingsViewController *settingsViewController = [Mime_meSettingsViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:parentViewController.navigationController.view cache:YES];
                     }];
    
    [parentViewController.navigationController pushViewController:settingsViewController animated:NO];
    
//    [self.delegate onSettingsButtonPressed:sender];
}

- (IBAction) onBackButtonPressed:(id)sender {
    UIViewController *parentViewController = (UIViewController *)self.delegate;
    
    [parentViewController.navigationController popViewControllerAnimated:YES];
    
//    [self.delegate onBackButtonPressed:sender];
}

#pragma mark - Statics
+ (CGRect)frameForNavigationHeader {
    return CGRectMake(0, 0, 320, 125);
}

@end
