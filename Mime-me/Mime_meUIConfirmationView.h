//
//  Mime_meUIConfirmationView.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Mime_meUIConfirmationViewDelgate <NSObject>
@required

- (IBAction) onCloseButtonPressed:(id)sender;
- (IBAction) onOkButtonPressed:(id)sender;
- (IBAction) onFavoriteButtonPressed:(id)sender;
- (IBAction) onEmailButtonPressed:(id)sender;
- (IBAction) onFacebookButtonPressed:(id)sender;
- (IBAction) onTwitterButtonPressed:(id)sender;

@end

@interface Mime_meUIConfirmationView : UIView {
    id<Mime_meUIConfirmationViewDelgate> m_delegate;
    
    UIView          *m_view;
    UIView          *m_v_background;
    UIView          *m_v_confirmationView;
    
    UIView          *m_v_sentHeader;
    UILabel         *m_lbl_title;
    UILabel         *m_lbl_subtitle;
    UIButton        *m_btn_close;
    UIButton        *m_btn_ok;
    UIButton        *m_btn_facebook;
    UIButton        *m_btn_twitter;
    UIButton        *m_btn_email;
    UIButton        *m_btn_favorite;
    
}

@property (nonatomic, assign) id<Mime_meUIConfirmationViewDelgate>  delegate;

@property (nonatomic, retain) IBOutlet  UIView          *view;
@property (nonatomic, retain) IBOutlet  UIView          *v_background;
@property (nonatomic, retain) IBOutlet  UIView          *v_confirmationView;

@property (nonatomic, retain) IBOutlet  UIView          *v_sentHeader;
@property (nonatomic, retain) IBOutlet  UILabel         *lbl_title;
@property (nonatomic, retain) IBOutlet  UILabel         *lbl_subtitle;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_close;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_ok;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_facebook;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_twitter;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_email;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_favorite;

- (void)show;

+ (CGRect)frameForConfirmationView;
+ (Mime_meUIConfirmationView*)createInstanceWithFrame:(CGRect)frame withTitle:(NSString *)title withSubtitle:(NSString *)subtitle;

@end
