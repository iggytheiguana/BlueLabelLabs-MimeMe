//
//  UIImage+UIImageCategory.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/11/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIImage+UIImageCategory.h"

@implementation UIImage (UIImageCategory)

- (UIImage*)imageScaledToSize:(CGSize)size {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    double scaleFactor = fmax(fmax(self.size.width / size.width, self.size.height / size.height), 1);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    double newWidth = self.size.width / scaleFactor;
    double newHeight = self.size.height / scaleFactor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (size.width - newWidth) / 2; float topOffset = (size.height - newHeight) / 2;
    
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
//    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [self drawInRect:newRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
