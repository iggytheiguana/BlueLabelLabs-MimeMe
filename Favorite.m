//
//  Favorite.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Favorite.h"
#import "AuthenticationManager.h"
#import "User.h"

@implementation Favorite
@dynamic userid;
@dynamic mimeid;

#pragma mark - Static Initializers
//creates a Favorite object
+ (Favorite*)createFavoriteWithMimeID:(NSNumber *)mimeID {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Favorite *retVal = (Favorite*)[Resource createInstanceOfType:FAVORITE withResourceContext:resourceContext];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    User *user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    if (user != nil) {
        retVal.userid = user.objectid;
    }
    
    retVal.mimeid = mimeID;
    
    return retVal;
}

@end
