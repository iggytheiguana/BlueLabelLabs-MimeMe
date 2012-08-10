//
//  Mime.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "Word.h"
#import "ImageManager.h"

@implementation Mime
@dynamic creatorid;
@dynamic creatorname;
@dynamic imageurl;
@dynamic numberofattempts;
@dynamic numberoftimesviewed;
@dynamic numbertimesanswered;
@dynamic thumbnailurl;
@dynamic visibility;
@dynamic word;
@dynamic wordid;
@dynamic ispublic;
@dynamic isstaffpick;
@dynamic hasanswered;
@dynamic isfavorite;
@dynamic numberofflags;
#pragma mark - Static Initializers
//creates a Mime object
+ (Mime*)createMimeWithWordID:(NSNumber *)wordID
                    withImage:(UIImage *)image
                withThumbnail:(UIImage *)thumbnailImage {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *retVal = (Mime*)[Resource createInstanceOfType:MIME withResourceContext:resourceContext];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    User *user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    if (user != nil) {
        retVal.creatorid = user.objectid;
        retVal.creatorname = user.username;
    }
    
    retVal.wordid = wordID;
    Word *word = (Word*)[resourceContext resourceWithType:WORD withID:wordID];
    retVal.word = word.word1;
    
    ImageManager* imageManager = [ImageManager instance];
    retVal.imageurl = [imageManager saveImage:image forMimeWithID:retVal.objectid];
    retVal.thumbnailurl = [imageManager saveThumbnailImage:thumbnailImage forMimeWithID:retVal.objectid];
    
    retVal.numberofattempts = [NSNumber numberWithInteger:0];
    retVal.numberoftimesviewed = [NSNumber numberWithInteger:0];
    retVal.numbertimesanswered = [NSNumber numberWithInteger:0];
    
    retVal.visibility = [NSNumber numberWithInt:0];
    
    retVal.ispublic = [NSNumber numberWithBool:NO];
    retVal.isstaffpick = [NSNumber numberWithBool:NO];
    retVal.hasanswered = [NSNumber numberWithBool:NO];
    retVal.isfavorite = [NSNumber numberWithBool:NO];
    
    return retVal;
}

@end
