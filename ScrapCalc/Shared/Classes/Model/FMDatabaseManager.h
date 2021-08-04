//
//  FMDatabaseManager.h
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "FMDatabase.h"

#define DB_NAME @"metal_calc_db.sqlite"


@interface FMDatabaseManager : NSObject {
    FMDatabase *fmdb_;
}

- (NSMutableArray *)selectAllMetals;
- (NSMutableArray *)selectPuritiesForMetalID:(NSString *)metalID;
- (NSMutableArray *)selectAllUnits;
- (NSMutableArray *)selectAllBaseUnits;
- (NSMutableArray *)selectAllClients;
- (NSMutableArray *)selectAllDiamonds;
- (NSMutableArray *)selectAllPurchases;
- (NSMutableArray *)selectItemsForPurchaseID:(NSString *)purchaseID;
- (NSDictionary *)selectSettings;
- (NSDictionary *)selectCompany;
- (NSMutableArray *)selectAllCurrencies;
- (NSDictionary *)selectPushOptionForMetalID:(NSString *)metalID;

- (NSString *)insertClientWithInfo:(NSDictionary *)info;
- (NSString *)insertPurchaseWithInfo:(NSDictionary *)info;
- (NSString *)insertPurchaseItemWithInfo:(NSDictionary *)info;

- (BOOL)updateSettingsWithInfo:(NSDictionary *)info;
- (BOOL)updateCompanyWithInfo:(NSDictionary *)info;
- (BOOL)updatePurchaseWithInfo:(NSDictionary *)info purchaseID:(NSString *)purchaseID;
- (BOOL)updateClientWithInfo:(NSDictionary *)info clientID:(NSString *)clientID;
- (BOOL)updateMetalWithInfo:(NSDictionary *)info metalID:(NSString *)metalID;
- (BOOL)updateCurrencyWithInfo:(NSDictionary *)info shortname:(NSString *)shortname;
- (void)updateCurrencies:(NSArray *)curs;
- (BOOL)updatePurityWithInfo:(NSDictionary *)info metalID:(NSString *)metalID key:(NSString *)key;
- (BOOL)updateDiamondWithInfo:(NSDictionary *)info diamondID:(NSString *)diamondID;
- (void)updateDiamonds:(NSArray *)diamonds;
- (void)updatePushOptionWithInfo:(NSDictionary *)info metalID:(NSString *)metalID;

- (void)deletePurchaseItemByID:(NSString *)theID;

@end
