//
//  MimeAnswer.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "MimeAnswer.h"
#import "AuthenticationManager.h"
#import "User.h"

@implementation MimeAnswer
@dynamic answer;
@dynamic creatorname;
@dynamic creatorid;
@dynamic didusehint;
@dynamic mimeid;
@dynamic pointsawarded;
@dynamic state;
@dynamic targetemail;
@dynamic targetfacebookid;
@dynamic targetuserid;
@dynamic issentbyfriend;

#pragma mark - Static Initializers
//creates a Mime object
+ (MimeAnswer*)createMimeAnswerWithMimeID:(NSNumber *)mimeID
                         withTargetUserID:(NSNumber *)targetUserID
                                 isPublic:(BOOL)isPublic {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    MimeAnswer *retVal = (MimeAnswer*)[Resource createInstanceOfType:MIMEANSWER withResourceContext:resourceContext];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    User *user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    if (user != nil) {
        retVal.creatorid = user.objectid;
        retVal.creatorname = user.username;
    }
    
    retVal.mimeid = mimeID;
    retVal.targetuserid = [targetUserID stringValue];
    
    User *targetUser = (User*)[resourceContext resourceWithType:USER withID:targetUserID];
    if (targetUser != nil) {
        retVal.targetfacebookid = [targetUser.fb_user_id stringValue];
        retVal.targetemail = user.email;
    }
    else {
        retVal.targetfacebookid = nil;
        retVal.targetemail = nil;
    }
    
    retVal.didusehint = [NSNumber numberWithBool:NO];
    retVal.issentbyfriend = [NSNumber numberWithBool:!isPublic];
    retVal.pointsawarded = [NSNumber numberWithInt:0];
    retVal.state = [NSNumber numberWithInt:0];
    
    retVal.answer = nil;
    
    return retVal;
}

@end
