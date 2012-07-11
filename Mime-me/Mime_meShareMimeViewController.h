//
//  Mime_meShareMimeViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Mime_meShareMimeViewController : BaseViewController {
    
    UIView          *m_v_sentContainer;
    UIView          *m_v_sentHeader;
    
}

@property (nonatomic, retain) IBOutlet  UIView          *v_sentContainer;
@property (nonatomic, retain) IBOutlet  UIView          *v_sentHeader;

- (IBAction) onHomeButtonPressed:(id)sender;

+ (Mime_meShareMimeViewController*)createInstance;

@end
