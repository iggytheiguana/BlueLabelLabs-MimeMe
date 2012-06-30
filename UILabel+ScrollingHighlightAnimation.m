//
//  UILabel+ScrollingHighlightAnimation.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/29/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "UILabel+ScrollingHighlightAnimation.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation UILabel (ScrollingHighlightAnimation)

- (void)setTextWithChangeAnimation:(NSString*)text reverse:(BOOL)reverse withTextShadow:(BOOL)shadow
{
    NSLog(@"value changing");
    
    CGFloat textWidth = self.frame.size.width;
    CGFloat textHeight = self.frame.size.height;
    
    self.text = text;
    CALayer *maskLayer = [CALayer layer];
    
    // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
    // to the same value so the layer can extend the mask image.
    maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f] CGColor];
    maskLayer.contents = (id)[[UIImage imageNamed:@"Mask.png"] CGImage];
    
    // Center the mask image on twice the width of the text layer, so it starts to the left
    // of the text layer and moves to its right when we translate it by width.
    maskLayer.contentsGravity = kCAGravityCenter;
    if (reverse == YES) {
        maskLayer.frame = CGRectMake(0, 0.0f, textWidth * 2, textHeight);
    }
    else {
        maskLayer.frame = CGRectMake(textWidth * -1, 0.0f, textWidth * 2, textHeight);
    }
    
    // Animate the mask layer's horizontal position
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    if (reverse == YES) {
        maskAnim.byValue = [NSNumber numberWithFloat:-textWidth];
    }
    else {
        maskAnim.byValue = [NSNumber numberWithFloat:textWidth];
    }
    
    maskAnim.repeatCount = HUGE_VALF;
    maskAnim.duration = 2.0f;
    [maskLayer addAnimation:maskAnim forKey:@"slideAnim"];
    
    self.layer.mask = maskLayer;
    
    // OPTIONAL: Add shadow to the text layer
    if (shadow == YES) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.layer.shadowOpacity = 1;   
        self.layer.shadowRadius = 2.0;
    }
}

@end
