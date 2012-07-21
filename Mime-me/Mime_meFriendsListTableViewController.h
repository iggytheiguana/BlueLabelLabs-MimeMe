//
//  Mime_meFriendsListTableViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meFriendsListTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, FBRequestDelegate > {
    UITableView         *m_tbl_friends;
    
    UIButton            *m_btn_back;
    UIView              *m_v_headerContainer;
    
    NSArray             *m_facebookFriends;
}

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_friends;

@property (nonatomic, retain) IBOutlet  UIButton            *btn_back;
@property (nonatomic, retain) IBOutlet  UIView              *v_headerContainer;

@property (nonatomic, retain)           NSArray             *facebookFriends;

- (IBAction) onBackButtonPressed:(id)sender;

+ (Mime_meFriendsListTableViewController*)createInstance;

@end
