//
//  SocialSharingManager.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 8/7/12.
//  Copyright 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "SocialSharingManager.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "Request.h"
#import "RequestManager.h"
#import "UrlManager.h"
#import "Macros.h"

@implementation SocialSharingManager


#pragma mark - Instance Management

static  SocialSharingManager* sharedManager;

+ (id) getInstance {
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        }        
        return sharedManager;
    }
}

#pragma mark - Initializer
- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)        share:(NSURL*)url 
   withSharingOptions:(SharingOptions*)sharingOptions 
             onFinish:(Callback*)callback 
    trackProgressWith:(id<RequestProgressDelegate>)progressDelegate 
{
    Request* request = [Request createInstanceOfRequest];
    request.url = [url absoluteString];
    request.onFailCallback = callback;
    request.onSuccessCallback = callback;
    request.operationcode =[NSNumber numberWithInt:kSHARE];
    request.delegate = progressDelegate;
     [request updateRequestStatus:kPENDING];
    //request.statuscode = [NSNumber numberWithInt:kPENDING];
    
    [progressDelegate initializeWith:[NSArray arrayWithObject:request]];
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];

}


#pragma mark - Sharing Methods
- (void) shareMimeOnFacebook:(NSNumber *)mimeID 
                    onFinish:(Callback *)callback 
           trackProgressWith:(id<RequestProgressDelegate>)progressDelegate
{
    NSString* activityName = @"SocialSharingManager.shareMimeOnFacebook:";
    SharingOptions* sharingOptions = [SharingOptions shareOnFacebook];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:mimeID withObjectType:MIME withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }
}

- (void) shareMimeOnTwitter:(NSNumber *)mimeID 
                   onFinish:(Callback *)callback 
          trackProgressWith:(id<RequestProgressDelegate>)progressDelegate
{
    NSString* activityName = @"SocialSharingManager.shareMimeOnTwitter:";
    SharingOptions* sharingOptions = [SharingOptions shareOnTwitter];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:mimeID withObjectType:MIME withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }

}

@end
