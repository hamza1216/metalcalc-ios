/*
 *  AppDelegate.c
 *  ScarpCalc
 *
 *  Created by admin on 3/1/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#import "AppDelegate.h"
#import "ModalActivityIndicator.h"
#import "ModelManager.h"
#import "GAI.h"
#import "SecureUDID.h"
#import "NSURLConnection+Blocks.h"
#import "ACTReporter.h"
#import "Firebase.h"

static NSString *const GA_TRACKING_ID = @"UA-42010034-1";

typedef void (^BackgroundCompletionBlock)(UIBackgroundFetchResult);

@interface AppDelegate ()
{
    ModalActivityIndicator *_loadIndicator;
    RMStoreAppReceiptVerificator *_receiptVerificator;
    RMStoreKeychainPersistence *_persistence;
}

@property (nonatomic, readonly) ModalActivityIndicator *loadIndicator;
@property (nonatomic, strong) BackgroundCompletionBlock completionBlock;

- (void)setupGoogleAnalytics;

@end


@implementation AppDelegate

- (ModalActivityIndicator *)loadIndicator
{
	if (_loadIndicator == nil) {
		_loadIndicator = [[ModalActivityIndicator alloc] init];
		[self.window.rootViewController.view addSubview:_loadIndicator];
	}
    _loadIndicator.frame = self.window.rootViewController.view.bounds;
	return _loadIndicator;
}

- (UIView *)viewForBanner
{
    return nil;
}

- (void)showLoadingIndicator
{
    [[self loadIndicator] start];
}

- (void)hideLoadingIndicator
{
    [[self loadIndicator] stop];
}

- (void)configureStore
{    
    _receiptVerificator = [[RMStoreAppReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = _receiptVerificator;
    
    _persistence = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = _persistence;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [InMobi initialize:INMOBI_APPID];
    [InMobi setLogLevel:IMLogLevelDebug];
    
    //GoogleConversationTracking Initialize
    [ACTConversionReporter reportWithConversionID:kConversationID
                                            label:kConversationLabel
                                            value:kConversationValue
                                     isRepeatable:NO];
    
    if ([self iOS9OrHigher]) {
        [self configureStore];
    } else {
        //MKStoreKit Initialize
        [MKStoreManager sharedManager];
    }
    
    [self setupGoogleAnalytics];
    [[VersionManager shared] setDidBecomeActive:YES];
	[self.window makeKeyAndVisible];
    
    // Configure Firebase
    [FIRApp configure];
    
    if([FIRAuth auth].currentUser){
        // User is signed in
        NSLog(@"Already signed in: %@", [FIRAuth auth].currentUser.uid)
        [[ModelManager shared] setupFirebase];
    }
    else{
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (error){
                // signin failed
                NSLog(@"Signin Failed: %@", error)
            }
            else{
                NSLog(@"User: %@", [FIRAuth auth].currentUser.uid)
                [[ModelManager shared] setupFirebase];
            }
        }];
         
    }
    
/*
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        if (IS_IOS7) {
            [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        }
        else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
    }
#else
    if (IS_IOS7) {
        [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
#endif
*/
    application.applicationIconBadgeNumber = 0;
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) ) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

        //if( option != nil )
        //{
        //    NSLog( @"registerForPushWithOptions:" );
        //}
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if( !error ) {
            // required to get the app to do anything at all about push notifications
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            NSLog( @"Push registration success." );
        } else {
            NSLog( @"Push registration FAILED" );
            NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
            NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
        }
        }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    [[VersionManager shared] setDidBecomeActive:YES];
    //[[self activeViewController] viewWillAppear:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    for (Metal *metal in [[ModelManager shared] metals]) {
        if (metal.pushOption.isOn == PushOptionTypeBadge) {
            NSInteger badge = (NSInteger)round(metal.bidPrice);
            application.applicationIconBadgeNumber = badge;
            return;
        }
    }
    application.applicationIconBadgeNumber = 0;
}

//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    [INAPP_PURCHASE setObserverEnabled:NO];
//}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [INAPP_PURCHASE setObserverEnabled:YES];
    [[VersionManager shared] setDidBecomeActive:YES];
    NSLog(@"\n\n\n\n!!foreground!!\n\n\n");
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{    
    if ([self iOS9OrHigher]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationsResponse" object:nil];
    }

    const unsigned *tokenBytes = [devToken bytes];
    NSString *deviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
//    NSString *udid = [SecureUDID UDIDForDomain:@"com.mikeburkard.metalcalcplus" usingKey:@"the_harDesT_Key-ToGuess_evEr1111"];
    NSString* udid = [[FIRAuth auth] currentUser].uid;

    if(udid == nil){
        return;
    }
    [[ModelManager shared] setToken:deviceToken];
    [[ModelManager shared] setUdid:udid];
    
    NSLog(@"INITIAL REQUEST");
    
    NSString* membership = @"trial";
    if([VersionManager shared].currentVersion == VersionTrial)
        membership = @"tiral";
    else if([VersionManager shared].currentVersion == VersionDemo)
        membership = @"demo";
    else if([VersionManager shared].currentVersion == VersionPro)
        membership = @"pro";
    else if([VersionManager shared].currentVersion == VersionExpired)
        membership = @"expired";
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRDatabaseReference* userinfoRef = [[ref child:@"users"] child:udid];
    
    NSDictionary* dictionary = @{@"device_token": deviceToken,
                                 @"membership": membership
    };
    [userinfoRef setValue:dictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        static NSString* const key = @"ScrapCalc.AppDelegate.FirstLaunch";
        NSUserDefaults *usr = [NSUserDefaults standardUserDefaults];
        if ([usr objectForKey:key] == nil) {
            
            Metal *gold = [[ModelManager shared] metalForID:1];
            [[ModelManager shared] updatePushOptionsForMetal:gold withInfo:@{ kPushIsOn:@(PushOptionTypeBadge) }];
            
            [usr setObject:@"1" forKey:key];
            [usr synchronize];
        }
    }];
    
/*
    NSString *urlStr = @"http://burkardsolutions.com/iphone/insertgeneraluser_new.php";
    NSLog(@"URL: %@", urlStr);
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
	[postRequest setHTTPMethod:@"POST"];
    
    NSString *bodyStr = [NSString stringWithFormat:@"udid=%@&devicetoken=%@", udid, deviceToken];
    NSLog(@"BODY: %@", bodyStr);
    
    NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest setHTTPBody:body];
    
    [NSURLConnection asyncRequest:postRequest
                          success:^(NSData *data, NSURLResponse *response) {
                              NSLog(@"INITIAL RESPONSE: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
                              
                              static NSString* const key = @"ScrapCalc.AppDelegate.FirstLaunch";
                              NSUserDefaults *usr = [NSUserDefaults standardUserDefaults];
                              if ([usr objectForKey:key] == nil) {
                                  
                                  Metal *gold = [[ModelManager shared] metalForID:1];
                                  [[ModelManager shared] updatePushOptionsForMetal:gold withInfo:@{ kPushIsOn:@(PushOptionTypeBadge) }];
                                  
                                  [usr setObject:@"1" forKey:key];
                                  [usr synchronize];
                              }
                          }
                          failure:^(NSData *data, NSError *error) {
                              NSLog(@"FAILURE: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
                              NSLog(@"ERROR: %@", error.localizedDescription);
                          }];
     */
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([self iOS9OrHigher]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationsResponse" object:nil];
    }
    NSLog(@"fail");
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    completionHandler(UNNotificationPresentationOptionAlert);
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    completionHandler();
}
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    self.completionBlock = completionHandler;
    [[ModelManager shared] fetchBidsWithDelegate:self];
}

- (void)_backgroundCompletedWithResult:(UIBackgroundFetchResult)result
{
    NSLog(@"Background Fetch Completed: %d", result);
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionBlock) {
                self.completionBlock(result);
                self.completionBlock = nil;
            }
        });
    }
    @catch (NSException *exc) {
    }
}

#pragma mark - ModelManager delegate | For fetching data in background

- (void)didReceiveNewBids
{
    NSArray *metals = [[ModelManager shared] changedMetals];
    if (metals.count > 0) {
        
        NSMutableString *str = [NSMutableString string];
        UILocalNotification *notif = [UILocalNotification new];
        
        
        for (Metal *metal in metals) {
            
            NSLog(@"%f", metal.bidChange);
            if (metal.pushOption.isOn == PushOptionTypeBadge) {
                [str appendFormat:@"%@ is now %.2f\n", metal.name, metal.bidPrice];
                notif.applicationIconBadgeNumber = (NSInteger)round(metal.bidPrice);
            }
            if(metal.pushOption.isOn == PushOptionTypeThreshold)
            {
                if(metal.bidPrice <= metal.pushOption.minValue)
                {
                    [str appendFormat:@"%@ has went below %.2f and is now %.2f\n", metal.name, metal.pushOption.minValue, metal.bidPrice];
                }
                else if(metal.bidPrice >= metal.pushOption.maxValue)
                {
                    [str appendFormat:@"%@ has went over %.2f and is now %.2f\n", metal.name, metal.pushOption.maxValue, metal.bidPrice];
                }
                else
                {
                    if(metal.bidChange >0)
                    {
                        [str appendFormat:@"%@ has went over %.2f and is now %.2f\n", metal.name, metal.pushOption.minValue, metal.bidPrice];
                    }
                    else
                    {
                        [str appendFormat:@"%@ has went below %.2f and is now %.2f\n", metal.name, metal.pushOption.maxValue, metal.bidPrice];
                    }
                }
            }
        }
        
        notif.alertBody = str;
        notif.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        [notif release];
    }
    
    [self _backgroundCompletedWithResult:UIBackgroundFetchResultNewData];
}

- (void)didFailReceivingBidsError:(NSError *)error
{
    [self _backgroundCompletedWithResult:UIBackgroundFetchResultFailed];
}

- (void)didForbidReceiveBids
{
    [self _backgroundCompletedWithResult:UIBackgroundFetchResultFailed];
}

#pragma mark -

- (BOOL)iOS9OrHigher
{
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (version.majorVersion>=9) {
        return YES;
    } else {
        return NO;
    }
}

- (UIViewController *)activeViewController
{
    return nil;
}

#pragma mark - Private methods

- (void)setupGoogleAnalytics
{
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [[GAI sharedInstance] setDispatchInterval:20];
    [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKING_ID];
}

#pragma mark - Memory management

- (void)dealloc
{
    self.window = nil;
    [super dealloc];
}

@end
