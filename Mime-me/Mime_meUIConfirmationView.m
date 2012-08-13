//
//  Mime_meUIConfirmationView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUIConfirmationView.h"
#import <QuartzCore/QuartzCore.h>
#import "ResourceContext.h"
#import "Mime.h"

@implementation Mime_meUIConfirmationView
@synthesize view                = m_view;
@synthesize v_background        = m_v_background;
@synthesize v_confirmationView  = m_v_confirmationView;
@synthesize v_sentHeader        = m_v_sentHeader;
@synthesize lbl_title           = m_lbl_title;
@synthesize lbl_subtitle        = m_lbl_subtitle;
@synthesize btn_close           = m_btn_close;
@synthesize btn_ok              = m_btn_ok;
@synthesize btn_facebook        = m_btn_facebook;
@synthesize btn_twitter         = m_btn_twitter;
@synthesize btn_email           = m_btn_email;
@synthesize btn_favorite        = m_btn_favorite;
@synthesize mimeID              = m_mimeID;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<Mime_meUIConfirmationViewDelgate>)del
{
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"Mime_meUIConfirmationView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load Mime_meUIConfirmationView file.\n");
        }
        
        // Add drop shadow to container view
        [self.v_confirmationView.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.v_confirmationView.layer setShadowOpacity:0.7f];
        [self.v_confirmationView.layer setShadowRadius:5.0f];
        [self.v_confirmationView.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
        [self.v_confirmationView.layer setMasksToBounds:NO];
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.v_confirmationView.layer.bounds].CGPath;
        [self.v_confirmationView.layer setShadowPath:shadowPath];
        
        // Add rounded corners to container view
        [self.v_confirmationView.layer setCornerRadius:8.0f];
        [self.v_confirmationView.layer setOpaque:NO];
        
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
        [self.v_sentHeader.layer setOpaque:NO];
        
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
        [self.btn_favorite.layer setCornerRadius:3.0f];
        [self.btn_favorite.layer setOpaque:NO];
        [self.btn_favorite.layer setMasksToBounds:YES];
        
        [self addSubview:self.view];
        
        
        [self.btn_favorite setImage:[UIImage imageNamed:@"icon-favorite-yellow.png"] forState:UIControlStateDisabled];
        
    }
    
    return self;
    
}

- (void)dealloc {
    self.view = nil;
    self.v_background = nil;
    self.v_confirmationView = nil;
    self.v_sentHeader = nil;
    self.lbl_title = nil;
    self.lbl_subtitle = nil;
    self.btn_close = nil;
    self.btn_ok = nil;
    self.btn_facebook = nil;
    self.btn_twitter = nil;
    self.btn_email = nil;
    self.btn_favorite = nil;
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)show {
    // Animate the showing of the sent container view
    if (self.v_confirmationView.hidden == YES) { // swoop in if coming from hidden, otherwise pulse in-place
        self.v_confirmationView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    }
    self.v_confirmationView.hidden = NO;
    self.v_background.hidden = NO;
    self.hidden = NO;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.v_confirmationView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                         self.v_confirmationView.alpha = 0.8;
                         
                         self.v_background.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:1/15.0
                                          animations:^{
                                              self.v_confirmationView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                              self.v_confirmationView.alpha = 0.9;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:1/7.5
                                                               animations:^{
                                                                   self.v_confirmationView.transform = CGAffineTransformIdentity;                                                             
                                                                   self.v_confirmationView.alpha = 1.0;
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}

#pragma mark - UIButton Handlers
- (IBAction) onCloseButtonPressed:(id)sender {
    // Hide the confirmation container view and background to show the full screen image
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.v_confirmationView.alpha = 0.0;
                         self.v_background.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.v_confirmationView.hidden = YES;
                         self.v_background.hidden = YES;
                         self.hidden = YES;
                     }];
    
    [self.delegate onCloseButtonPressed:sender];
}

- (IBAction) onOkButtonPressed:(id)sender {
    [self.delegate onOkButtonPressed:sender];
}

- (IBAction) onFavoriteButtonPressed:(id)sender {
    [self.btn_favorite setEnabled:NO];
    
    [self.delegate onFavoriteButtonPressed:sender];
}

- (IBAction) onEmailButtonPressed:(id)sender {
    [self.delegate onEmailButtonPressed:sender];
}

- (IBAction) onFacebookButtonPressed:(id)sender {   
    [self.delegate onFacebookButtonPressed:sender];
}

- (IBAction) onTwitterButtonPressed:(id)sender {
    [self.delegate onTwitterButtonPressed:sender];
}

#pragma mark - Statics
+ (Mime_meUIConfirmationView*)createInstanceWithFrame:(CGRect)frame withTitle:(NSString *)title withSubtitle:(NSString *)subtitle forMimeWithID:(NSNumber *)mimeID {
    Mime_meUIConfirmationView* instance = [[Mime_meUIConfirmationView alloc]initWithFrame:(CGRect)frame];
    [instance autorelease];
    
    // Set the title and subtitle
    instance.lbl_title.text = title;
    instance.lbl_subtitle.text = subtitle;
    instance.mimeID = mimeID;
    
    // Check if favorite
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:instance.mimeID];
    if ([mime.isfavorite boolValue] == YES) {
        [instance.btn_favorite setEnabled:NO];
    }
    
    return instance;
}


+ (CGRect)frameForConfirmationView {
    return CGRectMake(0, 0, 320, 480);
}

@end
