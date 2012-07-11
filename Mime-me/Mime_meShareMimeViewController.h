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
    UIImageView     *m_iv_image;
    
    UIView          *m_v_sentContainer;
    UIView          *m_v_sentHeader;
    
    NSNumber        *m_mimeID;
    
}

@property (nonatomic, retain) IBOutlet  UIImageView     *iv_image;

@property (nonatomic, retain) IBOutlet  UIView          *v_sentContainer;
@property (nonatomic, retain) IBOutlet  UIView          *v_sentHeader;

@property (nonatomic, retain)           NSNumber        *mimeID;

- (IBAction) onHomeButtonPressed:(id)sender;

+ (Mime_meShareMimeViewController*)createInstanceWithMimeID:(NSNumber *)mimeID;

@end
