//
//  Mime_meUIAnswerView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUIAnswerView.h"
#import <QuartzCore/QuartzCore.h>

#define kMAXWORDLENGTH 15
#define kANSWERVIEWHEIGHT 84.0
#define kANSWERVIEWDISMISSED 50.0
#define kKEYBOARDHEIGHTPORTRAIT 216.0
#define kKEYBOARDHEIGHTLANDSCAPE 162.0

@implementation Mime_meUIAnswerView
@synthesize view                = m_view;
@synthesize v_answerHeader      = m_v_answerHeader;
@synthesize lbl_from            = m_lbl_from;
@synthesize btn_dismiss         = m_btn_dismiss;
@synthesize btn_clue            = m_btn_clue;
@synthesize tf_answer           = m_tf_answer;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<Mime_meUIAnswerViewDelgate>)del
{
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"Mime_meUIAnswerView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load Mime_meUIAnswerView file.\n");
        }
        
        // Add drop shadow to container view
        [self.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.view.layer setShadowOpacity:0.7f];
        [self.view.layer setShadowRadius:5.0f];
        [self.view.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
        [self.view.layer setMasksToBounds:NO];
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
        [self.view.layer setShadowPath:shadowPath];
        
        // Add rounded corners to container view
        [self.view.layer setCornerRadius:8.0f];
        [self.view.layer setOpaque:NO];
        
        // Add rounded corners to top part of header view
        UIBezierPath *maskPathHeader = [UIBezierPath bezierPathWithRoundedRect:self.v_answerHeader.bounds 
                                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                                         cornerRadii:CGSizeMake(8.0, 8.0)];
        // Create the shape layer and set its path
        CAShapeLayer *maskLayerHeader = [CAShapeLayer layer];
        maskLayerHeader.frame = self.v_answerHeader.bounds;
        maskLayerHeader.path = maskPathHeader.CGPath;
        // Set the newly created shape layer as the mask for the view's layer
        self.v_answerHeader.layer.mask = maskLayerHeader;
        [self.v_answerHeader.layer setOpaque:NO];
        
        // Animate the showing of the answer view
        self.view.transform = CGAffineTransformMakeTranslation(0.0, kANSWERVIEWHEIGHT);     // move the view off the screen first
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
        [self addSubview:self.view];
        
    }
    
    return self;
    
}

- (void)dealloc {
    self.view = nil;
    self.v_answerHeader = nil;
    self.lbl_from = nil;
    self.btn_dismiss = nil;
    self.btn_clue = nil;
    self.tf_answer = nil;
    
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

#pragma mark - UIButton Handlers
- (IBAction) onDismissButtonPressed:(id)sender {
    CGFloat deltaY = 0.0;
    
    if ([self.tf_answer isFirstResponder] == YES) {
        [self.tf_answer resignFirstResponder];
        deltaY = kKEYBOARDHEIGHTPORTRAIT;
    }
    else {
        deltaY = kANSWERVIEWDISMISSED;
    }
    
    // Slide the answer view down
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.view.center = CGPointMake(self.view.center.x, self.view.center.y+deltaY);
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
    [self.delegate onDismissButtonPressed:sender];
}

- (IBAction) onClueButtonPressed:(id)sender {
    [self.delegate onClueButtonPressed:sender];
}

#pragma mark - TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textfield editing has begun
    
    // Slide the answer view up
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.view.center = CGPointMake(self.view.center.x, self.view.center.y-kKEYBOARDHEIGHTPORTRAIT);
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // textfield editing has ended
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {    
    // Prevent numbers, spaces, special characters and capitals in the word and limit to 15 letters
    
    if ([text rangeOfCharacterFromSet:[[NSCharacterSet lowercaseLetterCharacterSet] invertedSet]].location != NSNotFound) {
        // only lower case letters allowed
        return NO;
    }
    else if ([textField.text length] >= kMAXWORDLENGTH) {
        return NO;
    }
    
    return YES;
}

// Handles keyboard Return button pressed while editing the textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

#pragma mark - Statics
+ (CGRect)frameForAnswerView {
    // The view will start off the screen and move up into view when loaded
    return CGRectMake(10, 396, 300, 92);
}

@end
