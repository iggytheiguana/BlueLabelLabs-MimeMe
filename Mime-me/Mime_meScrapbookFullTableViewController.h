//
//  Mime_meScrapbookFullTableViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Mime_meUINavigationHeaderView.h"

@interface Mime_meScrapbookFullTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_sentHeader;
    UITableViewCell     *m_tc_favoritesHeader;
    UITableViewCell     *m_tc_guessedHeader;
    
    NSInteger           m_mimeType;
    
    CloudEnumerator     *m_mimeCloudEnumerator;
    
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_mimes;

@property (nonatomic, retain)           CloudEnumerator                 *mimeCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_sentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_favoritesHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_guessedHeader;

@property (nonatomic, assign)           NSInteger           mimeType;

+ (Mime_meScrapbookFullTableViewController*)createInstanceForMimeType:(NSInteger)mimeType;


@end
