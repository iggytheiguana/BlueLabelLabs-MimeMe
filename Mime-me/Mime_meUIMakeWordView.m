//
//  Mime_meUIMakeWordView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/10/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUIMakeWordView.h"
#import <QuartzCore/QuartzCore.h>

#define kMAXWORDLENGTH 15

@implementation Mime_meUIMakeWordView
@synthesize view                = m_view;
@synthesize v_makeWordContainer = m_v_makeWordContainer;
@synthesize v_makeWordHeader    = m_v_makeWordHeader;
@synthesize v_background        = m_v_background;
@synthesize tf_newWord          = m_tf_newWord;
@synthesize btn_ok              = m_btn_ok;
@synthesize btn_close           = m_btn_close;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<Mime_meUIMakeWordViewDelgate>)del
{
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"Mime_meUIMakeWordView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load Mime_meUIMakeWordView file.\n");
        }
        
        // Add drop shadow to container view
        [self.v_makeWordContainer.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.v_makeWordContainer.layer setShadowOpacity:0.7f];
        [self.v_makeWordContainer.layer setShadowRadius:5.0f];
        [self.v_makeWordContainer.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
        [self.v_makeWordContainer.layer setMasksToBounds:NO];
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.v_makeWordContainer.layer.bounds].CGPath;
        [self.v_makeWordContainer.layer setShadowPath:shadowPath];
        
        // Add rounded corners to container view
        [self.v_makeWordContainer.layer setCornerRadius:8.0f];
        [self.v_makeWordContainer.layer setOpaque:NO];
        
        // Add rounded corners to top part of header view
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.v_makeWordHeader.bounds 
                                                       byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                             cornerRadii:CGSizeMake(8.0, 8.0)];
        
        // Create the shape layer and set its path
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.v_makeWordHeader.bounds;
        maskLayer.path = maskPath.CGPath;
        
        // Set the newly created shape layer as the mask for the view's layer
        self.v_makeWordHeader.layer.mask = maskLayer;
        
        // Animate the showing of the make word container views
        self.v_makeWordContainer.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.v_background.alpha = 0.0;
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.v_makeWordContainer.transform = CGAffineTransformMakeScale(1.05, 1.05);
                             self.v_makeWordContainer.alpha = 0.8;
                             
                             self.v_background.alpha = 0.5;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:1/15.0
                                              animations:^{
                                                  self.v_makeWordContainer.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                                  self.v_makeWordContainer.alpha = 0.9;
                                              }
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:1/7.5
                                                                   animations:^{
                                                                       self.v_makeWordContainer.transform = CGAffineTransformIdentity;                                                             
                                                                       self.v_makeWordContainer.alpha = 1.0;
                                                                   }
                                                   ];
                                              }
                              ];
                         }
         ];
        
        // Show keyboard ready for text entry
        [self.tf_newWord becomeFirstResponder];
        
        [self addSubview:self.view];

    }
    return self;
}

- (void)dealloc {
    self.view = nil;
    self.v_makeWordContainer = nil;
    self.v_makeWordHeader = nil;
    self.v_background = nil;
    self.tf_newWord = nil;
    self.btn_ok = nil;
    self.btn_close = nil;
    
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
- (IBAction) onOkButtonPressed:(id)sender {
    
    NSString *newWordStr = self.tf_newWord.text;
    
    // Check to see that the newWord is not empty and does not contain any whitespace
    if (newWordStr == nil ||
        [newWordStr isEqualToString:@""] ||
        [newWordStr isEqualToString:@" "] ||
        [newWordStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
        
        // there is no word or whitespace present
        self.tf_newWord.placeholder = @"please enter a word";
    }
    else {
        [self.tf_newWord resignFirstResponder];
        [self.delegate onOkButtonPressed:sender];
    }
}

- (IBAction) onCloseButtonPressed:(id)sender {
    // Animate the hiding of the view
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

#pragma mark - TextField Delegate Methods
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    // textfield editing has begun
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    // textfield editing has ended
//    
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {    
    // Prevent numbers, spaces, special characters and capitals in the word and limit to 15 letters
    
    if ([text rangeOfCharacterFromSet:[[NSCharacterSet lowercaseLetterCharacterSet] invertedSet]].location != NSNotFound) {
        // only lower case letters allowed
        return NO;
    }
    else if ([textField.text length] >= kMAXWORDLENGTH) {
        return NO;
    }
    
    self.tf_newWord.placeholder = @" ";
    
    return YES;
}

// Handles keyboard Return button pressed while editing the textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onOkButtonPressed:(id)textField];
    return NO;
}

#pragma mark - Statics
+ (CGRect)frameForMakeWordView {
    return CGRectMake(0, 0, 320, 480);
}

@end
