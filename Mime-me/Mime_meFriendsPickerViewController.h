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
#import "Mime_meFriendsListTableViewController.h"
#import "GADBannerView.h"
#import "GADPublisherID.h"

@interface Mime_meFriendsPickerViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, UIProgressHUDViewDelegate, Mime_meFriendsListTableViewControllerDelegate, FBRequestDelegate > {
    
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    UIButton            *m_btn_go;
    
    UITableView         *m_tbl_friends;
    UITableViewCell     *m_tc_selectedHeader;
    UITableViewCell     *m_tc_addContactsHeader;
    
    NSNumber            *m_mimeID;
    
    NSArray             *m_facebookFriendsArray;
    NSArray             *m_phoneContactsArray;
    NSMutableArray      *m_selectedFriendsArray;
    NSMutableArray      *m_selectedFriendsArrayCopy;
    
    GADBannerView       *m_gad_bannerView;
    
}

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;
@property (nonatomic, retain)           UIButton            *btn_go;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_friends;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_selectedHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_addContactsHeader;

@property (nonatomic, retain)           NSNumber            *mimeID;

@property (nonatomic, retain)           NSArray             *facebookFriendsArray;
@property (nonatomic, retain)           NSArray             *phoneContactsArray;
@property (nonatomic, retain)           NSMutableArray      *selectedFriendsArray;
@property (nonatomic, retain)           NSMutableArray      *selectedFriendsArrayCopy;

@property (nonatomic, retain)           GADBannerView                   *gad_bannerView;

- (IBAction) onGoButtonPressed:(id)sender;

+ (Mime_meFriendsPickerViewController*)createInstanceWithMimeID:(NSNumber *)mimeID;

@end
