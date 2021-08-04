//
//  Model.h
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabaseManager.h"
#import "ServerManager.h"
#import "VersionManager.h"
#import "Metal.h"
#import "Unit.h"
#import "Client.h"
#import "Purchase.h"
#import "PurchaseItem.h"
#import "Settings.h"
#import "Currency.h"
#import "Diamond.h"
#import "Company.h"
#import "CurrencyParser.h"
#import "ERServerErrorsCodeTypes.h"
#import "Firebase.h"
#define kPushIsOn   @"isOn"
#define kPushMinVal @"minValue"
#define kPushMaxVal @"maxValue"

@protocol ModelManagerDelegate

@optional
- (void)didReceiveNewBids;
- (void)didFailReceivingBidsError:(NSError *)error;
- (void)didForbidReceiveBids;

- (void)didSucceedSendingPushOptions;
- (void)didFailSendingPushOptions;
// Key Code
- (void)didVerifieyKeyCode:(NSInteger) code;
@end

@interface ModelManager : NSObject <ServerManagerDelegate, VersionManagerDelegate, CurrencyParserDelegate> {
    FMDatabaseManager *dbManager_;
    
    NSMutableArray *metals_;
    NSMutableArray *availableMetals_;
    NSMutableArray *turnedOnMetals_;
    NSMutableArray *units_;
    NSMutableArray *baseUnits_;
    NSMutableArray *purchases_;
    NSMutableArray *clients_;
    NSMutableArray *currencies_;
    NSMutableArray *diamonds_;
    
    NSInteger requestCount_;
    BOOL inFetchBids_;
}

@property (nonatomic, readonly) NSMutableArray *metals;
@property (nonatomic, readonly) NSMutableArray *onMetals;
@property (nonatomic, readonly) NSMutableArray *units;
@property (nonatomic, readonly) NSMutableArray *baseUnits;
@property (nonatomic, readonly) NSMutableArray *purchases;
@property (nonatomic, readonly) NSMutableArray *clients;
@property (nonatomic, readonly) NSMutableArray *currencies;
@property (nonatomic, readonly) NSMutableArray *diamonds;

@property (nonatomic, readonly) Settings *settings;
@property (nonatomic, assign) BOOL shouldSavePurchase;
@property (nonatomic, assign, getter=isProVersion) BOOL proVersion;
@property (nonatomic, readonly) BOOL isTrialVersion;
@property (nonatomic, ) BOOL isBaseMetal;
@property (nonatomic, assign) BOOL needsFetch;
//@property (nonatomic, assign) BOOL isBurstlyShown;
@property (nonatomic, assign) BOOL isInmobiShown;
@property (nonatomic, strong) NSMutableArray *changedMetals;

@property (nonatomic, retain) NSObject<ModelManagerDelegate> *delegate;
//Firebase
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic, copy) NSString *token;

+ (ModelManager *)shared;

- (void)fetchBidsWithDelegate:(NSObject<ModelManagerDelegate> *)delegate;

- (BOOL)addClient:(Client *)theClient;
- (BOOL)addPurchase:(Purchase *)thePurchase;
- (BOOL)addPurchaseItem:(PurchaseItem *)theItem;

- (NSString *)clientNameByID:(NSString *)cliendID;
- (Client*) clientByID:(NSString*)clientID;
- (NSInteger)selectedUnitIndex;
- (Purchase *)activePurchase;

- (void)synchronizeSettings;
- (void)synchronizeCompanyWithInfo:(NSDictionary *)info;
- (Company *)fetchCompany;

- (void)deletePurchaseItemByID:(NSString *)purchaseID;
- (void)approvePurchase;
- (BOOL)updateClient:(Client *)theClient;

- (BOOL)updatePurchaseWithNewClient:(Purchase *)thePurchase;

- (void)updateMetalWithNewBids:(Metal *)theMetal;
- (void)updateMetalWithSavedOptions:(Metal *)theMetal;
- (void)updateMetal:(Metal *)theMetal withPurity:(NSDictionary *)purity;

- (void)updateDiamond:(Diamond *)theDiamond;
- (void)updateAllDiamonds;

- (void)buyMetal:(Metal *)theMetal;
- (void)updateMetal:(Metal *)theMetal visibility:(BOOL)isVisible;
- (void)setupFirebase;
- (void)verifyKeyCode:(NSString *)keyCode;
- (void)updateKeyCodeValue: (NSString*)keyCode;

- (Metal *)metalForID:(NSInteger)metalID;
- (Unit *)unitForMetal:(Metal *)metal;
- (Unit *)unitForID:(NSInteger)unitID;
- (Unit *)unitForID:(NSInteger)unitID isBase:(BOOL)isBase;
- (NSInteger)unitIndexForID:(NSInteger)unitID;
- (NSInteger)unitIndexForID:(NSInteger)unitID isBase:(BOOL)isBase;

- (NSMutableArray *)purchasesForClient:(Client *)theClient;

- (Currency *)currencyForID:(NSString *)curID;
- (Currency *)selectedCurrency;

- (void)storeFirstLaunchTimestamp;

- (void)updatePushOptionsForMetal:(Metal *)metal withInfo:(NSDictionary *)info;
- (BOOL)isFetchIntervalExceeded;

@end
