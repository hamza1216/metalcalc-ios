//
//  VersionManager.m
//  ScrapCalc
//
//  Created by Domovik on 15.08.13.
//
//

#import "AppDelegate_iPhone.h"
#import "AppDelegate_iPad.h"
#import "AppDelegate.h"
#import "VersionManager.h"
#import "PDKeychainBindings.h"
#import "MCPurchaseSettingsViewController.h"

#define USER_DEF        [NSUserDefaults standardUserDefaults]
#define KEY_CHAIN       [PDKeychainBindings sharedKeychainBindings]


static NSString* const kFirstLaunchKey      = @"FirstLaunchKey";
static NSString* const kStartTimeKey        = @"TimestampKey";
static NSString* const kExpireTimeKey       = @"ExpireTimeKey";
static NSString* const kVersionKey          = @"VersionKey";

static double const trialDuration           = 3600 * 24 * 30;   // 1 month
static double const demoDuration            = 3600 * 24 * 90;   // 3 months

@implementation VersionManager


static VersionManager *shared_;

+ (VersionManager *)shared
{
    @synchronized(self) {
        if (shared_ == nil) {
            shared_ = [VersionManager new];
            shared_.didBecomeActive = NO;
//            [shared_ clearKeyChain];
        }
        return shared_;
    }
}


- (id)init
{
    self = [super init];
    if (self) {

        self.currentVersion = [[KEY_CHAIN objectForKey:kVersionKey] intValue];
        if (self.currentVersion == VersionUndefined) {
            self.currentVersion = VersionTrial;
        }
    }
    
    return self;
}

#pragma mark - Private

- (BOOL)_isFirstLaunch
{
    return ![[KEY_CHAIN objectForKey:kFirstLaunchKey] boolValue];
}

- (void)_storeFirstKeyChain
{
    double timestamp = [[NSDate date] timeIntervalSince1970];
    double expirestamp;
    
    if(self.currentVersion == VersionTrial)
        expirestamp = timestamp + trialDuration;
    else if(self.currentVersion == VersionDemo)
        expirestamp = timestamp + demoDuration;
    else if(self.currentVersion == VersionPro)
        expirestamp = [self getProDuration];
    
    [KEY_CHAIN setObject:@"1" forKey:kFirstLaunchKey];
    [KEY_CHAIN setObject:[NSString stringWithFormat:@"%lf", timestamp] forKey:kStartTimeKey];
    [KEY_CHAIN setObject:[NSString stringWithFormat:@"%lf", expirestamp] forKey:kExpireTimeKey];
    [KEY_CHAIN setObject:[NSString stringWithFormat:@"%d", (int)self.currentVersion] forKey:kVersionKey];
    
}

- (void)_storeNewKeyChainWithVersion:(Version) version
{
    [KEY_CHAIN setObject:[NSString stringWithFormat:@"%d", (int)version] forKey:kVersionKey];
    if(version == VersionPro){
        
        double timestamp = [[NSDate date] timeIntervalSince1970];
        double expirestamp = [self getProDuration];
        [KEY_CHAIN setObject:[NSString stringWithFormat:@"%lf", timestamp] forKey:kStartTimeKey];
        [KEY_CHAIN setObject:[NSString stringWithFormat:@"%lf", expirestamp] forKey:kExpireTimeKey];
        
    }
    else if(version == VersionDemo){
        
        double timestamp = [[KEY_CHAIN objectForKey:kStartTimeKey] doubleValue];
        double expirestamp = timestamp + demoDuration;
        [KEY_CHAIN setObject:[NSString stringWithFormat:@"%lf", expirestamp] forKey:kExpireTimeKey];
    }
    else if(version == VersionKeyCode){
        double timestamp = [[KEY_CHAIN objectForKey:kStartTimeKey] doubleValue];
        double expirestamp = timestamp + demoDuration;
        [KEY_CHAIN setObject:[NSString stringWithFormat:@"%lf", expirestamp] forKey:kExpireTimeKey];
    }
    
    self.currentVersion = version;
    [self.delegate versionManagerDidFinishVerification];    
}

- (BOOL)_isExpired
{
    double expirestamp = [[KEY_CHAIN objectForKey:kExpireTimeKey] doubleValue];
    double timestamp = [[NSDate date] timeIntervalSince1970];
    return (timestamp > expirestamp);
}

#pragma mark - Public

- (void)clearKeyChain
{
    [KEY_CHAIN removeObjectForKey:kFirstLaunchKey];
    [KEY_CHAIN removeObjectForKey:kStartTimeKey];
    [KEY_CHAIN removeObjectForKey:kExpireTimeKey];
    [KEY_CHAIN removeObjectForKey:kVersionKey];
    [self.delegate versionManagerDidFinishVerification];
    
}

-(void)verifyVersion{
    
    if([self _isFirstLaunch]){

        self.currentVersion = VersionTrial;
        
        if([self hasOldVersion])
            self.currentVersion = VersionDemo;
        
        if([self isSubscriptionPurchased])
        {
            if ([self hasActiveSubscription])
                self.currentVersion = VersionPro;
            else
                self.currentVersion = VersionExpired;
        }
        
        [self _storeFirstKeyChain];
        
    } else {
        
        self.currentVersion = [[KEY_CHAIN objectForKey:kVersionKey] intValue];
        
        if([self _isExpired] && self.currentVersion != VersionExpired){                 //expired when working
            self.currentVersion = VersionExpired;
            
            if(IS_IPAD){
                AppDelegate_iPad* appDelegate = (AppDelegate_iPad*) [UIApplication sharedApplication].delegate;
                for(UIButton* button in appDelegate.toolbarView.tabBar.buttons){
                    [button setEnabled:NO];                                             //disable when expire
                }
                [appDelegate.toolbarView selectTabIndex:3];
                appDelegate.splitViewController.shouldPresentPurchaseScreen = YES;
                [appDelegate.splitViewController.toolbar selectTabIndex:3];
            } else {
                
                AppDelegate_iPhone* appDelegate = (AppDelegate_iPhone*) [UIApplication sharedApplication].delegate;
                for(UITabBarItem* item in appDelegate.tabBarController.tabBar.items){
                    [item setEnabled:NO];                                       // disable when expire
                }
                [appDelegate.tabBarController setSelectedIndex:4];
                UINavigationController *nav = appDelegate.tabBarController.viewControllers[4];
                [nav popToRootViewControllerAnimated:NO];
                MCPurchaseSettingsViewController* vc = [MCPurchaseSettingsViewController new];
                [nav pushViewController:vc animated:NO];

            }
            [KEY_CHAIN setObject:[NSString stringWithFormat:@"%d", (int)self.currentVersion] forKey:kVersionKey];
            
        }
    }    
    
    [self.delegate versionManagerDidFinishVerification];
    return;
    
}

- (BOOL) isSubscriptionPurchased
{
    NSArray* _SUBSCIPTIONS = [[NSArray alloc] initWithObjects:@"com.mikeburkard.metalcalcplus.1m", @"com.mikeburkard.metalcalcplus.6m", @"com.mikeburkard.metalcalcplus.1y", nil];
    
    BOOL bFlag = NO;
    
    if ([APP_DELEGATE iOS9OrHigher]) {
        
        RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
        for(NSString* featureID in _SUBSCIPTIONS) {
            if([receipt containsInAppPurchaseOfProductIdentifier:featureID])
            {
                bFlag = YES;
                break;
            }
        }
    } else {
        for(NSString* featureID in _SUBSCIPTIONS)
        {
            if([MKStoreManager isFeaturePurchased:featureID])
            {
                bFlag = YES;
                break;
            }
        }
    }
    
    return bFlag;
}

- (BOOL)hasActiveSubscription{
    
    NSArray* _SUBSCIPTIONS = [[NSArray alloc] initWithObjects:@"com.mikeburkard.metalcalcplus.1m", @"com.mikeburkard.metalcalcplus.6m", @"com.mikeburkard.metalcalcplus.1y", nil];
    
    BOOL bFlag = NO;
    
    if ([APP_DELEGATE iOS9OrHigher]) {
        
        RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
        for(NSString* featureID in _SUBSCIPTIONS) {
            if([receipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:featureID forDate:[NSDate date]])
                bFlag = YES;
        }
    } else {
        for(NSString* featureID in _SUBSCIPTIONS) {
            if([[MKStoreManager sharedManager] isSubscriptionActive:featureID])
                bFlag = YES;
        }
    }
    
    return bFlag;
}

- (double)getProDuration{
    
    NSDictionary* _durationDic = @{@"com.mikeburkard.metalcalcplus.1m" : @"2592000",
                                   @"com.mikeburkard.metalcalcplus.6m" : @"15552000",
                                   @"com.mikeburkard.metalcalcplus.1y" : @"31104000"};
    
    double dExpiresDuration = 0;
    
    if ([APP_DELEGATE iOS9OrHigher]) {
        
        RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
        BOOL bFlag = NO;
        for(NSString* featureID in [_durationDic allKeys]) {
            if([receipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:featureID forDate:[NSDate date]])
                bFlag = YES;
        }
        
        if (bFlag) {
            
            for(RMAppReceiptIAP* appReceiptIAP in [receipt inAppPurchases]) {
                
                if ([appReceiptIAP subscriptionExpirationDate] && [[appReceiptIAP subscriptionExpirationDate] timeIntervalSince1970] > dExpiresDuration) {
                    dExpiresDuration = [[appReceiptIAP subscriptionExpirationDate] timeIntervalSince1970];
                }
            }
        }
    } else {
        
        for(NSString* featureID in [_durationDic allKeys])
        {
            if([[MKStoreManager sharedManager] isSubscriptionActive:featureID]) {
                dExpiresDuration = [[MKStoreManager sharedManager] getExpiredDate:featureID];
            }
        }
    }
    
    return dExpiresDuration;
}

- (BOOL)hasOldVersion{
    
    NSString* _OLDVERSION = [NSString stringWithFormat:@"%@", @"com.mikeburkard.metalcalcplus.proversion"];
    if ([APP_DELEGATE iOS9OrHigher]) {
        RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
        return [receipt containsInAppPurchaseOfProductIdentifier:_OLDVERSION];
    } else {
        return [MKStoreManager isFeaturePurchased:_OLDVERSION];
    }
}

- (BOOL)needsAd
{
    Version version = self.currentVersion;
    return ![self _isFirstLaunch]
            && self.didBecomeActive
            && ((version == VersionExpired) || (version == VersionTrial));
}

- (BOOL)canFetchData
{
    return self.currentVersion != VersionExpired;
}

#pragma mark - Dates

- (NSDate *)_expireDate
{
    double expirestamp = [[KEY_CHAIN objectForKey:kExpireTimeKey] doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:expirestamp];
}

- (NSDate *)_startDate
{
    double startstamp = [[KEY_CHAIN objectForKey:kStartTimeKey] doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:startstamp];
}

@end
