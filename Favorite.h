//
//  Favorite.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Favorite : Resource
@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSNumber* mimeid;
@end
