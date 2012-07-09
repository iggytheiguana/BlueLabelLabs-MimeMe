//
//  Mime_meSettingsViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meSettingsViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate > {
    UITableView         *m_tbl_settings;
    UITableViewCell     *m_tc_settingHeader;
    
    UIButton            *m_btn_close;

}

@property (nonatomic, retain) IBOutlet  UITableView      *tbl_settings;
@property (nonatomic, retain) IBOutlet  UITableViewCell  *tc_settingHeader;

@property (nonatomic, retain) IBOutlet  UIButton         *btn_close;

- (IBAction) onCloseButtonPressed:(id)sender;

+ (Mime_meSettingsViewController*)createInstance;

@end
