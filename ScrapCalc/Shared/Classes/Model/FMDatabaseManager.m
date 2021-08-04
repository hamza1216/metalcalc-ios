//
//  FMDatabaseManager.m
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "FMDatabaseManager.h"

@implementation FMDatabaseManager

- (id)init
{
    self = [super init];
    if (self) {
        if (![self createDatabase]) {
            return nil;
        }
        fmdb_ = [[FMDatabase alloc] initWithPath:self.dbPath];
        fmdb_.shouldCacheStatements = NO;//YES;
        fmdb_.crashOnErrors = NO;//YES;
    }
    return self;
}

- (BOOL)createDatabase
{
    NSString *path = self.dbPath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return YES;
    }
    
    NSString *bundleDatabasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    if ([fileManager fileExistsAtPath:bundleDatabasePath]) {
        
        NSError *error = nil;
        [fileManager copyItemAtPath:bundleDatabasePath
                             toPath:path
                              error:&error];
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        else {
            return YES;
        }
    }
    return NO;
}

- (NSString *)dbPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:DB_NAME];
}

#pragma mark - Selecting base objects

- (NSMutableArray *)selectAllFromTable:(NSString *)dbName condition:(NSString *)condition
{
    if (![fmdb_ open])
        return nil;
    
    NSMutableArray *all = [NSMutableArray array];
    
    FMResultSet *result = [fmdb_ executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ %@", dbName, condition ? condition : @""]];
    while (result.next) {
        [all addObject:result.resultDictionary];
    }
    
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
    return all;
}

- (NSMutableArray *)selectAllMetals
{
    return [self selectAllFromTable:@"Metal" condition:nil];
}

- (NSMutableArray *)selectPuritiesForMetalID:(NSString *)metalID
{
    return [self selectAllFromTable:@"Purity" condition:[NSString stringWithFormat:@"WHERE metal_id=%@", metalID]];
}

- (NSMutableArray *)selectAllUnits
{
    return [self selectAllFromTable:@"Unit" condition:nil];
}

- (NSMutableArray *)selectAllBaseUnits
{
    return [self selectAllFromTable:@"BaseUnit" condition:nil];
}

- (NSMutableArray *)selectAllPurchases
{
    return [self selectAllFromTable:@"Purchase" condition:nil];
}

- (NSMutableArray *)selectItemsForPurchaseID:(NSString *)purchaseID
{
    return [self selectAllFromTable:@"PurchaseItem" condition:[NSString stringWithFormat:@"WHERE purchase_id=%@", purchaseID]];
}

- (NSMutableArray *)selectAllClients
{
    return [self selectAllFromTable:@"Client" condition:nil];
}

- (NSMutableArray *)selectAllDiamonds
{
    return [self selectAllFromTable:@"Diamond" condition:nil];
}

- (NSDictionary *)selectSettings
{
    return [self selectAllFromTable:@"Settings" condition:nil][0];
}

- (NSDictionary *)selectCompany
{
    return [self selectAllFromTable:@"Company" condition:nil][0];
}

- (NSMutableArray *)selectAllCurrencies
{
    return [self selectAllFromTable:@"Currency" condition:nil];
}

- (NSDictionary *)selectPushOptionForMetalID:(NSString *)metalID
{
    return [self selectAllFromTable:@"PushOption" condition:[NSString stringWithFormat:@"WHERE metal_id=%@", metalID]][0];
}

- (NSString *)getMaxIDFromTable:(NSString *)theTable
{
    NSString *res = nil;
    [fmdb_ open];
    FMResultSet *rs = [fmdb_ executeQuery:[NSString stringWithFormat:@"SELECT MAX(id) AS id FROM %@;", theTable]];
    if (rs.next) {
        res = [NSString stringWithFormat:@"%d", (int)[rs.resultDictionary[@"id"] integerValue]];
    }
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
    return res;
}

#pragma mark - Insert objects

- (BOOL)insertIntoTable:(NSString *)tableName parameters:(NSDictionary *)params
{
    if (![fmdb_ open])
        return NO;
    
    NSMutableString *keysString = [NSMutableString string];
    NSMutableString *valuesString = [NSMutableString string];
    NSMutableArray *valuesArray = [NSMutableArray array];
    
    for (NSString *key in params.keyEnumerator) {
        if ([params[key] isKindOfClass:[UIImage class]]) {
            [valuesArray addObject:UIImagePNGRepresentation(params[key])];
        }
        else if ([params[key] isKindOfClass:[NSString class]] || [params[key] isKindOfClass:[NSNumber class]]) {
            [valuesArray addObject:params[key]];
        }
        else {
            continue;
        }
        [keysString appendFormat:@"%@,", key];
        [valuesString appendString:@"?,"];
    }
    
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);", tableName, [keysString substringToIndex:keysString.length-1], [valuesString substringToIndex:valuesString.length-1]];
    BOOL res = [fmdb_ executeUpdate:insertQuery withArgumentsInArray:valuesArray];
    
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
    return res;
}

- (NSString *)insertClientWithInfo:(NSDictionary *)info
{
    if ([self insertIntoTable:@"Client" parameters:info]) {
        return [self getMaxIDFromTable:@"Client"];
    }
    return nil;
}

- (NSString *)insertPurchaseWithInfo:(NSDictionary *)info
{
    if ([self insertIntoTable:@"Purchase" parameters:info]) {
        return [self getMaxIDFromTable:@"Purchase"];
    }
    return nil;
}

- (NSString *)insertPurchaseItemWithInfo:(NSDictionary *)info
{
    if ([self insertIntoTable:@"PurchaseItem" parameters:info]) {
        return [self getMaxIDFromTable:@"PurchaseItem"];
    }
    return nil;
}

#pragma mark - Update objects

- (BOOL)updateTable:(NSString *)tableName parameters:(NSDictionary *)params condition:(NSString *)condition
{
    if (![fmdb_ open])
        return NO;
    
    NSMutableString *argumentsString = [NSMutableString string];
    NSMutableArray *valuesArray = [NSMutableArray array];
    
    for (NSString *key in params.keyEnumerator) {
        if ([params[key] isKindOfClass:[UIImage class]]) {
            [valuesArray addObject:UIImagePNGRepresentation(params[key])];
        }
        else if ([params[key] isKindOfClass:[NSString class]] || [params[key] isKindOfClass:[NSNumber class]]) {
            [valuesArray addObject:params[key]];
        }
        else {
            continue;
        }
        [argumentsString appendFormat:@"%@=?,", key];
    }
    
    NSString *updateQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@ %@;", tableName, [argumentsString substringToIndex:argumentsString.length-1], condition];
    BOOL res = [fmdb_ executeUpdate:updateQuery withArgumentsInArray:valuesArray];
    
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
    return res;
}

- (BOOL)updateTable:(NSString *)tableName parameters:(NSDictionary *)params rowID:(NSString *)rowID
{
    NSString *condition = (rowID == nil ? @"" : [NSString stringWithFormat:@"WHERE id=%@", rowID]);
    return [self updateTable:tableName
                  parameters:params
                   condition:condition];
}

- (BOOL)updateSettingsWithInfo:(NSDictionary *)info
{
    return [self updateTable:@"Settings"
                  parameters:info
                       rowID:nil];
}

- (BOOL)updateCompanyWithInfo:(NSDictionary *)info
{
    return [self updateTable:@"Company"
                  parameters:info
                       rowID:nil];
}

- (BOOL)updatePurchaseWithInfo:(NSDictionary *)info purchaseID:(NSString *)purchaseID
{
    return [self updateTable:@"Purchase"
                  parameters:info
                       rowID:purchaseID];
}

- (BOOL)updateClientWithInfo:(NSDictionary *)info clientID:(NSString *)clientID
{
    return [self updateTable:@"Client"
                  parameters:info
                       rowID:clientID];
}

- (BOOL)updateMetalWithInfo:(NSDictionary *)info metalID:(NSString *)metalID
{
    return [self updateTable:@"Metal"
                  parameters:info
                       rowID:metalID];
}

- (BOOL)updateCurrencyWithInfo:(NSDictionary *)info shortname:(NSString *)shortname
{
    return [self updateTable:@"Currency"
                  parameters:info
                   condition:[NSString stringWithFormat:@"WHERE shortname='%@'", shortname]];
}

- (BOOL)updatePurityWithInfo:(NSDictionary *)info metalID:(NSString *)metalID key:(NSString *)key
{
    return [self updateTable:@"Purity"
                  parameters:info
                   condition:[NSString stringWithFormat:@"WHERE metal_id=%@ AND name='%@'", metalID, key]];
}

- (BOOL)updateDiamondWithInfo:(NSDictionary *)info diamondID:(NSString *)diamondID
{
    return [self updateTable:@"Diamond"
                  parameters:info
                       rowID:diamondID];
}

- (void)updateDiamonds:(NSArray *)diamonds
{
    if (![fmdb_ open])
        return;
    
    [fmdb_ beginTransaction];
    
    for (NSDictionary *params in diamonds) {
        NSMutableString *argumentsString = [NSMutableString string];
        NSMutableArray *valuesArray = [NSMutableArray array];
        
        for (NSString *key in params.keyEnumerator) {
            if ([params[key] isKindOfClass:[UIImage class]]) {
                [valuesArray addObject:UIImagePNGRepresentation(params[key])];
            }
            else if ([params[key] isKindOfClass:[NSString class]] || [params[key] isKindOfClass:[NSNumber class]]) {
                [valuesArray addObject:params[key]];
            }
            else {
                continue;
            }
            [argumentsString appendFormat:@"%@=?,", key];
        }
        
        NSString *updateQuery = [NSString stringWithFormat:@"UPDATE Diamond SET %@ WHERE name='%@';", [argumentsString substringToIndex:argumentsString.length-1], params[@"name"]];
        [fmdb_ executeUpdate:updateQuery withArgumentsInArray:valuesArray];
    }
    
    [fmdb_ commit];
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
}

- (void)updateCurrencies:(NSArray *)curs
{
    if (![fmdb_ open])
        return;
    
    [fmdb_ beginTransaction];
    
    for (NSDictionary *params in curs) {
        NSMutableString *argumentsString = [NSMutableString string];
        NSMutableArray *valuesArray = [NSMutableArray array];
        
        for (NSString *key in params.keyEnumerator) {
            if ([params[key] isKindOfClass:[UIImage class]]) {
                [valuesArray addObject:UIImagePNGRepresentation(params[key])];
            }
            else if ([params[key] isKindOfClass:[NSString class]] || [params[key] isKindOfClass:[NSNumber class]]) {
                [valuesArray addObject:params[key]];
            }
            else {
                continue;
            }
            [argumentsString appendFormat:@"%@=?,", key];
        }
        
        NSString *updateQuery = [NSString stringWithFormat:@"UPDATE Currency SET %@ WHERE shortname='%@';", [argumentsString substringToIndex:argumentsString.length-1], params[@"shortname"]];
        [fmdb_ executeUpdate:updateQuery withArgumentsInArray:valuesArray];
    }
    
    [fmdb_ commit];
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
}

- (void)updatePushOptionWithInfo:(NSDictionary *)info metalID:(NSString *)metalID
{
    [self updateTable:@"PushOption"
           parameters:info
            condition:[NSString stringWithFormat:@"WHERE metal_id=%@", metalID]];
}

#pragma mark - Delete objects

- (void)deleteFromTable:(NSString *)tableName withID:(NSString *)theID
{
    if (![fmdb_ open])
        return;
    
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id=%@", tableName, theID];
    [fmdb_ executeUpdate:deleteQuery];
    
    if (![APP_DELEGATE iOS9OrHigher]) {
        [fmdb_ close];
    }
}

- (void)deletePurchaseItemByID:(NSString *)theID
{
    [self deleteFromTable:@"PurchaseItem" withID:theID];
}

#pragma mark - Memory

- (void)dealloc
{
    [fmdb_ release];
    [super dealloc];
}

@end
