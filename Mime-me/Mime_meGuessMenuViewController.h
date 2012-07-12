//
//  Mime_meGuessMenuViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Mime_meUINavigationHeaderView.h"

@interface Mime_meGuessMenuViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_recentHeader;
    UITableViewCell     *m_tc_staffPicksHeader;
    
    NSArray             *m_friendsArray;
    NSArray             *m_recentArray;
    NSArray             *m_staffPicksArray;
    
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_mimes;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_recentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_staffPicksHeader;

@property (nonatomic, retain)           NSArray             *friendsArray;
@property (nonatomic, retain)           NSArray             *recentArray;
@property (nonatomic, retain)           NSArray             *staffPicksArray;

+ (Mime_meGuessMenuViewController*)createInstance;

@end
