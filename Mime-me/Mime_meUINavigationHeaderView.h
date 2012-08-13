//
//  Mime_meUINavigationHeaderView.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Mime_meUINavigationHeaderViewDelgate <NSObject>

@optional

- (IBAction) onHomeButtonPressed:(id)sender;

- (IBAction) onBackButtonPressed:(id)sender;
- (IBAction) onSettingsButtonPressed:(id)sender;

- (IBAction) onMimeButtonPressed:(id)sender;
- (IBAction) onGuessButtonPressed:(id)sender;
- (IBAction) onScrapbookButtonPressed:(id)sender;

@end

@interface Mime_meUINavigationHeaderView : UIView {
    id<Mime_meUINavigationHeaderViewDelgate> m_delegate;
    
    UIView      *m_view;
    
    UIButton    *m_btn_home;
    
    UIButton    *m_btn_mime;
    UIButton    *m_btn_guess;
    UIButton    *m_btn_scrapbook;
    
    UIButton    *m_btn_settings;
    UIButton    *m_btn_back;
    UIButton    *m_btn_gemCount;
}

@property (nonatomic, assign) id<Mime_meUINavigationHeaderViewDelgate>  delegate;

@property (nonatomic, retain) IBOutlet  UIView          *view;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_home;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_mime;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_guess;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_scrapbook;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_settings;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_back;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_gemCount;

+ (CGRect)frameForNavigationHeader;

@end
