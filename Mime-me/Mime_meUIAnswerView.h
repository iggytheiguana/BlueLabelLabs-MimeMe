//
//  Mime_meUIAnswerView.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Mime_meUIAnswerViewDelgate <NSObject>
@required

- (IBAction) onSlideButtonPressed:(id)sender;
- (IBAction) onFlagButtonPressed:(id)sender;
- (IBAction) onClueButtonPressed:(id)sender;
- (void) onSubmittedCorrectAnswer:(BOOL)isCorrect;


@end

@interface Mime_meUIAnswerView : UIView < UITextFieldDelegate> {
    id<Mime_meUIAnswerViewDelgate> m_delegate;
    
    UIView          *m_view;
    
    UIView          *m_v_answerHeader;
    UIButton        *m_btn_slide;
    UIButton        *m_btn_flag;
    UIButton        *m_btn_clue;
    UITextField     *m_tf_answer;
    UIView          *m_v_wrongAnswer;
    
    NSString        *m_word;
    BOOL            m_isViewHidden;
    BOOL            m_isKeyboardShown;
    BOOL            m_didGuessCorrectAnswer;
    
}

@property (nonatomic, assign) id<Mime_meUIAnswerViewDelgate>  delegate;

@property (nonatomic, retain) IBOutlet  UIView          *view;

@property (nonatomic, retain) IBOutlet  UIView          *v_answerHeader;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_slide;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_flag;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_clue;
@property (nonatomic, retain) IBOutlet  UITextField     *tf_answer;
@property (nonatomic, retain)           UIView          *v_wrongAnswer;

@property (nonatomic, retain)           NSString        *word;
@property (nonatomic, assign)           BOOL            isViewHidden;
@property (nonatomic, assign)           BOOL            isKeyboardShown;
@property (nonatomic, assign)           BOOL            didGuessCorrectAnswer;

- (void)renderWordDisplay;
- (void)disableAnswerTextFields;
- (void)showAnswer;

+ (CGRect)frameForAnswerView;
+ (Mime_meUIAnswerView*)createInstanceWithFrame:(CGRect)frame withWord:(NSString *)word;

@end
