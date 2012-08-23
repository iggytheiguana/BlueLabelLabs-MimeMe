//
//  Mime_meShareMimeViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "Mime_meUIAnswerView.h"
#import "Mime_meUIConfirmationView.h"
#import "ViewMimeCase.h"

@interface Mime_meViewMimeViewController : BaseViewController < Mime_meUIConfirmationViewDelgate, Mime_meUIAnswerViewDelgate, UIProgressHUDViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, CloudEnumeratorDelegate > {
    NSNumber        *m_mimeID;
    NSNumber        *m_mimeAnswerID;
    NSNumber        *m_creatorID;
    CGSize          m_imageSize;
    int             m_viewMimeCase;
    
    UIImageView     *m_iv_photo;
    UIView          *m_v_background;
    
    UIView          *m_v_customNavContainer;
    UIButton        *m_btn_back;
    UIImageView     *m_iv_profilePicture;
    UILabel         *m_lbl_title;
    UIButton        *m_btn_gemCount;
    
    UIView          *m_v_fromUserContainer;
    UIButton        *m_btn_answers;
    UIButton        *m_btn_comments;
    
    // sentContainer    
    Mime_meUIConfirmationView   *m_v_confirmationView;
    
    // answerContainer
    Mime_meUIAnswerView         *m_v_answerView;
    
    int                         m_numHintsUsed;
    BOOL                        m_didMakeWord;
    
    CloudEnumerator             *m_mimeAnswerCloudEnumerator;
    CloudEnumerator             *m_commentsCloudEnumerator;
    
}

@property (nonatomic, retain)           NSNumber        *mimeID;
@property (nonatomic, retain)           NSNumber        *mimeAnswerID;
@property (nonatomic, retain)           NSNumber        *creatorID;
@property                               CGSize          imageSize;
@property                               int             viewMimeCase;

@property (nonatomic, retain) IBOutlet  UIImageView     *iv_photo;
@property (nonatomic, retain) IBOutlet  UIView          *v_background;

@property (nonatomic, retain) IBOutlet  UIView          *v_customNavContainer;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_back;
@property (nonatomic, retain) IBOutlet  UIImageView     *iv_profilePicture;
@property (nonatomic, retain) IBOutlet  UILabel         *lbl_title;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_gemCount;

@property (nonatomic, retain) IBOutlet  UIView          *v_fromUserContainer;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_answers;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_comments;

// sentContainer
@property (nonatomic, retain)           Mime_meUIConfirmationView   *v_confirmationView;

// answerContainer
@property (nonatomic, retain)           Mime_meUIAnswerView         *v_answerView;

@property (nonatomic, assign)           int                         numHintsUsed;
@property (nonatomic, assign)           BOOL                        didMakeWord;

@property (nonatomic, retain)           CloudEnumerator             *mimeAnswerCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator             *commentsCloudEnumerator;

- (IBAction) onBackButtonPressed:(id)sender;
- (IBAction) onAnswersButtonPressed:(id)sender;
- (IBAction) onCommentsButtonPressed:(id)sender;

- (IBAction) onFacebookButtonPressed:(id)sender;
- (IBAction) onTwitterButtonPressed:(id)sender;

+ (Mime_meViewMimeViewController*)createInstanceForCase:(int)viewMimeCase withMimeID:(NSNumber *)mimeID withMimeAnswerIDorNil:(NSNumber *)mimeAnswerID;

@end
