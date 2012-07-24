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

@interface Mime_meFriendsListTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, FBRequestDelegate > {
    id<Mime_meFriendsListTableViewControllerDelegate> m_delegate;
    
    UITableView         *m_tbl_friends;
    
    UIButton            *m_btn_back;
    UIView              *m_v_headerContainer;
    
    NSArray             *m_contacts;
    
    NSDictionary*           m_allContacts;
    NSMutableDictionary*    m_contactSearch;
    NSMutableArray*         m_letters;
    NSMutableArray*         m_lettersDeepCopy;
}

@property (nonatomic, assign) id<Mime_meFriendsListTableViewControllerDelegate>  delegate;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_friends;

@property (nonatomic, retain) IBOutlet  UIButton            *btn_back;
@property (nonatomic, retain) IBOutlet  UIView              *v_headerContainer;

@property (nonatomic, retain)           NSArray             *contacts;

@property (nonatomic, retain)           NSDictionary            *allContacts;
@property (nonatomic, retain)           NSMutableDictionary     *contactSearch;
@property (nonatomic, retain)           NSMutableArray          *letters;
@property (nonatomic, retain)           NSMutableArray          *lettersDeepCopy;

- (IBAction) onBackButtonPressed:(id)sender;

+ (Mime_meFriendsListTableViewController*)createInstance;

@end
