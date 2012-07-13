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

- (IBAction) onDismissButtonPressed:(id)sender;
- (IBAction) onClueButtonPressed:(id)sender;


@end

@interface Mime_meUIAnswerView : UIView < UITextFieldDelegate> {
    id<Mime_meUIAnswerViewDelgate> m_delegate;
    
    UIView          *m_view;
    
    UIView          *m_v_answerHeader;
    UILabel         *m_lbl_from;
    UIButton        *m_btn_dismiss;
    UIButton        *m_btn_clue;
    UITextField     *m_tf_answer;
}

@property (nonatomic, assign) id<Mime_meUIAnswerViewDelgate>  delegate;

@property (nonatomic, retain) IBOutlet  UIView          *view;

@property (nonatomic, retain) IBOutlet  UIView          *v_answerHeader;
@property (nonatomic, retain) IBOutlet  UILabel         *lbl_from;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_dismiss;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_clue;
@property (nonatomic, retain) IBOutlet  UITextField     *tf_answer;

+ (CGRect)frameForAnswerView;

@end
