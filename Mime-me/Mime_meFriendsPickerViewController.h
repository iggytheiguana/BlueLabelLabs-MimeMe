//
//  Mime_meFriendsPickerViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meFriendsPickerViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate > {
    UITableView         *m_tbl_friends;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_addContactsHeader;
    
    NSArray             *m_friendsArray;
}

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_friends;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_addContactsHeader;

@property (nonatomic, retain)           NSArray         *friendsArray;

+ (Mime_meFriendsPickerViewController*)createInstance;

@end
