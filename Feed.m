//
//  Feed.m
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Feed.h"
#import "JSONKit.h"
#import "FeedTypes.h"
#import "Attributes.h"
#import "AuthenticationManager.h"

@implementation Feed
@dynamic message;
@dynamic feedevent;
@dynamic userid;
@dynamic hasopened;
@dynamic dateexpires;
@dynamic imageurl;
@dynamic rendertype;
@dynamic html;


@synthesize feeddata = __feeddata;

#pragma mark - Properties
- (NSArray*) feeddata {
    if (__feeddata != nil) {
        return __feeddata;
    }
    
    //we need to loop through all of the elements of the feeddatas array on the object
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    NSArray* feedDataArray = [self valueForKey:@"feeddatas"];
    
    for (NSDictionary* feedObjectDictionary in feedDataArray) {
        //we now need to cast each dictionary into a FeedData object
        FeedData* fData = [[FeedData alloc]initFromJSONDictionary:feedObjectDictionary];
        [retVal addObject:fData];
        [fData release];
    }
    
    //we now have an array created with all items deserialized, let us save it
    __feeddata = retVal;
    return __feeddata;
}

- (void) dealloc {
    [__feeddata release];
    [super dealloc];
}

//returns the number of unexpired, unopened new Mime notifications for this user in the database
+ (int) unopenedNotificationsForFeedEvent:(int)feedEvent
{
    NSNumber* loggedInUserID = [[AuthenticationManager instance] m_LoggedInUserID];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
    
    NSArray *values = [NSArray arrayWithObjects:[loggedInUserID stringValue], feedEvent, nil];
    NSArray *attributes = [NSArray arrayWithObjects:USERID, FEEDEVENT, nil];
    
    NSArray* feedObjects = [resourceContext resourcesWithType:FEED withValuesEqual:values forAttributes:attributes sortBy:[NSArray arrayWithObject:sortDescriptor]];
    
    int count = 0;
    //get the current date
    double date = [[NSDate date] timeIntervalSince1970];
    
    for (Feed* feed in feedObjects) 
    {
        if ([feed.dateexpires doubleValue] > date && [feed.hasopened boolValue] == NO) {
            //its unexpired and unopened
            count++;
        }
    }
    return count;
}

@end
