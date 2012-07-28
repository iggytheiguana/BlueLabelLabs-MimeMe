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

@interface Mime_meGuessMenuViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_recentHeader;
    UITableViewCell     *m_tc_staffPicksHeader;
    
    CloudEnumerator     *m_mimeAnswersCloudEnumerator;
    CloudEnumerator     *m_recentMimesCloudEnumerator;
    CloudEnumerator     *m_staffPickedMimesCloudEnumerator;
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_mimeAnswersFromFriends;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_recentMimes;
@property (nonatomic, retain)           NSFetchedResultsController      *frc_staffPickedMimes;

@property (nonatomic, retain)           CloudEnumerator                 *mimeAnswersCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *recentMimesCloudEnumerator;
@property (nonatomic, retain)           CloudEnumerator                 *staffPickedMimesCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_recentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_staffPicksHeader;

+ (Mime_meGuessMenuViewController*)createInstance;

@end
