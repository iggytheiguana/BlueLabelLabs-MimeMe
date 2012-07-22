//
//  FacebookFriend.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"
#import <CoreData/CoreData.h>
@interface FacebookFriend : NSManagedObject <IJSONSerializable>

@property (nonatomic,copy) NSNumber* facebookid;
@property (nonatomic,copy) NSString* name;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity 
    insertIntoResourceContext:(ResourceContext*)resourceContext;
+ (id)          createInstanceFromJSON:(NSDictionary*)jsonDictionary;

@end
