//
//  Contact.m
//  Mime-me
//
//  Created by Jasjeet Gill on 7/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Contact.h"
#import "Attributes.h"
#import "Resource.h"
#import "ResourceContext.h"
#import "Types.h"
#import "NSStringGUIDCategory.h"
#import "Macros.h"

@implementation Contact
@dynamic facebookid;
@dynamic name;
@dynamic email;

- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary
{
  
    NSString* facebookid = [jsonDictionary objectForKey:@"id"];
    NSString* name = [jsonDictionary objectForKey:@"name"];
    
    NSNumber* facebookIDNumber = [facebookid numberValue];
    
    self.facebookid = facebookIDNumber;
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
    
    Contact* facebookFriend = [[Contact alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil];
    
    [facebookFriend autorelease];
    return facebookFriend;

}

+ (Contact *)createContactWithName:(NSString *)name
                          withEmail:(NSString *)email
{
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:FACEBOOKFRIEND inManagedObjectContext:resourceContext.managedObjectContext];
    Contact *retVal = [[Contact alloc]initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    
    retVal.name = name;
    retVal.email = email;
    [retVal autorelease];
    return retVal;
    
}

@end
