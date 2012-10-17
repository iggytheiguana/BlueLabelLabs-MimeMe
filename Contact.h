//
//  Contact.h
//  Mime-me
//
//  Created by Jasjeet Gill on 7/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"
#import <CoreData/CoreData.h>

@interface Contact : NSManagedObject <IJSONSerializable>

@property (nonatomic,copy) NSNumber* facebookid;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* email;
@property (nonatomic,copy) NSString* imageurl;
@property (nonatomic,copy) NSNumber* hasinstalled;

- (NSDictionary *) toJSONDictionary;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity 
    insertIntoResourceContext:(ResourceContext*)resourceContext;

+ (id) createInstanceFromJSON:(NSDictionary *)jsonDictionary isFromFacebook:(BOOL)isFromFacebook;

+ (Contact *)createContactWithName:(NSString *)name
                         withEmail:(NSString *)email
                         withImage:(UIImage *)image;

@end
