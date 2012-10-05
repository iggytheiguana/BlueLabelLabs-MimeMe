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
#import "ImageManager.h"

@implementation Contact
@dynamic facebookid;
@dynamic name;
@dynamic email;
@dynamic imageurl;
@dynamic hasinstalled;

#pragma mark - Properties
//- (id)facebookid {
//    return self.facebookid;
//}
//
//- (void)setFacebookid:(NSNumber *)fid
//{
//    self.facebookid = fid;
//}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.facebookid forKey:@"facebookid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.imageurl forKey:@"imageurl"];
    [coder encodeObject:self.hasinstalled forKey:@"hasinstalled"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [[Contact alloc] init];
    if (self != nil)
    {
        self.facebookid = [[coder decodeObjectForKey:@"facebookid"] retain];
        self.name = [[coder decodeObjectForKey:@"name"] retain];
        self.email = [[coder decodeObjectForKey:@"email"] retain];
        self.imageurl = [[coder decodeObjectForKey:@"imageurl"] retain];
        self.hasinstalled = [[coder decodeObjectForKey:@"hasinstalled"] retain];
    }
    return self;
}

- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary
{
  
    NSString* facebookid = [jsonDictionary objectForKey:@"id"];
    NSString* name = [jsonDictionary objectForKey:@"name"];
    NSString* imageurl = [jsonDictionary objectForKey:@"picture"];
    NSNumber* hasinstalled = [jsonDictionary objectForKey:@"installed"];
    
    NSNumber* facebookIDNumber = [facebookid numberValue];
    
    
    self.facebookid = facebookIDNumber;
    self.name  = name;
    
    if (imageurl != nil)
    {
        self.imageurl = imageurl;
    }
    
    if (hasinstalled != nil)
    {
        self.hasinstalled = hasinstalled;
    }
    else {
        self.hasinstalled = [NSNumber numberWithBool:NO];
    }

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
    NSEntityDescription* entity = [NSEntityDescription entityForName:CONTACT inManagedObjectContext:resourceContext.managedObjectContext];
    
    Contact* facebookFriend = [[Contact alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil];
    
    [facebookFriend autorelease];
    return facebookFriend;

}

+ (Contact *)createContactWithName:(NSString *)name
                         withEmail:(NSString *)email
                         withImage:(UIImage *)image
{
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:CONTACT inManagedObjectContext:resourceContext.managedObjectContext];
    Contact *retVal = [[Contact alloc]initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    
    retVal.name = name;
    retVal.email = email;
    retVal.hasinstalled = [NSNumber numberWithBool:NO];
    
    ImageManager* imageManager = [ImageManager instance];
    retVal.imageurl = [imageManager saveImage:image forContactWithManagedObjectID:retVal.objectID];
    
    [retVal autorelease];
    return retVal;
    
}

@end
