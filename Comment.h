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
@property (nonatomic,retain) NSNumber* mimeanswerid;
@property (nonatomic,retain) NSNumber* mimeid;
@property (nonatomic,retain) NSNumber* hasseen;

+ (Comment *)createCommentWithString:(NSString *)string forMimeID:(NSNumber *)mimeID forMimeAnswerID:(NSNumber *)mimeAnswerID;

@end
