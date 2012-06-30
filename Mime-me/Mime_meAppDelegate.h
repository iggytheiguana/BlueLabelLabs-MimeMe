//
//  Mime_meAppDelegate.h
//  Mime-me
//
//  Created by Jasjeet Gill on 6/30/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "AuthenticationManager.h"
#import "ApplicationSettingsManager.h"
@interface Mime_meAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString* m_deviceToken;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain)           Facebook    *facebook;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) ApplicationSettingsManager*   applicationSettingsManager;
@property (nonatomic, retain) NSString* deviceToken;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
