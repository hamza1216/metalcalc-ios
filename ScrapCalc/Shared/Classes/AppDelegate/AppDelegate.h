//
//  AppDelegate.h
//  ScarpCalc
//
//  Created by admin on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "VersionManager.h"
#import "ModelManager.h"
#import "MKStoreManager.h"
#import "ACTReporter.h"
#import "RMStore.h"
#import "RMStoreTransactionReceiptVerificator.h"
#import "RMStoreAppReceiptVerificator.h"
#import "RMStoreKeychainPersistence.h"
#import "RMAppReceipt.h"

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define ADMOB_UNITID        @"ca-app-pub-7007672671551093/9096254937"

//GoogleConversation Account
#define kConversationID     @"1070155276"
#define kConversationLabel  @"UawKCJjZ3wkQjIyl_gM"
#define kConversationValue  @"1.000000"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@class ModalActivityIndicator;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarDelegate, UIAlertViewDelegate, UNUserNotificationCenterDelegate, ModelManagerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (UIViewController *)activeViewController;
- (BOOL)iOS9OrHigher;

- (void)showLoadingIndicator;
- (void)hideLoadingIndicator;

@end
