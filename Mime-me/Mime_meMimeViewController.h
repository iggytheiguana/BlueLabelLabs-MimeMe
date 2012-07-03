//
//  Mime_meMimeViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UICameraActionSheet.h"

@interface Mime_meMimeViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UICameraActionSheetDelegate > {
    UIButton    *m_btn_home;
    
    UIButton    *m_btn_mime;
    UIButton    *m_btn_guess;
    UIButton    *m_btn_scrapbook;
    UIButton    *m_btn_settings;
    UIButton    *m_btn_getWords;
    
    UITableView *m_tbl_words;
    
    NSArray     *m_wordsArray;
}

@property (nonatomic, retain) IBOutlet  UIButton        *btn_home;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_mime;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_guess;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_scrapbook;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_settings;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_getWords;

@property (nonatomic, retain) IBOutlet  UITableView     *tbl_words;

@property (nonatomic, retain)           NSArray         *wordsArray;

- (IBAction) onMimeButtonPressed:(id)sender;
- (IBAction) onGuessButtonPressed:(id)sender;
- (IBAction) onScrapbookButtonPressed:(id)sender;
- (IBAction) onSettingsButtonPressed:(id)sender;

- (IBAction) onHomeButtonPressed:(id)sender;

+ (Mime_meMimeViewController*)createInstance;

@end
