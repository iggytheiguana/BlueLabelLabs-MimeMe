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

@interface Mime_meViewMimeViewController : BaseViewController < Mime_meUIConfirmationViewDelgate, Mime_meUIAnswerViewDelgate, UIProgressHUDViewDelegate, MFMailComposeViewControllerDelegate > {
    NSNumber        *m_mimeID;
    NSNumber        *m_mimeAnswerID;
    CGSize          m_imageSize;
    int             m_viewMimeCase;
    
    UIImageView     *m_iv_photo;
    UIImageView     *m_iv_logo;
    UIButton        *m_btn_back;
    UIView          *m_v_background;
    
    // sentContainer    
    Mime_meUIConfirmationView   *m_v_confirmationView;
    
    // answerContainer
    Mime_meUIAnswerView         *m_v_answerView;
    
    BOOL                        m_didUseHint;
    
}

@property (nonatomic, retain)           NSNumber        *mimeID;
@property (nonatomic, retain)           NSNumber        *mimeAnswerID;
@property                               CGSize          imageSize;
@property                               int             viewMimeCase;

@property (nonatomic, retain) IBOutlet  UIImageView     *iv_photo;
@property (nonatomic, retain) IBOutlet  UIImageView     *iv_logo;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_back;
@property (nonatomic, retain) IBOutlet  UIView          *v_background;

// sentContainer
@property (nonatomic, retain)           Mime_meUIConfirmationView   *v_confirmationView;

// answerContainer
@property (nonatomic, retain)           Mime_meUIAnswerView         *v_answerView;

@property (nonatomic, assign)           BOOL                        didUseHint;

- (IBAction) onBackButtonPressed:(id)sender;

- (IBAction) onFacebookButtonPressed:(id)sender;
- (IBAction) onTwitterButtonPressed:(id)sender;

+ (Mime_meViewMimeViewController*)createInstanceForCase:(int)viewMimeCase withMimeID:(NSNumber *)mimeID withMimeAnswerIDorNil:(NSNumber *)mimeAnswerID;

@end
