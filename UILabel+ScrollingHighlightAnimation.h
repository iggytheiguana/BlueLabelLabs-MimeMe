//
//  UILabel+ScrollingHighlightAnimation.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/29/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UILabel (ScrollingHighlightAnimation)

- (void)setTextWithChangeAnimation:(NSString*)text reverse:(BOOL)reverse withTextShadow:(BOOL)shadow;

@end
