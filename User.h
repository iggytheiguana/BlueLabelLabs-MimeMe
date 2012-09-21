//
//  User.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface User : Resource {
    
}
@property (nonatomic,retain) NSNumber* achievementthreshold;
@property (nonatomic,retain) NSString* app_version;
@property (nonatomic,retain) NSString* devicetoken;
@property (nonatomic,retain) NSString* displayname;
@property (nonatomic,retain) NSString* email;
@property (nonatomic,retain) NSNumber* fb_user_id;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSNumber* numberfollowing;
@property (nonatomic,retain) NSNumber* numberoffollowers;
@property (nonatomic,retain) NSNumber* numberofpoints;
@property (nonatomic,retain) NSNumber* numberofpointslw;
@property (nonatomic,retain) NSNumber* numberofpointssw;
@property (nonatomic,retain) NSNumber* prevachievementthreshold;
@property (nonatomic,retain) NSNumber* sharinglevel;
@property (nonatomic,retain) NSString* thumbnailurl;
@property (nonatomic,retain) NSString* twitter_user_id;
@property (nonatomic,retain) NSString* username;
@property (nonatomic,retain) NSNumber* state;

+ (int) unopenedNotificationsFor:(NSNumber*)objectid;

@end
