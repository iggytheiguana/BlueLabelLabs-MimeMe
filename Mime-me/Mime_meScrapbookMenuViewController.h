//
//  Mime_meScrapbookMenuViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Mime_meUINavigationHeaderView.h"
#import "GADBannerView.h"
#import "GADPublisherID.h"

@interface Mime_meScrapbookMenuViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_scrapbook;
    UITableViewCell     *m_tc_sentHeader;
    UITableViewCell     *m_tc_favoritesHeader;
    UITableViewCell     *m_tc_guessedHeader;
    
    CloudEnumerator     *m_sentMimesCloudEnumerator;
    CloudEnumerator     *m_favoriteMimesCloudEnumerator;
    CloudEnumerator     *m_guessedMimeAnswersCloudEnumerator;
    
    GADBannerView       *m_gad_bannerView;
    
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_sentMimes;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_favoriteMimes;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_guessedMimeAnswers;

@property (nonatomic, retain)           CloudEnumerator                 *sentMimesCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *favoriteMimesCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *guessedMimeAnswersCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView                     *tbl_scrapbook;
@property (nonatomic, retain) IBOutlet  UITableViewCell                 *tc_sentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell                 *tc_favoritesHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell                 *tc_guessedHeader;

@property (nonatomic, retain)           GADBannerView                   *gad_bannerView;

+ (Mime_meScrapbookMenuViewController*)createInstance;

@end
