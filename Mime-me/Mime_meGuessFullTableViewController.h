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

@interface Mime_meGuessFullTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    UITableView         *m_tbl_mimes;
    UITableViewCell     *m_tc_friendsHeader;
    UITableViewCell     *m_tc_recentHeader;
    UITableViewCell     *m_tc_staffPicksHeader;
    
    NSInteger           m_mimeType;
    
    CloudEnumerator     *m_mimeCloudEnumerator;
    
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_mimes;

@property (nonatomic, retain)           CloudEnumerator                 *mimeCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain) IBOutlet  UITableView         *tbl_mimes;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_friendsHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_recentHeader;
@property (nonatomic, retain) IBOutlet  UITableViewCell     *tc_staffPicksHeader;

@property (nonatomic, assign)           NSInteger           mimeType;



- (IBAction) onHomeButtonPressed:(id)sender;

- (IBAction) onMimeButtonPressed:(id)sender;
- (IBAction) onGuessButtonPressed:(id)sender;
- (IBAction) onScrapbookButtonPressed:(id)sender;

- (IBAction) onSettingsButtonPressed:(id)sender;
- (IBAction) onBackButtonPressed:(id)sender;

+ (Mime_meGuessFullTableViewController*)createInstanceForMimeType:(NSInteger)mimeType;


@end
