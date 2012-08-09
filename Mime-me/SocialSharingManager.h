//
//  SocialSharingManager.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 8/7/12.
//  Copyright 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mime.h"

@interface SocialSharingManager : NSObject {
    
}

- (id) init;

- (void) shareMimeOnFacebook:(NSNumber *)mimeID 
                    onFinish:(Callback *)callback 
           trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;

- (void) shareMimeOnTwitter:(NSNumber *)mimeID 
                   onFinish:(Callback *)callback 
          trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;

+ (id) getInstance;

@end
