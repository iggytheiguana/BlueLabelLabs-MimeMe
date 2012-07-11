//
//  Mime_meShareMimeViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meShareMimeViewController : BaseViewController {
    UIImageView     *m_iv_photo;
    
    UIView          *m_v_sentContainer;
    UIView          *m_v_sentHeader;
    UIView          *m_v_background;
    
    UIButton        *m_btn_close;
    UIButton        *m_btn_ok;
    UIButton        *m_btn_facebook;
    UIButton        *m_btn_twitter;
    UIButton        *m_btn_email;
    UIButton        *m_btn_scrapbook;
    
    NSNumber        *m_mimeID;
    CGSize          m_imageSize;
    
}

@property (nonatomic, retain) IBOutlet  UIImageView     *iv_photo;

@property (nonatomic, retain) IBOutlet  UIView          *v_sentContainer;
@property (nonatomic, retain) IBOutlet  UIView          *v_sentHeader;
@property (nonatomic, retain) IBOutlet  UIView          *v_background;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_close;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_ok;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_facebook;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_twitter;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_email;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_scrapbook;


@property (nonatomic, retain)           NSNumber        *mimeID;
@property                               CGSize          imageSize;

- (IBAction) onCloseButtonPressed:(id)sender;
- (IBAction) onOkButtonPressed:(id)sender;

+ (Mime_meShareMimeViewController*)createInstanceWithMimeID:(NSNumber *)mimeID;

@end
