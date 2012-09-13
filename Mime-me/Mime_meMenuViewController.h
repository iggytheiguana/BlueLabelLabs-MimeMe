//
//  Mime_meMenuViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GADBannerView.h"
#import "GADPublisherID.h"

@interface Mime_meMenuViewController : BaseViewController {
    UIButton    *m_btn_mime;
    UIButton    *m_btn_guess;
    UIButton    *m_btn_scrapbook;
    UIButton    *m_btn_settings;
    UIButton    *m_btn_getGems;
    
    GADBannerView       *m_gad_bannerView;
}

@property (nonatomic, retain) IBOutlet UIButton     *btn_mime;
@property (nonatomic, retain) IBOutlet UIButton     *btn_guess;
@property (nonatomic, retain) IBOutlet UIButton     *btn_scrapbook;
@property (nonatomic, retain) IBOutlet UIButton     *btn_settings;
@property (nonatomic, retain) IBOutlet UIButton     *btn_getGems;

@property (nonatomic, retain)          GADBannerView       *gad_bannerView;

- (IBAction) onMimeButtonPressed:(id)sender;
- (IBAction) onGuessButtonPressed:(id)sender;
- (IBAction) onScrapbookButtonPressed:(id)sender;
- (IBAction) onSettingsButtonPressed:(id)sender;

+ (Mime_meMenuViewController*)createInstance;

@end
