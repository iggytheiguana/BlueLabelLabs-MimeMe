//
//  AutorotatingUINavigationController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 10/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutorotatingUINavigationController : UINavigationController

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotate;

@end
