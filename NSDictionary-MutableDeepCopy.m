//
//  UIImageView+UIImageViewCategory.m
//  Platform
//
//  Created by Jordan Gurrieri on 2/16/12.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//


#import "NSDictionary-MutableDeepCopy.h"
@implementation NSDictionary (MutableDeepCopy)

- (NSMutableDictionary *) mutableDeepCopy {
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc]
                                       initWithCapacity:[self count]]; NSArray *keys = [self allKeys];
    
    for (id key in keys) {
        id oneValue = [self valueForKey:key];
        id oneCopy = nil;
        
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)])
            oneCopy = [oneValue mutableDeepCopy];
        else if ([oneValue respondsToSelector:@selector(mutableCopy)])
            oneCopy = [oneValue mutableCopy];
        if (oneCopy == nil)
            oneCopy = [oneValue copy];
        [returnDict setValue:oneCopy forKey:key];
        [oneCopy release];
    }
    return returnDict;
}

@end