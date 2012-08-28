//
//  Mime_meGuessFullTableViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Mime_meUINavigationHeaderView.h"
#import "GADBannerView.h"
#import "GADPublisherID.h"

@interface Mime_meGuessFullTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_recentHeader;
    UITableViewCell     *m_tc_staffPicksHeader;
    UITableViewCell     *m_tc_topFavoritesHeader;
    
    NSInteger           m_mimeType;
    
    CloudEnumerator     *m_mimeCloudEnumerator;

    GADBannerView       *m_gad_bannerView;
    
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_mimes;

@property (nonatomic, retain)           CloudEnumerator                 *mimeCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_recentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_staffPicksHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_topFavoritesHeader;

@property (nonatomic, assign)           NSInteger           mimeType;

@property (nonatomic, retain)           GADBannerView       *gad_bannerView;

+ (Mime_meGuessFullTableViewController*)createInstanceForMimeType:(NSInteger)mimeType;


@end
