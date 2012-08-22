//
//  Mime_meCommentsTableViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 8/22/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meCommentsTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    NSNumber                    *m_mimeID;
    
    UITableView                 *m_tbl_comments;
    
    UIButton                    *m_btn_back;
    UIView                      *m_v_headerContainer;
    
    CloudEnumerator             *m_commentsCloudEnumerator;
    
}

@property (nonatomic, retain)           NSNumber                    *mimeID;

@property (nonatomic, retain)           NSFetchedResultsController  *frc_comments;

@property (nonatomic, retain)           CloudEnumerator             *commentsCloudEnumerator;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_comments;

@property (nonatomic, retain) IBOutlet  UIButton                    *btn_back;
@property (nonatomic, retain) IBOutlet  UIView                      *v_headerContainer;

- (IBAction) onBackButtonPressed:(id)sender;

+ (Mime_meCommentsTableViewController*)createInstanceForMimeWithID:(NSNumber *)mimeID;

@end
