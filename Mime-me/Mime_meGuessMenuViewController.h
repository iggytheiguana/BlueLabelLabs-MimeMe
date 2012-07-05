//
//  Mime_meGuessMenuViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meGuessMenuViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate > {
    UIButton    *m_btn_home;
    
    UIButton    *m_btn_mime;
    UIButton    *m_btn_guess;
    UIButton    *m_btn_scrapbook;
    UIButton    *m_btn_settings;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_recentHeader;
    UITableViewCell     *m_tc_staffPicksHeader;
    
    NSArray             *m_friendsArray;
    NSArray             *m_recentArray;
    NSArray             *m_staffPicksArray;
    
}

@property (nonatomic, retain) IBOutlet  UIButton        *btn_home;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_mime;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_guess;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_scrapbook;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_settings;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_recentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_staffPicksHeader;

@property (nonatomic, retain)           NSArray             *friendsArray;
@property (nonatomic, retain)           NSArray             *recentArray;
@property (nonatomic, retain)           NSArray             *staffPicksArray;

- (IBAction) onHomeButtonPressed:(id)sender;

- (IBAction) onMimeButtonPressed:(id)sender;
- (IBAction) onGuessButtonPressed:(id)sender;
- (IBAction) onScrapbookButtonPressed:(id)sender;
- (IBAction) onSettingsButtonPressed:(id)sender;

+ (Mime_meGuessMenuViewController*)createInstance;

@end
