//
//  User.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "User.h"
#import <CoreData/CoreData.h>
#import "ResourceContext.h"
#import "DateTimeHelper.h"
#import "Feed.h"
#import "Attributes.h"
@implementation User

@dynamic email;
@dynamic firstname;
@dynamic lastname;
@dynamic numcompleted;
@dynamic lastposition;


- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext* appContext = resourceContext.managedObjectContext;
    NSEntityDescription* entity = [NSEntityDescription entityForName:USER inManagedObjectContext:appContext];
    return [super initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:resourceContext];
}


@end
