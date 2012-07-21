//
//  FacebookFriend.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "FacebookFriend.h"
#import "Attributes.h"
#import "ResourceContext.h"
#import "Types.h"
#import "NSStringGUIDCategory.h"
#import "Macros.h"

@implementation FacebookFriend
@dynamic facebookid;
@dynamic name;


- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary
{
  
    NSString* facebookid = [jsonDictionary objectForKey:@"id"];
    NSString* name = [jsonDictionary objectForKey:@"name"];
    
    
    
    self.facebookid = [facebookid numberValue];
    self.name  = name;


}

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity 
    insertIntoResourceContext:(ResourceContext*)resourceContext
{
    if (resourceContext != nil) {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    }
    else {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:nil];
    }
    
    if (self)  {
        
        [self readAttributesFromJSONDictionary:jsonDictionary];     
        
        
        
        
    }
    return self;

}
+ (id) createInstanceFromJSON:(NSDictionary *)jsonDictionary
{
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:FACEBOOKFRIEND inManagedObjectContext:resourceContext.managedObjectContext];
    
    FacebookFriend* facebookFriend = [[FacebookFriend alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil];
    
    [facebookFriend autorelease];
    return facebookFriend;

}
@end
