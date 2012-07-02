//
//  Comment.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Comment : Resource
@property (nonatomic,retain) NSString* comment1;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSNumber* mimeid;
@end
