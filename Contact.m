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


- (NSDictionary *) toJSONDictionary {
    NSMutableDictionary *jContact = [[[NSMutableDictionary alloc] init] autorelease];
    
    if (self.facebookid != nil) {
        [jContact setObject:self.facebookid forKey:@"id"];
    }
    
    if (self.name != nil) {
        [jContact setObject:self.name forKey:@"name"];
    }
    
    if (self.email != nil) {
        [jContact setObject:self.email forKey:@"email"];
    }
    
    if (self.imageurl != nil) {
        [jContact setObject:self.imageurl forKey:@"url"];
    }
    
    if (self.hasinstalled != nil) {
        [jContact setObject:self.hasinstalled forKey:@"installed"];
    }
    
    return jContact;
}

- (void) readAttributesFromFacebookJSONDictionary:(NSDictionary*)jsonDictionary
{
  
    NSString* facebookid = [jsonDictionary objectForKey:@"id"];
    NSString* name = [jsonDictionary objectForKey:@"name"];

    NSNumber* hasinstalled = [jsonDictionary objectForKey:@"installed"];
    
    NSNumber* facebookIDNumber = [facebookid numberValue];
    
    
    self.facebookid = facebookIDNumber;
    self.name  = name;
    
    NSDictionary* imageDictionary = [jsonDictionary objectForKey:@"picture"];
    NSDictionary* dataDictionary = [imageDictionary objectForKey:@"data"];
    
    
    NSString* imageurl = [dataDictionary objectForKey:@"url"];
    
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

- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary
{
    
    NSNumber* facebookid = [jsonDictionary objectForKey:@"id"];
    NSString* name = [jsonDictionary objectForKey:@"name"];
    NSString* email = [jsonDictionary objectForKey:@"email"];
    
    NSNumber* hasinstalled = [jsonDictionary objectForKey:@"installed"];
    
//    NSNumber* facebookIDNumber = [facebookid numberValue];
    
    
    self.facebookid = facebookid;
    self.name  = name;
    self.email  = email;
    
    NSString* imageurl = [jsonDictionary objectForKey:@"url"];
    
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
               isFromFacebook:(BOOL)isFromFacebook
{
    if (resourceContext != nil) {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    }
    else {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:nil];
    }
    
    if (self)  {
        if (isFromFacebook == YES) {
            [self readAttributesFromFacebookJSONDictionary:jsonDictionary];
        }
        else {
            [self readAttributesFromJSONDictionary:jsonDictionary];
        }
    }
    return self;

}

+ (id) createInstanceFromJSON:(NSDictionary *)jsonDictionary isFromFacebook:(BOOL)isFromFacebook
{
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:CONTACT inManagedObjectContext:resourceContext.managedObjectContext];
    
    Contact* facebookFriend = [[Contact alloc] initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil isFromFacebook:isFromFacebook];
    
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
