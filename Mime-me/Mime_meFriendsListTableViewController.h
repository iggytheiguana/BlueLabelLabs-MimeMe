//
//  Mime_meFriendsListTableViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol Mime_meFriendsListTableViewControllerDelegate <NSObject>
@required

@end

@interface Mime_meFriendsListTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, FBRequestDelegate, UISearchDisplayDelegate, UISearchBarDelegate > {
    id<Mime_meFriendsListTableViewControllerDelegate> m_delegate;
    
    UITableView                 *m_tbl_friends;
    
    UIButton                    *m_btn_back;
    UIView                      *m_v_headerContainer;
    UISearchDisplayController   *m_searchDisplayController;
    
    NSArray                     *m_contacts;            // Master list of contacts
    NSMutableArray              *m_filteredContacts;    // Used for search control
    
}

@property (nonatomic, assign) id<Mime_meFriendsListTableViewControllerDelegate>  delegate;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_friends;

@property (nonatomic, retain) IBOutlet  UIButton                    *btn_back;
@property (nonatomic, retain) IBOutlet  UIView                      *v_headerContainer;
@property (nonatomic, retain) IBOutlet  UISearchDisplayController   *searchDisplayController;

@property (nonatomic, retain)           NSArray                     *contacts;
@property (nonatomic, retain)           NSMutableArray              *filteredContacts;

- (IBAction) onBackButtonPressed:(id)sender;

+ (Mime_meFriendsListTableViewController*)createInstance;

@end
