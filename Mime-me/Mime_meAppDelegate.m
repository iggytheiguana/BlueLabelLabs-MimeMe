//
//  Mime_meAppDelegate.m
//  Mime-me
//
//  Created by Jasjeet Gill on 6/30/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meAppDelegate.h"
#import "User.h"
#import "CloudEnumerator.h"
#import "CloudEnumeratorFactory.h"
#import "Macros.h"
#import "LoginViewController.h"
#import "Mime_meMenuViewController.h"
#import "ApplicationSettings.h"

@implementation Mime_meAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize applicationSettingsManager = __applicationSettingsManager;
@synthesize authenticationManager = __authenticationManager;
@synthesize facebook = __facebook;
@synthesize progressView = __progressView;
@synthesize deviceToken = m_deviceToken;
@synthesize navigationController = m_navigationController;

#define     kFACEBOOKAPPID  @"496697550344824"
- (UIProgressHUDView*)progressView {
    if (__progressView != nil) {
        return __progressView;
    }
    UIProgressHUDView* pv = [[UIProgressHUDView alloc]initWithWindow:self.window];
    __progressView = pv;
    
    
    return __progressView;
}

- (ApplicationSettingsManager*)applicationSettingsManager {
    if (__applicationSettingsManager != nil) {
        return __applicationSettingsManager;
    }
    __applicationSettingsManager = [ApplicationSettingsManager instance];
    return __applicationSettingsManager;
}

- (Facebook*) facebook {
    if (__facebook != nil) {
        return __facebook;
    }
    
    __facebook = [[Facebook alloc]initWithAppId:kFACEBOOKAPPID];
    
    return __facebook;
    
}

- (AuthenticationManager*) authenticationManager {
    if (__authenticationManager != nil) {
        return __authenticationManager;
    }
    
    __authenticationManager = [AuthenticationManager instance];
    return __authenticationManager;
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [self.navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    NSString* activityName = @"PlatformAppDelegate.applicationDidiFinishLoading:";
    
    [self.applicationSettingsManager settings];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    //register for push notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
    //let us make some checks beginning with the user object
    if ([authenticationManager isUserAuthenticated]) {
        ResourceContext* resourceContext = [ResourceContext instance];
        
        //if the user is logged in, lets check to make sure we have a copy of their user object
        //check to see if the profile picture is empty, if so, lets grab it from fb
        User* currentUser = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID]; 
        
        if (currentUser == nil) {
            //if the user object isnt in the database, we need to fetch it from the web service
            CloudEnumerator* userEnumerator = [[CloudEnumeratorFactory instance]enumeratorForUser:authenticationManager.m_LoggedInUserID];
            
            LOG_SECURITY(0,@"%@Downloading missing user object for user %@ from the cloud", activityName,authenticationManager.m_LoggedInUserID);
            //execute the enumerator
            [userEnumerator enumerateUntilEnd:nil];
        }
        else 
        {
            //we perform a check to update the application version if necessary
            NSString* currentAppVersion = [ApplicationSettingsManager getApplicationVersion];
            
            if ([currentUser.app_version isEqualToString:@""] ||
                ![currentUser.app_version isEqualToString:currentAppVersion] ||
                currentUser.app_version == nil)
            {
                //we need to update the User object because the versions do not match
                currentUser.app_version = currentAppVersion;
                LOG_APPLICATIONSETTINGSMANAGER(0, @"%@Updating user's app version number from %@ to %@",activityName,currentUser.app_version,currentAppVersion);
                [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
            }
            
            // We are ready to launch the menu
            Mime_meMenuViewController* menuViewController = [Mime_meMenuViewController createInstance];
            self.navigationController = [[[UINavigationController alloc]initWithRootViewController:menuViewController] autorelease];
        }
    }
    else {
        // User is not logged in, we need a login
        Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginSuccess:) withContext:nil];        
        Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
        
        // Launch login view controller
        LoginViewController* loginViewController = [LoginViewController createAuthenticationInstance:NO shouldGetTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];
        self.navigationController = [[[UINavigationController alloc]initWithRootViewController:loginViewController] autorelease];
        
    }
    
    // We are ready to launch the menu or the login screen as appropriate
    [self.navigationController hidesBottomBarWhenPushed];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.window.rootViewController = self.navigationController;
    
    self.window.backgroundColor = [UIColor blackColor];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (NSString*) getImageCacheStorageDirectory {
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count])
    {
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        path = [[paths objectAtIndex:0]stringByAppendingPathComponent:bundleName];
    }
    return path;
}

#pragma mark - Login Callback Handlers
- (void) onLoginFailed:(CallbackResult *)result {
    NSString* activityName = @"PlatformAppDelegate.onLoginFailed:";
    
    //need to display an error message to the user
    //TODO: create generic error emssage display
    LOG_SECURITY(1, @"%@Authentication failed",activityName);
}

- (void) onLoginSuccess:(CallbackResult *)result {
    NSString* activityName = @"PlatformAppDelegate.onLoginSuccess:";
    
    LOG_SECURITY(0, @"%@Authentication successful",activityName);
    
    // Successful user login, launch menu
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                     }];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
    
}


- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString* activityName = @"application.didFailToRegisterForRemoteNotificationsWithError:";
    LOG_SECURITY(1, @"%@Device failed to register for notifications:%@",activityName,[error userInfo]);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString* activityName = @"application.didRegisterForRemoteNotificationsWithDeviceToken:";
    self.deviceToken = [[[[deviceToken description]
                          stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    LOG_SECURITY(0, @"%@Device token is %@",activityName,self.deviceToken);
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mime_me" withExtension:@"momd"];
//    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    __managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mime_me.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
