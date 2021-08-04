//
//  InAppPurchaseProtocol.h
//  ScrapCalc
//
//  Created by Domovik on 14.08.13.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, InAppPurchaseType) {
    InAppPurchaseType1month,
    InAppPurchaseType6months,
    InAppPurchaseType1year,
    InAppPurchaseTypeRestoreAll,
    InAppPurchaseTypeOldVersion
};


NS_INLINE NSString *
InAppPurchaseID(InAppPurchaseType type)
{
    switch (type)
    {
        case InAppPurchaseType1month:
            return @"com.mikeburkard.metalcalcplus.1m";
        case InAppPurchaseType6months:
            return @"com.mikeburkard.metalcalcplus.6m";
        case InAppPurchaseType1year:
            return @"com.mikeburkard.metalcalcplus.1y";
        case InAppPurchaseTypeOldVersion:
            return @"com.mikeburkard.metalcalcplus.proversion";
        default:
            return @"";
    }
}


NS_INLINE NSSet *
InAppPurchaseAllIdentifiers()
{
    return [NSSet setWithObjects:
            InAppPurchaseID(InAppPurchaseType1month),
            InAppPurchaseID(InAppPurchaseType6months),
            InAppPurchaseID(InAppPurchaseType1year),
            InAppPurchaseID(InAppPurchaseTypeOldVersion), nil];
}


NS_INLINE NSString *
InAppPurchaseTitle(InAppPurchaseType type)
{
    switch (type)
    {
        case InAppPurchaseType1month:
            return @"1 month for $1.99";
        case InAppPurchaseType6months:
            return @"6 months for $8.99";
        case InAppPurchaseType1year:
            return @"1 year for $12.99";
        case InAppPurchaseTypeRestoreAll:
            return @"Restore purchases";
        case InAppPurchaseTypeOldVersion:
            return @"Buy Old Version";
        default:
            return @"";
    }
}


@protocol InAppPurchaseDelegate

@optional

- (void)inAppPurchaseDidFailLoadingProducts;
- (void)inAppPurchaseDidCompleteProductPayment;
- (void)inAppPurchaseDidFailProductPayment;

- (void)inAppPurchaseDidRestorePurchases;
- (void)inAppPurchaseDidFailRestoringPurchases;

- (void)inAppPurchaseDidRestoreOldVersion;
- (void)inAppPurchaseDidFinishUpdateTransactions;

- (void)inAppPurchaseDidRestoreProVersionInsteadOfBuyingNewOne;

@end
