//
//  Mime_meAnswersTableViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 8/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meAnswersTableViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {
    NSNumber                    *m_mimeID;
    
    UITableView                 *m_tbl_answers;
    
    UIButton                    *m_btn_back;
    UIView                      *m_v_headerContainer;
    
    CloudEnumerator             *m_mimeAnswerCloudEnumerator;
//    CloudEnumerator             *m_userCloudEnumerator;
    
}

@property (nonatomic, retain)           NSNumber                    *mimeID;

@property (nonatomic, retain)           NSFetchedResultsController  *frc_mimeAnswers;

@property (nonatomic, retain)           CloudEnumerator             *mimeAnswerCloudEnumerator;
//@property (nonatomic, retain)           CloudEnumerator             *userCloudEnumerator;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_answers;

@property (nonatomic, retain) IBOutlet  UIButton                    *btn_back;
@property (nonatomic, retain) IBOutlet  UIView                      *v_headerContainer;

- (IBAction) onBackButtonPressed:(id)sender;

+ (Mime_meAnswersTableViewController*)createInstanceForMimeWithID:(NSNumber *)mimeID;

@end