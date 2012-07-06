//
//  Mime_meFriendsPickerViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Mime_meUINavigationHeaderView.h"

@interface Mime_meFriendsPickerViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    UIButton            *m_btn_go;
    
    UITableView         *m_tbl_friends;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_addContactsHeader;
    
    NSArray             *m_friendsArray;
}

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;
@property (nonatomic, retain)           UIButton            *btn_go;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_friends;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_addContactsHeader;

@property (nonatomic, retain)           NSArray             *friendsArray;

- (IBAction) onHomeButtonPressed:(id)sender;

- (IBAction) onGoButtonPressed:(id)sender;

+ (Mime_meFriendsPickerViewController*)createInstance;

@end
