//
//  Mime_meMimeViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meMimeViewController : BaseViewController {
    UIButton    *m_btn_home;
}

@property (nonatomic, retain) IBOutlet UIButton     *btn_home;

- (IBAction) onHomeButtonPressed:(id)sender;

+ (Mime_meMimeViewController*)createInstance;

@end
