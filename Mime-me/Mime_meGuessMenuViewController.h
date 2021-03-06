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
#import "GADBannerView.h"
#import "GADPublisherID.h"

@interface Mime_meGuessMenuViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_recentHeader;
    UITableViewCell     *m_tc_staffPicksHeader;
    UITableViewCell     *m_tc_topFavoritesHeader;
    
    CloudEnumerator     *m_mimeAnswersCloudEnumerator;
    CloudEnumerator     *m_recentMimesCloudEnumerator;
    CloudEnumerator     *m_staffPickedMimesCloudEnumerator;
    CloudEnumerator     *m_topFavoriteMimesCloudEnumerator;
    
    GADBannerView       *m_gad_bannerView;
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_mimeAnswersFromFriends;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_recentMimes;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_staffPickedMimes;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_topFavoriteMimes;

@property (nonatomic, retain)           CloudEnumerator                 *mimeAnswersCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *recentMimesCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *staffPickedMimesCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *topFavoriteMimesCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_recentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_staffPicksHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_topFavoritesHeader;

@property (nonatomic, retain)           GADBannerView       *gad_bannerView;

+ (Mime_meGuessMenuViewController*)createInstance;

@end
