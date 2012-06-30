//
//  NSMutableArray+NSMutableArrayCategory.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/26/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//
//  This category enhances NSMutableArray by providing
//  methods to randomly shuffle the elements.
//

#import "NSMutableArray+NSMutableArrayCategory.h"

@implementation NSMutableArray (NSMutableArrayCategory)

- (void)shuffle
{
    
    /*static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom(time(NULL));
    }*/
    
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        //int n = (random() % nElements) + i;// if seeding
        int n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
