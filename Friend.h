//
//  Friend.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Friend : Resource
@property (nonatomic,retain) NSString* email;
@property (nonatomic,retain) NSNumber* facebookid;
@property (nonatomic,retain) NSNumber* targetuserid;
@property (nonatomic,retain) NSNumber* userid;

@end
