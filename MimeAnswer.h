//
//  MimeAnswer.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface MimeAnswer : Resource
@property (nonatomic,retain) NSString* answer;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSNumber* didusehint;
@property (nonatomic,retain) NSNumber* mimeid;
@property (nonatomic,retain) NSNumber* pointsawarded;
@property (nonatomic,retain) NSNumber* state;
@property (nonatomic,retain) NSString* targetemail;
@property (nonatomic,retain) NSString* targetfacebookid;
@property (nonatomic,retain) NSString* targetuserid;
@end
