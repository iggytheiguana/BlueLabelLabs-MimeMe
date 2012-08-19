//
//  Mime.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Mime : Resource


@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSNumber* numberofattempts;
@property (nonatomic,retain) NSNumber* numberoftimesviewed;
@property (nonatomic,retain) NSNumber* numbertimesanswered;
@property (nonatomic,retain) NSString* thumbnailurl;
@property (nonatomic,retain) NSNumber* visibility;
@property (nonatomic,retain) NSString* word;
@property (nonatomic,retain) NSNumber* wordid;
@property (nonatomic,retain) NSNumber* ispublic;
@property (nonatomic,retain) NSNumber* isstaffpick;
@property (nonatomic,retain) NSNumber* isfavorite;
@property (nonatomic,retain) NSNumber* hasanswered;
@property (nonatomic,retain) NSNumber* numberofflags;
@property (nonatomic,retain) NSString* creatorimageurl;
@property (nonatomic,retain) NSNumber* numberoftimesfavorited;
@property (nonatomic,retain) NSNumber* hasseen;

+ (Mime*)createMimeWithWordID:(NSNumber *)wordID
                    withImage:(UIImage *)image
                withThumbnail:(UIImage *)thumbnailImage;

@end
