//
//  Mime_meUIAnswerView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUIAnswerView.h"
#import <QuartzCore/QuartzCore.h>
#import <stdlib.h>
#import "ResourceContext.h"
#import "Mime.h"

#define kMAXWORDLENGTH 20
#define kALLOWEDCHARACTERSET @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
#define kUNICHARSPACE 32

#define kANSWERVIEWDEFAULTHEIGHT 84.0
//#define kANSWERVIEWHIDDEN 50.0
#define kHEADERHEIGHT 34.0
#define kFOOTERHEIGHT 8.0

#define kKEYBOARDHEIGHTPORTRAIT 216.0
#define kKEYBOARDHEIGHTLANDSCAPE 162.0

@implementation Mime_meUIAnswerView
@synthesize view                = m_view;
@synthesize v_answerHeader      = m_v_answerHeader;
@synthesize btn_slide           = m_btn_slide;
@synthesize btn_flag            = m_btn_flag;
@synthesize btn_more            = m_btn_more;
@synthesize btn_clue            = m_btn_clue;
@synthesize tf_answer           = m_tf_answer;
//@synthesize v_wrongAnswer       = m_v_wrongAnswer;
@synthesize lbl_notificationsBadge = m_lbl_notificationsBadge;
@synthesize mimeID              = m_mimeID;
@synthesize word                = m_word;
@synthesize isViewHidden        = m_isViewHidden;
@synthesize isKeyboardShown     = m_isKeyboardShown;
@synthesize didGuessCorrectAnswer = m_didGuessCorrectAnswer;
@synthesize revealedIndexes     = m_revealedIndexes;

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
        
        // Animate the showing of the answer view
        self.transform = CGAffineTransformMakeTranslation(0.0, kANSWERVIEWDEFAULTHEIGHT);     // move the view off the screen first
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
//        // Add a view to highlight a wrong answer
//        self.v_wrongAnswer = [[UIView alloc] initWithFrame:self.tf_answer.frame];
//        self.v_wrongAnswer.layer.cornerRadius = 6.0f;
//        self.v_wrongAnswer.layer.masksToBounds = YES;
//        self.v_wrongAnswer.backgroundColor = [UIColor redColor];
//        self.v_wrongAnswer.alpha = 0.0;
//        self.v_wrongAnswer.userInteractionEnabled = NO;
//        self.v_wrongAnswer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.v_wrongAnswer.hidden = YES;
//        [self.view addSubview:self.v_wrongAnswer];
        
        // Set up notification of system events
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        // Setup notification for device orientation change
        [center addObserver:self 
                   selector:@selector(didRotate) 
                       name:UIDeviceOrientationDidChangeNotification
                     object:nil];
        
        // Setup keyboard notifications
        [center addObserver:self 
                   selector:@selector(keyboardDidShow) 
                       name:UIKeyboardDidShowNotification
                     object:nil];
        
        [center addObserver:self 
                   selector:@selector(keyboardDidHide) 
                       name:UIKeyboardDidHideNotification
                     object:nil];
        
        // Initialize the array to hold which letters have been revealed via a clue
        self.revealedIndexes = [[NSMutableArray alloc] init];
        
        // Hide the notification label until it needs to be shown
        [self.lbl_notificationsBadge setHidden:YES];
        
        [self addSubview:self.view];
        
    }
    
    return self;
    
}

- (void) applyViewStyles {
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
}

- (void) renderWordDisplay {
    
    unsigned int x = 0;
    unsigned int deltaY = 36;
    
    unsigned int charSpace = 2;
    unsigned int blankSpace = 12;
    
    unsigned int charWidth = 27;
    unsigned int charHeight = 31;
    
    unsigned int characterIndex = 0;
    unsigned int componentIndex = 0;
    unsigned int rowIndex = 0;
    
    // create container views to hold the textfield boxes for each row of components
    UIView *v_row1 = [[[UIView alloc] init] autorelease];
    UIView *v_row2 = [[[UIView alloc] init] autorelease];
    UIView *v_row3 = [[[UIView alloc] init] autorelease];
    
    for (NSString *component in [self.word componentsSeparatedByString:@" "]) {
        
        unsigned int len = [component length];
        
        // compute amount of space needed for this component of the string
        unsigned int requiredWidth = len * (charWidth + charSpace) - charSpace;
        
        // determine if we need a new line for the next component of the string
        if (componentIndex == 0 && rowIndex == 0) {
            // set the default frame of the first row container
            if ((x + requiredWidth) > 290) {
                // maximize the width to 280, enough to fit 8 characters accross
                v_row1.frame = CGRectMake(0, 44, 280, charHeight);
            }
            else {
                v_row1.frame = CGRectMake(0, 44, requiredWidth, charHeight);
            }
        }
        else if ((x + requiredWidth) > 290) {
            // skip to new line
            ++rowIndex;
            
            // reset x origin
            x = 0;
            
            // set the default frame of the remaining row containers
            if (rowIndex == 1) {
                v_row2.frame = CGRectMake(0, 80, requiredWidth, charHeight);
            }
            else if (rowIndex == 2) {
                v_row3.frame = CGRectMake(0, 116, requiredWidth, charHeight);
            }
            
            // increase height of answer view
            CGRect newFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - deltaY, self.view.frame.size.width, self.view.frame.size.height + deltaY);
            self.view.frame = newFrame;
            
            CGRect containerFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - deltaY, self.frame.size.width, self.frame.size.height + deltaY);
            self.frame = containerFrame;
        }
        else {
            // now add a space
            x = x + blankSpace;
            
            // increase the width of the row container view to accomodate the next component
            if (rowIndex == 0) {
                v_row1.frame = CGRectMake(0, 44, v_row1.frame.size.width + requiredWidth + blankSpace, charHeight);
            }
            else if (rowIndex == 1) {
                v_row2.frame = CGRectMake(0, 80, v_row2.frame.size.width + requiredWidth + blankSpace, charHeight);
            }
            else if (rowIndex == 2) {
                v_row3.frame = CGRectMake(0, 116, v_row3.frame.size.width + requiredWidth + blankSpace, charHeight);
            }
        }
        
        // create the textfields for each character in the component
        unichar *buffer = calloc(len, sizeof(unichar));
        
        [component getCharacters:buffer range:NSMakeRange(0, len)];
        
        for(int i = 0; i < len; ++i) {
            unichar current = buffer[i];
            
            if (current == ' ') {
                x = x + blankSpace;
            }
            else {
                UITextField *tf = [[[UITextField alloc] initWithFrame:CGRectMake(x, 0, charWidth, charHeight)] autorelease];
                tf.delegate = self;
                tf.borderStyle = UITextBorderStyleRoundedRect;
                tf.textAlignment = UITextAlignmentCenter;
                tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                tf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                tf.font = [UIFont boldSystemFontOfSize:14.0];
                tf.textColor = [UIColor blackColor];
                tf.returnKeyType = UIReturnKeyDone;
                tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                tf.text = @" "; // this blank space will help us manage a backspace press on the keyboard
                
                // tag the textfield so we can retrive it later
                // we add 1 to the character index because a view tag cannot be 0
                // adding the component index accounts for spaces in the word/phrase
                tf.tag = (characterIndex + 1) + componentIndex;
                
                //increment the character index
                ++characterIndex;
                
                if (rowIndex == 0) {
                    [v_row1 addSubview:tf];
                }
                else if (rowIndex == 1) {
                    [v_row2 addSubview:tf];
                }
                else if (rowIndex == 2) {
                    [v_row3 addSubview:tf];
                }
                
                // increment x origin for the next character
                x = x + charWidth + charSpace;
                
                if (x > 260 && (len - (i + 1)) > 1) {
                    // add hyphen and move to the next line
                    UILabel *lbl_hyphen = [[[UILabel alloc] initWithFrame:CGRectMake(x, 0, charWidth, charHeight)] autorelease];
                    lbl_hyphen.backgroundColor = [UIColor clearColor];
                    lbl_hyphen.textAlignment = UITextAlignmentCenter;
                    lbl_hyphen.font = [UIFont boldSystemFontOfSize:14.0];
                    lbl_hyphen.text = @"-";
                    
                    if (rowIndex == 0) {
                        [v_row1 addSubview:lbl_hyphen];
                    }
                    else if (rowIndex == 1) {
                        [v_row2 addSubview:lbl_hyphen];
                    }
                    else if (rowIndex == 2) {
                        [v_row3 addSubview:lbl_hyphen];
                    }
                    
                    // skip to new line
                    ++rowIndex;
                    
                    // reset x origin
                    x = 0;
                    
                    // reset the required width to the width for the remaining characters
                    requiredWidth = (len - i - 1) * (charWidth + charSpace);
                    
                    // set the default frame of the remaining row containers
                    if (rowIndex == 1) {
                        v_row2.frame = CGRectMake(0, 80, requiredWidth, charHeight);
                    }
                    else if (rowIndex == 2) {
                        v_row3.frame = CGRectMake(0, 116, requiredWidth, charHeight);
                    }
                    
                    // increase height of answer view
                    CGRect newFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - deltaY, self.view.frame.size.width, self.view.frame.size.height + deltaY);
                    self.view.frame = newFrame;
                    
                    CGRect containerFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - deltaY, self.frame.size.width, self.frame.size.height + deltaY);
                    self.frame = containerFrame;
                }
            }
        }
        
        // increment string component index
        ++componentIndex;
    }
    
    // increase the width of the row container view to accomodate the next component
    if (rowIndex == 2) {
        [self.view addSubview:v_row1];
        v_row1.center = CGPointMake(self.view.center.x, v_row1.center.y);
        [self.view addSubview:v_row2];
        v_row2.center = CGPointMake(self.view.center.x, v_row2.center.y);
        [self.view addSubview:v_row3];
        v_row3.center = CGPointMake(self.view.center.x, v_row3.center.y);
    }
    else if (rowIndex == 1) {
        [self.view addSubview:v_row1];
        v_row1.center = CGPointMake(self.view.center.x, v_row1.center.y);
        [self.view addSubview:v_row2];
        v_row2.center = CGPointMake(self.view.center.x, v_row2.center.y);
    }
    else if (rowIndex == 0) {
        [self.view addSubview:v_row1];
        v_row1.center = CGPointMake(self.view.center.x, v_row1.center.y);
    }
    
    // finish applying the view layout styles
    [self applyViewStyles];
}

- (void)dealloc {
    // unregister for notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.view = nil;
    self.v_answerHeader = nil;
    self.btn_slide = nil;
    self.btn_flag = nil;
    self.btn_more = nil;
    self.btn_clue = nil;
    self.tf_answer = nil;
//    self.v_wrongAnswer = nil;
    self.lbl_notificationsBadge = nil;
    
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

#pragma mark - Keyboard Notification Event Handlers
- (void) keyboardDidShow {
    self.isKeyboardShown = YES;
}

- (void) keyboardDidHide {
    self.isKeyboardShown = NO;
}

#pragma mark - Notification Handlers
- (void)updateNotifications {
    UIFont* notificationsFont = [UIFont boldSystemFontOfSize:14.0f];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:self.mimeID];
    
    // Display label for new answers if there are unseen answers
    int numNewAnswers = [mime numUnopenedMimeAnswers];
    int numNewComments = [mime numUnopenedComments];
    
    int totalNewNotifications = numNewAnswers + numNewComments;
    
    if (totalNewNotifications > 0) {
        // Adjust the size of the notification badge
        NSString *numNewNotificationsStr = [NSString stringWithFormat:@"%d", totalNewNotifications];
        CGSize notificationLabelSize = [numNewNotificationsStr sizeWithFont:notificationsFont constrainedToSize:CGSizeMake(40, 20) lineBreakMode:UILineBreakModeTailTruncation];
        notificationLabelSize.width = notificationLabelSize.width + 11.0f;
        
        if (notificationLabelSize.width > 20.0f) {
//            float deltaX = self.lbl_notificationsBadge.frame.origin.x + 20.0f - notificationLabelSize.width;
            float deltaX = 20.0f + 20.0f - notificationLabelSize.width;
            self.lbl_notificationsBadge.frame = CGRectMake(deltaX,
                                                          self.lbl_notificationsBadge.frame.origin.y,
                                                          notificationLabelSize.width,
                                                          self.lbl_notificationsBadge.frame.size.height);
        }
        
        // Add rounded corners to notification labels header
        [self.lbl_notificationsBadge.layer setCornerRadius:8.0f];
        [self.lbl_notificationsBadge.layer setMasksToBounds:YES];
        [self.lbl_notificationsBadge.layer setMasksToBounds:YES];
        [self.lbl_notificationsBadge.layer setBorderWidth:1.0f];
        [self.lbl_notificationsBadge.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [self.lbl_notificationsBadge setText:[NSString stringWithFormat:@"%d",totalNewNotifications]];
        [self.lbl_notificationsBadge setHidden:NO];
    }
    else {
        [self.lbl_notificationsBadge setHidden:YES];
        [self.lbl_notificationsBadge setText:[NSString stringWithFormat:@"!"]];
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

- (void)shakeAnswerView {
    CGFloat deltaX = 8.0;
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [UIView setAnimationRepeatCount:2];
                         self.center = CGPointMake(self.center.x + deltaX, self.center.y);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseInOut
                                          animations:^{
                                              self.center = CGPointMake(self.center.x - 2*deltaX, self.center.y);
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.1
                                                                    delay:0.0
                                                                  options:UIViewAnimationCurveEaseInOut
                                                               animations:^{
                                                                   self.center = CGPointMake(self.center.x + deltaX, self.center.y);
                                                               }
                                                               completion:^(BOOL finished){
                                                                   
                                                               }];
                                          }];
                     }
     ];
}

- (BOOL)checkForCorrectAnswerInitiatedByUser:(BOOL)userInitiated {
    // Check if each textfield's character matches the character in the answer
    
    BOOL isCorrectAnswer = NO;
    BOOL allTextFieldsPopulated = YES;
    
    /* OLD WAY */
//    for (int i = 1; i <= [self.word length]; i++) {
//        
//        unichar answerChar = [self.word characterAtIndex:(i - 1)];
//        
//        if (answerChar == kUNICHARSPACE) {
//            // Do nothing to account for space in answer
//            NSLog(@"Space in answer phrase");
//        }
//        else {
//            UITextField *tf = (UITextField *)[self.view viewWithTag:i];
//            
//            unichar tfChar = [tf.text characterAtIndex:0];
//            
//            if ([tf.text isEqualToString:@" "]) {
//                isCorrectAnswer = NO;
//                allTextFieldsPopulated = NO;
//                break;
//            }
//            else if (tfChar != answerChar) {
//                isCorrectAnswer = NO;
//            }
//            else {
//                isCorrectAnswer = YES;
//            }
//        }
//    }
    /* END OLD WAY */
    
    /* NEW WAY */
    // Build a string from the answer textfield boxes
    NSString *userAnswerStr = [[NSString alloc] init];
    for (int i = 1; i <= [self.word length]; i++) {
        
        unichar answerChar = [self.word characterAtIndex:(i - 1)];
        
        if (answerChar == kUNICHARSPACE) {
            NSLog(@"Space in answer phrase");
            
            // Add space for space in user answer string
            userAnswerStr = [NSString stringWithFormat:@"%@ ", userAnswerStr];
        }
        else {
            UITextField *tf = (UITextField *)[self.view viewWithTag:i];
            
            if (tf.text == nil || [tf.text isEqualToString:@" "]) {
                // We have an empty box, we can break
                userAnswerStr = [NSString stringWithFormat:@"%@ ", userAnswerStr];
                isCorrectAnswer = NO;
                allTextFieldsPopulated = NO;
                break;
            }
            else {
                // Add letter to user answer string
                userAnswerStr = [NSString stringWithFormat:@"%@%@", userAnswerStr, tf.text];
            }
        }
    }
    
    // Now check to see if the answers match
    if ([self.word isEqualToString:userAnswerStr] == YES) {
        isCorrectAnswer = YES;
        allTextFieldsPopulated = YES;
    }
    /* END NEW WAY */
    
    if (isCorrectAnswer == YES && allTextFieldsPopulated == YES) {
        // User submitted the correct answer
        
        CGFloat deltaY = 0.0;
        
        if (self.isKeyboardShown == YES) {
            [self.tf_answer resignFirstResponder];
            
            deltaY = [self deltaYForKeyboard];
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
    else if (allTextFieldsPopulated == YES || userInitiated == YES) {
        // Animate a horizontal shake of the answer view when an incorrent answer is entered
        [self shakeAnswerView];
    }
    
    return isCorrectAnswer;
    
}

- (void)colorizeAnswerTextFieldAtIndex:(int)index {
    UITextField *tf = (UITextField *)[self.view viewWithTag:index];
    
    tf.opaque = YES;
    tf.backgroundColor=[UIColor lightGrayColor];
    tf.layer.cornerRadius=8.0f;
    tf.layer.masksToBounds=YES;
}

- (void)disableAnswerTextFieldAtIndex:(int)index {
    UITextField *tf = (UITextField *)[self.view viewWithTag:index];
    
    [tf setEnabled:NO];
}

- (void)disableAnswerTextFields {
    for (int i = 1; i <= [self.word length]; i++) {
        
        unichar answerChar = [self.word characterAtIndex:(i - 1)];
        
        if (answerChar == kUNICHARSPACE) {
            // Do nothing to account for space in answer
            NSLog(@"Space in answer phrase");
        }
        else {
            [self disableAnswerTextFieldAtIndex:i];
        }
    }
}

- (void)showLetterAtIndex:(int)index {
    UITextField *tf = (UITextField *)[self.view viewWithTag:index];
    
    NSString *letter = [self.word substringWithRange:NSMakeRange(index - 1, 1)];
    
    // Special case, if entered character is a "W", left justify the text field to fit it
    if ([letter isEqualToString:@"W"]) {
        tf.textAlignment = UITextAlignmentLeft;
    }
    
    [tf setText:letter];
}

- (void)showAnswer {
    for (int i = 1; i <= [self.word length]; i++) {
        
        unichar answerChar = [self.word characterAtIndex:(i - 1)];
        
        if (answerChar == kUNICHARSPACE) {
            // Do nothing to account for space in answer
            NSLog(@"Space in answer phrase");
        }
        else {
            [self showLetterAtIndex:i];
        }
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
        deltaY = -self.view.frame.size.height + kHEADERHEIGHT + kFOOTERHEIGHT;
    }
    else {
        self.isViewHidden = YES;
        // Slide the answer view to the hidden position
        deltaY = self.view.frame.size.height - kHEADERHEIGHT - kFOOTERHEIGHT;
    }
    
    // Slide the answer view
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

- (IBAction) onFlagButtonPressed:(id)sender {
    [self.delegate onFlagButtonPressed:sender];
}

- (IBAction) onMoreButtonPressed:(id)sender {
    if ([self.tf_answer isFirstResponder] == YES) {
        [self.tf_answer resignFirstResponder];
        
        // Slide the answer view down after the keyboard hides
        CGFloat deltaY = [self deltaYForKeyboard];
        
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
    
    [self.delegate onMoreButtonPressed:sender];
}

- (IBAction) onClueButtonPressed:(id)sender {
    
    // Check if the user has enough gems to use a hint
    BOOL canUseHint = [self.delegate canUseHint];
    
    if (canUseHint == YES) {
        NSString *trimmedWordAnswer = [self.word stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //    int numLettersToReveal = MAX([trimmedWordAnswer length] / 3, 1);
        int numLettersToReveal = ([trimmedWordAnswer length] + 3 - 1) / 3;  // Always rounds up
        
        int numLettersRemaining = [trimmedWordAnswer length] - [self.revealedIndexes count];
        
        if (numLettersRemaining <= numLettersToReveal) {
            // Reveal all remaining letters
            for (int i = 1; i <= [self.word length]; i++) {
                if (![self.revealedIndexes containsObject:[NSNumber numberWithInt:i]]) {
                    [self showLetterAtIndex:i];
                    
                    [self disableAnswerTextFieldAtIndex:i];
                    
                    [self colorizeAnswerTextFieldAtIndex:i];
                    
                    [self.revealedIndexes addObject:[NSNumber numberWithInt:i]];
                    
                    // Disable and hide the clue button
                    self.btn_clue.enabled = NO;
                    self.btn_clue.hidden = YES;
                    
                    // Show confirmation view
                    self.didGuessCorrectAnswer = [self checkForCorrectAnswerInitiatedByUser:NO];
                    if (self.didGuessCorrectAnswer == YES) {
                        // User has submitted the correct answer
                        [self.delegate onSubmittedCorrectAnswerViaAllClues:YES];
                    }
                }
            }
        }
        else {
            for (int i = 0; i < numLettersToReveal; i++) {
                int r = arc4random() % ([self.word length] - 1);
                r++;
                
                if ([self.word characterAtIndex:(r - 1)] == kUNICHARSPACE) {
                    // Do not attempt to reveal blank spaces
                    i--;
                }
                else if (![self.revealedIndexes containsObject:[NSNumber numberWithInt:r]]) {
                    [self showLetterAtIndex:r];
                    
                    [self disableAnswerTextFieldAtIndex:r];
                    
                    [self colorizeAnswerTextFieldAtIndex:r];
                    
                    [self.revealedIndexes addObject:[NSNumber numberWithInt:r]];
                }
                else {
                    i--;
                }
            }
            
            // Make the first available textfield active
            for (int i = 0; i < [self.word length]; i++) {
                if ([self.word characterAtIndex:i] == kUNICHARSPACE) {
                    // Do nothing
                }
                else if ([self.revealedIndexes containsObject:[NSNumber numberWithInt:(i + 1)]]) {
                    // Do nothing
                }
                else {
                    UITextField *tf = (UITextField *)[self.view viewWithTag:(i + 1)];
                    [tf becomeFirstResponder];
                    self.tf_answer = tf;
                    break;
                }
            }
        }
    }
    
    [self.delegate onClueButtonPressed:sender];
}

#pragma mark - TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.tf_answer = textField;
    
//    // Hide the error view if it is visible
//    if (self.v_wrongAnswer.hidden == NO) {
//        [UIView animateWithDuration:0.3
//                              delay:0.0
//                            options:UIViewAnimationCurveEaseInOut
//                         animations:^{
//                             self.v_wrongAnswer.alpha = 0.0;
//                         }
//                         completion:^(BOOL finished){
//                             self.v_wrongAnswer.hidden = YES;
//                         }
//         ];
//    }
    
    // Slide the answer view up if the keyboard is not already visible
    if (self.isKeyboardShown == NO) {
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
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // textfield editing has ended
    
    if (self.didGuessCorrectAnswer == YES) {
        [self.delegate onSubmittedCorrectAnswerViaAllClues:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {
    // Prevent numbers, spaces, special characters and capitals in the word and limit to 20 letters
    
    self.tf_answer = textField;
    
    // Force the entered text to all caps
    text = [text uppercaseString];
    
    BOOL shouldProcess = NO; //default to reject
    BOOL shouldMoveToNextField = NO; //default to remaining on the current field
    BOOL shouldMoveToPreviousField = 0; //used if backspace is pressed
    
    int insertStringLength = [text length];
    if (insertStringLength == 0) { //backspace
        shouldProcess = YES; //Process if the backspace character was pressed
        
        if ([[textField text] length] == 1 && [[textField text] isEqualToString:@" "]) {
            shouldMoveToPreviousField = YES; //Backspace was pressed in an empty textfield, move to previous textfield
        }
    }
    else {
        if (([kALLOWEDCHARACTERSET rangeOfString:text].location == NSNotFound) && (range.length != 1)) {
            // only lower case letters and numbers allowed allowed
            shouldProcess = NO;
            
            // Animate a horizontal shake of the answer view when an invalid character is entered
            [self shakeAnswerView];
        }
        else if ([[textField text] length] == 0 || [[textField text] isEqualToString:@" "]) {
            shouldProcess = YES; //Process if there is only 1 character right now or a blank space
        }
    }
    
    //here we deal with the UITextField on our own
    if (shouldProcess) {
        // Special case, if entered character is a "W", left justify the text field to fit it
        if ([text isEqualToString:@"W"]) {
            textField.textAlignment = UITextAlignmentLeft;
        }
        
        //grab a mutable copy of what's currently in the UITextField
        NSMutableString* mstring = [[textField text] mutableCopy];
        if ([mstring length] == 0) {
            //nothing in the field yet so append the replacement string
            [mstring setString:text];
            
            shouldMoveToNextField = YES;
        }
        else {
            //adding a char or deleting?
            if (insertStringLength > 0) {
                [mstring setString:text];
                
                shouldMoveToNextField = YES;
            }
            else {
                //delete case - the length of replacement string is zero for a delete
                textField.textAlignment = UITextAlignmentCenter;
                [mstring setString:@" "];
            }
        }
        
        //set the text now
        [textField setText:mstring];
        
        [mstring release];
        
        // Check if the answer has been entered successfully
        self.didGuessCorrectAnswer = [self checkForCorrectAnswerInitiatedByUser:NO];
        
        if (self.didGuessCorrectAnswer == YES) {
            // User has submitted the correct answer
            [self.delegate onSubmittedCorrectAnswerViaAllClues:NO];
        }
        else {
            if (shouldMoveToNextField) {
                // Move to next textfield
                if (self.tf_answer.tag < [self.word length]) {
                    for (int i = self.tf_answer.tag; i < [self.word length]; i++) {
                        if ([self.word characterAtIndex:i] == kUNICHARSPACE) {
                            // Do nothing
                        }
                        else if ([self.revealedIndexes containsObject:[NSNumber numberWithInt:i + 1]]) {
                            // Do nothing
                        }
                        else {
                            UITextField *tf = (UITextField *)[self.view viewWithTag:(i + 1)];
                            [tf becomeFirstResponder];
                            self.tf_answer = tf;
                            break;
                        }
                    }
                }
                else {
                    // Loop back to the first
                    for (int i = 0; i < [self.word length]; i++) {
                        if ([self.word characterAtIndex:i] == kUNICHARSPACE) {
                            // Do nothing
                        }
                        else if ([self.revealedIndexes containsObject:[NSNumber numberWithInt:(i + 1)]]) {
                            // Do nothing
                        }
                        else {
                            UITextField *tf = (UITextField *)[self.view viewWithTag:(i + 1)];
                            [tf becomeFirstResponder];
                            self.tf_answer = tf;
                            break;
                        }
                    }
                }
            }
            else if (shouldMoveToPreviousField) {
                // Move to previous textfield
                if (self.tf_answer.tag > 1) {
                    for (int i = self.tf_answer.tag; i > 1; i--) {
                        if ([self.word characterAtIndex:(i - 2)] == kUNICHARSPACE) {
                            // Do nothing
                        }
                        else if ([self.revealedIndexes containsObject:[NSNumber numberWithInt:i - 1]]) {
                            // Do nothing
                        }
                        else {
                            UITextField *tf = (UITextField *)[self.view viewWithTag:(i - 1)];
                            [tf becomeFirstResponder];
                            self.tf_answer = tf;
                            break;
                        }
                    }
                }
                else {
                    // Loop back to the last
                    for (int i = [self.word length]; i > 0; i--) {
                        if ([self.word characterAtIndex:(i - 1)] == kUNICHARSPACE) {
                            // Do nothing
                        }
                        else if ([self.revealedIndexes containsObject:[NSNumber numberWithInt:i]]) {
                            // Do nothing
                        }
                        else {
                            UITextField *tf = (UITextField *)[self.view viewWithTag:i];
                            [tf becomeFirstResponder];
                            self.tf_answer = tf;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    //always return no since we are manually changing the text field
    return NO;
}

// Handles keyboard Return button pressed while editing the textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.tf_answer = textField;
    
    self.didGuessCorrectAnswer = [self checkForCorrectAnswerInitiatedByUser:YES];
    
    return self.didGuessCorrectAnswer;
}

#pragma mark - Statics
+ (Mime_meUIAnswerView*)createInstanceWithFrame:(CGRect)frame forMimeWithID:(NSNumber *)mimeID {
    Mime_meUIAnswerView* instance = [[Mime_meUIAnswerView alloc]initWithFrame:(CGRect)frame];
    [instance autorelease];
    
    instance.mimeID = mimeID;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime = (Mime*)[resourceContext resourceWithType:MIME withID:mimeID];
    
    // Set the answer
    instance.word = [mime.word uppercaseString];
    
    return instance;
}

+ (CGRect)frameForAnswerView {
    // The default view will start off the screen and move up into view when loaded
    return CGRectMake(10, 396, 300, 92);
}

@end
