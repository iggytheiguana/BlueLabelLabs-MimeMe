//
//  Mime_meUIAnswerView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUIAnswerView.h"
#import <QuartzCore/QuartzCore.h>

#define kMAXWORDLENGTH 20
#define kALLOWEDCHARACTERSET @"abcdefghijklmnopqrstuvwxyz0123456789 "

#define kANSWERVIEWHEIGHT 84.0
#define kANSWERVIEWHIDDEN 50.0

#define kKEYBOARDHEIGHTPORTRAIT 216.0
#define kKEYBOARDHEIGHTLANDSCAPE 162.0

@implementation Mime_meUIAnswerView
@synthesize view                = m_view;
@synthesize v_answerHeader      = m_v_answerHeader;
@synthesize lbl_title           = m_lbl_title;
@synthesize btn_slide           = m_btn_slide;
@synthesize btn_clue            = m_btn_clue;
@synthesize tf_answer           = m_tf_answer;
@synthesize v_wrongAnswer       = m_v_wrongAnswer;
@synthesize word                = m_word;
@synthesize isViewHidden            = m_isViewHidden;

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
        self.transform = CGAffineTransformMakeTranslation(0.0, kANSWERVIEWHEIGHT);     // move the view off the screen first
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
        // Add a view to highlight a wrong answer
        self.v_wrongAnswer = [[UIView alloc] initWithFrame:self.tf_answer.frame];
        self.v_wrongAnswer.layer.cornerRadius = 6.0f;
        self.v_wrongAnswer.layer.masksToBounds = YES;
        self.v_wrongAnswer.backgroundColor = [UIColor redColor];
        self.v_wrongAnswer.alpha = 0.0;
        self.v_wrongAnswer.userInteractionEnabled = NO;
        self.v_wrongAnswer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.v_wrongAnswer.hidden = YES;
        [self.view addSubview:self.v_wrongAnswer];
        
        // Setup notification for device orientation change
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate)
                                                     name:@"UIDeviceOrientationDidChangeNotification" object:nil];
        
        [self addSubview:self.view];
        
    }
    
    return self;
    
}

- (void)dealloc {
    self.view = nil;
    self.v_answerHeader = nil;
    self.lbl_title = nil;
    self.btn_slide = nil;
    self.btn_clue = nil;
    self.tf_answer = nil;
    self.v_wrongAnswer = nil;
    
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

#pragma mark - Landscape Photo Rotation Event Handler
- (void) didRotate {
    if ([self.tf_answer isFirstResponder] == YES) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        
        CGFloat deltaY = kKEYBOARDHEIGHTPORTRAIT - kKEYBOARDHEIGHTLANDSCAPE;
        if ((orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) && deviceOrientation != UIDeviceOrientationPortraitUpsideDown) {
            if (self.center.y != (320 - kKEYBOARDHEIGHTLANDSCAPE - self.frame.size.height/2 + 8.0)) {
                // Only move the center point if it is not already in position
                self.center = CGPointMake(self.center.x, self.center.y + deltaY);
            }
        }
        else if (orientation == UIInterfaceOrientationPortrait && deviceOrientation != UIDeviceOrientationPortraitUpsideDown) {
            if (self.center.y != (480 - kKEYBOARDHEIGHTPORTRAIT - self.frame.size.height/2 + 8.0)) {
                // Only move the center point if it is not already in position
                self.center = CGPointMake(self.center.x, self.center.y - deltaY);
            }
        }
    }
}

#pragma mark - Helper Methods
- (float)deltaYForKeyboard {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        return kKEYBOARDHEIGHTLANDSCAPE;
    }
    else {
        return kKEYBOARDHEIGHTPORTRAIT;
    }
}

#pragma mark - UIButton Handlers
- (IBAction) onSlideButtonPressed:(id)sender {
    CGFloat deltaY = 0.0;
    
    if ([self.tf_answer isFirstResponder] == YES) {
        [self.tf_answer resignFirstResponder];
        
        // Slide the answer view down after the keyboard hides
        deltaY = [self deltaYForKeyboard];
    }
    else if (self.isViewHidden == YES) {
        self.isViewHidden = NO;
        // Slide the answer view back up
        deltaY = -kANSWERVIEWHIDDEN;
    }
    else {
        self.isViewHidden = YES;
        // Slide the answer view to the hidden position
        deltaY = kANSWERVIEWHIDDEN;
    }
    
    // Slide the answer view down
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.center = CGPointMake(self.center.x, self.center.y + deltaY);
                     }
                     completion:^(BOOL finished){
                         if (self.isViewHidden == YES) {
                             self.btn_slide.imageView.image = [UIImage imageNamed:@"icon-slideUp.png"];
                         }
                         else {
                             self.btn_slide.imageView.image = [UIImage imageNamed:@"icon-slideDown.png"];
                         }
                     }
     ];
    
    [self.delegate onSlideButtonPressed:sender];
}

- (IBAction) onClueButtonPressed:(id)sender {
    [self.delegate onClueButtonPressed:sender];
}

#pragma mark - TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Hide the error view if it is visible
    if (self.v_wrongAnswer.hidden == NO) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.v_wrongAnswer.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             self.v_wrongAnswer.hidden = YES;
                         }
         ];
    }
    
    // Slide the answer view up
    CGFloat deltaY = [self deltaYForKeyboard];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.center = CGPointMake(self.center.x, self.center.y - deltaY);
                     }
                     completion:^(BOOL finished){
                         self.btn_slide.imageView.image = [UIImage imageNamed:@"icon-slideDown.png"];
                     }
     ];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    // textfield editing has ended
//    
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {    
    // Prevent numbers, spaces, special characters and capitals in the word and limit to 15 letters
    
//    if ([text rangeOfCharacterFromSet:[[NSCharacterSet lowercaseLetterCharacterSet] invertedSet]].location != NSNotFound) {
//        // only lower case letters allowed
//        return NO;
//    }
    if (([kALLOWEDCHARACTERSET rangeOfString:text].location == NSNotFound) && (range.length != 1)) {
        // only lower case letters and numbers allowed allowed
        return NO;
    }
    else if (([textField.text length] >= kMAXWORDLENGTH) && (range.length != 1)) {
        return NO;
    }
    
    // Hide the error view if it is visible
    if (self.v_wrongAnswer.hidden == NO) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.v_wrongAnswer.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             self.v_wrongAnswer.hidden = YES;
                         }
         ];
    }
    
    return YES;
}

// Handles keyboard Return button pressed while editing the textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.word isEqualToString:self.tf_answer.text]) {
        // User submitted the correct answer
        
        [self.delegate onSubmittedCorrectAnswer:YES];
        
        CGFloat deltaY = 0.0;
        
        if ([self.tf_answer isFirstResponder] == YES) {
            [self.tf_answer resignFirstResponder];
            
            deltaY = [self deltaYForKeyboard];
        }
        else {
            deltaY = kANSWERVIEWHIDDEN;
        }
        
        // Slide the answer view down
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.center = CGPointMake(self.center.x, self.center.y + deltaY);
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    }
    else {
        // User submitted an incorrect answer
        
        [self.delegate onSubmittedCorrectAnswer:NO];
        
        // Hide the error view if it is visible
        if (self.v_wrongAnswer.hidden == YES) {
            self.v_wrongAnswer.alpha = 0.0;
            self.v_wrongAnswer.hidden = NO;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^{
                                 self.v_wrongAnswer.alpha = 0.3;
                             }
                             completion:^(BOOL finished){
                                 self.v_wrongAnswer.hidden = NO;
                             }
             ];
        }
    }
    
    return NO;
}

#pragma mark - Statics
+ (Mime_meUIAnswerView*)createInstanceWithFrame:(CGRect)frame withTitle:(NSString *)title withWord:(NSString *)word {
    Mime_meUIAnswerView* instance = [[Mime_meUIAnswerView alloc]initWithFrame:(CGRect)frame];
    [instance autorelease];
    
    // Set the title and answer
    instance.lbl_title.text = title;
    instance.word = word;
    
    return instance;
}

+ (CGRect)frameForAnswerView {
    // The view will start off the screen and move up into view when loaded
    return CGRectMake(10, 396, 300, 92);
}

@end
