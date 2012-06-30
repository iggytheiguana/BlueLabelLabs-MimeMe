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
@property (nonatomic,retain) NSString* email;
@property (nonatomic,retain) NSString* firstname;
@property (nonatomic,retain) NSString* lastname;
@property (nonatomic,retain) NSNumber* numcompleted;
@property (nonatomic,retain) NSNumber* lastposition;



@end
