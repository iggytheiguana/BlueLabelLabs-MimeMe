//
//  Word.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Word : Resource
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSString* word1;
@property (nonatomic,retain) NSNumber* numberoftimesused;
@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSNumber* difficultylevel;

+ (Word*)createWordWithString:(NSString *)string;

@end
