//
//  BaseViewController.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIViewCategory.h"
#import "UIProgressHUDView.h"

#import "AuthenticationManager.h"
#import "User.h"
#import "UILoginView.h"
#import "FeedManager.h"
#import "EventManager.h"
#import "CallbackResult.h"
#import "Request.h"
#import "UICustomAlertView.h"

@class UICameraActionSheet;
@class ResourceContext;

@interface BaseViewController : UIViewController < UIAlertViewDelegate > {
    UILoginView*            m_loginView;
}

@property (nonatomic, retain) FeedManager*              feedManager;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) EventManager*             eventManager;


@property (nonatomic, retain) User*                     loggedInUser;
@property (nonatomic, retain) UILoginView*              loginView;

- (void)authenticate:(BOOL)facebook 
         withTwitter:(BOOL)twitter 
    onFinishSelector:(SEL)sel 
      onTargetObject:(id)targetObject 
          withObject:(id)parameter;

- (void)authenticateAndGetFacebook:(BOOL)getFaceobook 
                        getTwitter:(BOOL)getTwitter 
                 onSuccessCallback:(Callback*)successCallback 
                 onFailureCallback:(Callback*)failCallback;

- (void) onUserLoggedIn:(CallbackResult*)result;
- (void) onUserLoggedOut:(CallbackResult*)result;

- (void)showProgressBar:(NSString*)message 
         withCustomView:(UIView*)view 
 withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds;

- (void)showProgressBar:(NSString*)message 
         withCustomView:(UIView*)view 
 withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds
    showFinishedMessage:(BOOL)showFinishedMessage;


- (void)showDeterminateProgressBarWithMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds
                      withHeartbeat:(NSNumber*)heartbeatInSeconds 
                   onSuccessMessage:(NSString*)successMessage 
                   onFailureMessage:(NSString*)failureMessage 
                 inProgressMessages:(NSArray*)progressMessages;

- (void)showDeterminateProgressBarWithMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds 
                   onSuccessMessage:(NSString*)successMessage 
                   onFailureMessage:(NSString*)failureMessage 
                 inProgressMessages:(NSArray*)progressMessages; 
    

- (void)hideProgressBar;

- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
