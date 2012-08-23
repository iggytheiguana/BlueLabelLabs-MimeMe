//
//  Comment.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Comment.h"
#import "AuthenticationManager.h"
#import "User.h"

@implementation Comment
@dynamic mimeanswerid;
@dynamic comment1;
@dynamic creatorname;
@dynamic creatorid;
@dynamic mimeid;
@dynamic hasseen;

#pragma mark - Static Initializers
//creates a Comment object
+ (Comment *)createCommentWithString:(NSString *)string forMimeID:(NSNumber *)mimeID forMimeAnswerID:(NSNumber *)mimeAnswerID {
    ResourceContext* resourceContext = [ResourceContext instance];
    Comment* retVal = (Comment*) [Resource createInstanceOfType:COMMENT withResourceContext:resourceContext];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    if (user != nil) {
        retVal.creatorid = user.objectid;
        retVal.creatorname = user.username;
    }
    
    retVal.comment1 = string;
    retVal.mimeid = mimeID;
    retVal.mimeanswerid = mimeAnswerID;
    retVal.hasseen = [NSNumber numberWithBool:NO];
    
    return retVal;
}


@end
