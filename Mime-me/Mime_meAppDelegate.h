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
#import "UIProgressHUDView.h"

@interface Mime_meAppDelegate : UIResponder < UIApplicationDelegate, CloudEnumeratorDelegate > {
    NSString*               m_deviceToken;
    
    UINavigationController  *m_navigationController;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;
@property (nonatomic, retain)           Facebook                        *facebook;
@property (nonatomic, retain)           AuthenticationManager*          authenticationManager;
@property (nonatomic, retain)           ApplicationSettingsManager*     applicationSettingsManager;
@property (nonatomic, retain)           UIProgressHUDView*              progressView;
@property (nonatomic, retain)           NSString*                       deviceToken;

@property (nonatomic, strong)           UINavigationController          *navigationController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*) getImageCacheStorageDirectory;

@end
