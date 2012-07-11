//
//  Word.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Word.h"
#import "AuthenticationManager.h"
#import "User.h"

@implementation Word
@dynamic creatorid;
@dynamic creatorname;
@dynamic numberoftimesused;
@dynamic difficultylevel;
@dynamic word1;

#pragma mark - Static Initializers
//creates a Word object
+ (Word*)createWordWithString:(NSString *)string {
    ResourceContext* resourceContext = [ResourceContext instance];
    Word* retVal = (Word*) [Resource createInstanceOfType:WORD withResourceContext:resourceContext];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    if (user != nil) {
        retVal.creatorid = user.objectid;
        retVal.creatorname = user.username;
    }
    
    retVal.word1 = string;
    retVal.numberoftimesused = [NSNumber numberWithInt:1];
    retVal.difficultylevel = [NSNumber numberWithInt:0];
    
    return retVal;
}

@end
