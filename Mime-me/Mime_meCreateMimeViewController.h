//
//  Mime_meCreateMimeViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UICameraActionSheet.h"
#import "Mime_meUINavigationHeaderView.h"
#import "Mime_meUIMakeWordView.h"
#import "Word.h"
#import "GADBannerView.h"
#import "GADPublisherID.h"

@interface Mime_meCreateMimeViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UICameraActionSheetDelegate, Mime_meUINavigationHeaderViewDelgate, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate, Mime_meUIMakeWordViewDelgate, UIAlertViewDelegate > {
    
    Mime_meUINavigationHeaderView   *m_nv_navigationHeader;
    
    Mime_meUIMakeWordView *m_v_makeWordView;
    
    UITableView         *m_tbl_words;
    UITableViewCell     *m_tc_header;
    
    UIButton            *m_btn_moreWords;
    UIButton            *m_btn_makeWord;
    
    NSArray             *m_wordsArray;
    BOOL                m_didMakeWord;
    Word                *m_chosenWord;
    NSString            *m_chosenWordStr;
    
    UICameraActionSheet *m_cameraActionSheet;
    
    CloudEnumerator     *m_wordsCloudEnumerator;
    
    GADBannerView       *m_gad_bannerView;
}

@property (nonatomic, retain)           NSFetchedResultsController      *frc_words;
@property (nonatomic, retain)           CloudEnumerator                 *wordsCloudEnumerator;

@property (nonatomic, retain)           Mime_meUINavigationHeaderView   *nv_navigationHeader;

@property (nonatomic, retain)           Mime_meUIMakeWordView           *v_makeWordView;

@property (nonatomic, retain) IBOutlet  UITableView                     *tbl_words;
@property (nonatomic, retain) IBOutlet  UITableViewCell                 *tc_header;

@property (nonatomic, retain) IBOutlet  UIButton                        *btn_moreWords;
@property (nonatomic, retain) IBOutlet  UIButton                        *btn_makeWord;

@property (nonatomic, retain)           NSArray                         *wordsArray;
@property (nonatomic, assign)           BOOL                            didMakeWord;
@property (nonatomic, retain)           Word                            *chosenWord;
@property (nonatomic, retain)           NSString                        *chosenWordStr;

@property (nonatomic, retain)           UICameraActionSheet             *cameraActionSheet;

@property (nonatomic, retain)           GADBannerView                   *gad_bannerView;

- (IBAction) onMoreWordsButtonPressed:(id)sender;
- (IBAction) onMakeWordButtonPressed:(id)sender;

+ (Mime_meCreateMimeViewController*)createInstance;

@end
