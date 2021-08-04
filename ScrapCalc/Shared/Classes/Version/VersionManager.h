//
//  VersionManager.h
//  ScrapCalc
//
//  Created by Domovik on 15.08.13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ServerManager.h"

typedef NS_ENUM(NSInteger, Version) {
    VersionUndefined,
    VersionTrial, //1 month
    VersionDemo, //3 months (after old Pro)
    VersionPro,
    VersionExpired,
    VersionKeyCode
};

@protocol VersionManagerDelegate

- (void)versionManagerDidFinishVerification;

@end

@interface VersionManager : NSObject <ServerManagerDelegate>

@property (nonatomic, assign) Version currentVersion;
@property (nonatomic, assign) BOOL didBecomeActive;
@property (nonatomic, assign) BOOL wasFirstLaunch;
@property (nonatomic, assign) NSObject<VersionManagerDelegate> *delegate;

+ (VersionManager *)shared;

- (id)init;
- (BOOL)_isFirstLaunch;
- (void)_storeFirstKeyChain;
- (void)_storeNewKeyChainWithVersion:(Version) version;
- (BOOL)_isExpired;
- (void)clearKeyChain;
- (void)verifyVersion;
- (BOOL)hasActiveSubscription;
- (BOOL)hasOldVersion;
- (BOOL)needsAd;
- (BOOL)canFetchData;
- (BOOL) isSubscriptionPurchased;
- (NSDate *)_expireDate;
- (NSDate *)_startDate;

@end
