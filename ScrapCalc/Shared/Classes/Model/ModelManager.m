//
//  Model.m
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "ModelManager.h"
#import "FMDatabaseManager.h"
#import "NSURLConnection+Blocks.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "Firebase.h"


#define EXPIRATION_PERIOD   30 * 24 * 3600
#define FETCH_INTERVAL      12 * 3600
#define FETCH_INTERVAL_KEY  @"FetchInterval"

@implementation ModelManager

@synthesize metals = availableMetals_;
@synthesize onMetals = turnedOnMetals_;
@synthesize units = units_;
@synthesize baseUnits = baseUnits_;
@synthesize clients = clients_;
@synthesize purchases = purchases_;
@synthesize settings = settings_;
@synthesize currencies = currencies_;
@synthesize diamonds = diamonds_;
@synthesize shouldSavePurchase;
@synthesize isBaseMetal;
//@synthesize isBurstlyShown;
@synthesize isInmobiShown;

static ModelManager *shared_;

+ (ModelManager *)shared
{
    @synchronized(self) {
        if (shared_ == nil) {
            shared_ = [ModelManager new];
        }
        return shared_;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        dbManager_ = [FMDatabaseManager new];
        
        metals_ = [NSMutableArray new];
        availableMetals_ = [NSMutableArray new];
        turnedOnMetals_ = [NSMutableArray new];
        units_ = [NSMutableArray new];
        baseUnits_ = [NSMutableArray new];
        purchases_ = [NSMutableArray new];
        clients_ = [NSMutableArray new];
        currencies_ = [NSMutableArray new];
        diamonds_ = [NSMutableArray new];
        
        [self fetchMetals];
        [self fetchUnits];
        [self fetchClients];
        [self fetchPurchases];        
        [self fetchSettings];
        [self fetchCurrencies];
        [self fetchDiamonds];
        
        self.changedMetals = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Fetch data

- (void) setupFirebase
{
    self.ref = [[FIRDatabase database] reference];
    self.udid = [[FIRAuth auth] currentUser].uid;
    
}
- (void)fetchMetals
{
    [self convertDictionaries:[dbManager_ selectAllMetals] toArray:&metals_ entityClass:Metal.class];
    for (Metal *metal in metals_) {
        NSMutableArray *purs = [dbManager_ selectPuritiesForMetalID:metal.metalID];
        for (NSDictionary *dict in purs) {
            [metal.purities addObject:@{dict[@"name"]:dict[@"weight"]}];
        }
        if (metal.isAvailable) {
            [availableMetals_ addObject:metal];
            if (metal.isOn) {
                [turnedOnMetals_ addObject:metal];
            }
        }
        
        NSDictionary *pushDict = [dbManager_ selectPushOptionForMetalID:metal.metalID];
        PushOption *pushOption = [[PushOption alloc] initWithDictionary:pushDict];
        metal.pushOption = pushOption;
        [pushOption release];
    }
}

- (void)fetchUnits
{
    [self convertDictionaries:[dbManager_ selectAllUnits] toArray:&units_ entityClass:Unit.class];
    [self convertDictionaries:[dbManager_ selectAllBaseUnits] toArray:&baseUnits_ entityClass:Unit.class];
}

- (void)fetchClients
{
    [self convertDictionaries:[dbManager_ selectAllClients] toArray:&clients_ entityClass:Client.class];
}

- (void)fetchPurchases
{
    [self convertDictionaries:[dbManager_ selectAllPurchases] toArray:&purchases_ entityClass:Purchase.class];
    for (Purchase *purchase in purchases_) {
        
        NSMutableArray *items = purchase.items;
        NSMutableArray *dicts = [dbManager_ selectItemsForPurchaseID:purchase.purchaseID];
        [self convertDictionaries:dicts toArray:&items entityClass:PurchaseItem.class];
        
        for (NSInteger i = 0; i < dicts.count; ++i) {
            NSDictionary *dict = dicts[i];
            NSString *metalID = [NSString stringWithFormat:@"%d", [dict[@"metal_id"] intValue]];
            NSString *unitID = [NSString stringWithFormat:@"%d", [dict[@"unit_id"] intValue]];
            
            PurchaseItem *item = items[i];
            item.metal = [self metalByID:metalID];
            item.unit = [self unitByID:unitID];
            
            purchase.price += item.price;
        }
        
        for (Client *client in clients_) {
            if ([purchase.clientID isEqualToString:client.clientID]) {
                [client.purchases addObject:purchase];
            }
        }
    }
}

- (void)fetchDiamonds
{
    [self convertDictionaries:[dbManager_ selectAllDiamonds]
                      toArray:&diamonds_
                  entityClass:Diamond.class];
    
    NSDictionary *dict = DIAMONDS_DICT;
    for (Diamond *diam in diamonds_) {
        diam.values = dict[diam.name.lowercaseString];
    }
}

- (void)fetchSettings
{
    settings_ = [[Settings alloc] initWithDictionary:[dbManager_ selectSettings]];
}

- (void)fetchCurrencies
{
    if (currencies_.count < 1) {
        [self convertDictionaries:[dbManager_ selectAllCurrencies]
                          toArray:&currencies_
                      entityClass:Currency.class];
    }
}

- (void)convertDictionaries:(NSArray *)dicts toArray:(NSMutableArray **)array entityClass:(Class)class
{
    [*array removeAllObjects];
    for (NSDictionary *dict in dicts) {
        id obj = [[class alloc] initWithDictionary:dict];
        [*array addObject:obj];
        [obj release];
    }
}

#pragma mark Server

- (void)_fetchBids
{
    NSLog(@"fetch bids");
    inFetchBids_ = YES;
    requestCount_ = 0;
    [self.changedMetals removeAllObjects];
    
    self.ref = [[FIRDatabase database] reference];
    self.udid = [[FIRAuth auth] currentUser].uid;
    for (Metal *metal in metals_){
//        NSLog(@"Metal Name:@%@, Count:%i", metal.name, [metals_ count]);
        FIRDatabaseQuery* currencyQuery = [[[[self.ref child:@"today"] child: metal.name] queryOrderedByChild:@"datetime"] queryLimitedToLast:1];
        [currencyQuery observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            requestCount_++;
//          NSLog(@"Key: @%@, Value: @%@", [snapshot key], [snapshot value]);
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot* snapChild;
            while (snapChild = [children nextObject]) {
                FIRDataSnapshot* child = snapChild.value;
                 /*
                     NSEnumerator *children2 = [snapChild  children];
                     FIRDataSnapshot* child;
                     while (child = [children2 nextObject]) {
                //      NSLog(@"Key: @%@, Value: @%@", child.key, child.value);
                    }
                 */
                double newPrice = [[child valueForKey:@"bid"] doubleValue];
                // custom push notification for iOS7
                if (IS_IOS7) {
                    if (metal.pushOption.isOn == PushOptionTypeThreshold) {
//                        NSLog(@"BidPriceRaw: %f", metal.bidPriceRaw);
                        BOOL passedMinBorder = (metal.bidPriceRaw > metal.pushOption.minValue) != (newPrice > metal.pushOption.minValue);
                        BOOL passedMaxBorder = (metal.bidPriceRaw > metal.pushOption.maxValue) != (newPrice > metal.pushOption.maxValue);
                        
                        if (passedMinBorder || passedMaxBorder) {
                            [self.changedMetals addObject:metal];
                        }
                    }
                    else if (metal.pushOption.isOn == PushOptionTypeBadge) {
                        [self.changedMetals addObject:metal];
                    }
                }
                // end
                metal.bidPrice = newPrice;
                metal.bidChange = [[child valueForKey:@"change"] doubleValue];

                [metal setTimestampWithDateTime:[child valueForKey:@"datetime"]];
                
                
                if (fabs(metal.pushOption.minValue) < 0.0001 && fabs(metal.pushOption.maxValue) < 0.0001) {
                    metal.pushOption.minValue = 0.8 * newPrice;
                    metal.pushOption.maxValue = 1.2 * newPrice;
                    
                    [self performSelectorOnMainThread:@selector(updatePushWithMetal:)
                                           withObject:metal
                                        waitUntilDone:YES];
                }
                
                [self performSelectorOnMainThread:@selector(updateWithMetal:)
                                       withObject:metal
                                    waitUntilDone:YES];
                if(requestCount_ == metals_.count){
                    [APP_DELEGATE hideLoadingIndicator];
                    NSLog(@"did receive bids\n");
                    inFetchBids_ = NO;
                    if ([self.delegate respondsToSelector:@selector(didReceiveNewBids)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate didReceiveNewBids];
                            [APP_DELEGATE didReceiveNewBids];
                        });
                    }
                }
            }
        }];
    }
    
    /*
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://burkardsolutions.com/iphone/newprice.php"]];
	[postRequest setHTTPMethod:@"POST"];
    
    NSData *body = [@"task=fetch_latest_bids" dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest setHTTPBody:body];
	
    inFetchBids_ = YES;
    
    [NSURLConnection asyncRequest:postRequest success:^(NSData *data, NSURLResponse *response) {
        [APP_DELEGATE hideLoadingIndicator];
        
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSArray *bids = [json objectFromJSONString];
        
        [self.changedMetals removeAllObjects];
        
        for (NSDictionary *dict in bids) {
            NSString *name = [dict[@"name"] lowercaseString];
            for (Metal *metal in self.metals) {
                if ([metal.name.lowercaseString isEqualToString:name]) {
                    
                    double newPrice = [dict[@"price"] doubleValue];
                    
                    
                    // custom push notification for iOS7
                    
                    if (IS_IOS7) {
                        if (metal.pushOption.isOn == PushOptionTypeThreshold) {
                            BOOL passedMinBorder = (metal.bidPriceRaw > metal.pushOption.minValue) != (newPrice > metal.pushOption.minValue);
                            BOOL passedMaxBorder = (metal.bidPriceRaw > metal.pushOption.maxValue) != (newPrice > metal.pushOption.maxValue);
                            
                            if (passedMinBorder || passedMaxBorder) {
                                [self.changedMetals addObject:metal];
                            }
                        }
                        else if (metal.pushOption.isOn == PushOptionTypeBadge) {
                            [self.changedMetals addObject:metal];
                        }
                    }
                    
                    // end
                    
                    
                    metal.bidPrice = newPrice;
                    [metal setTimestampWithDateTime:dict[@"datetime"]];
                    
                    if ([dict[@"change"] hasSuffix:@"%"]) {
                        [metal setBidChangeWithPercent:[dict[@"change"] doubleValue]];
                    }
                    else {
                        metal.bidChange = [dict[@"change"] doubleValue];
                    }
                    
                    if (fabs(metal.pushOption.minValue) < 0.0001 && fabs(metal.pushOption.maxValue) < 0.0001) {
                        metal.pushOption.minValue = 0.8 * [dict[@"price"] doubleValue];
                        metal.pushOption.maxValue = 1.2 * [dict[@"price"] doubleValue];
                        
                        [self performSelectorOnMainThread:@selector(updatePushWithMetal:)
                                               withObject:metal
                                            waitUntilDone:YES];
                    }
                    
                    [self performSelectorOnMainThread:@selector(updateWithMetal:)
                                           withObject:metal
                                        waitUntilDone:YES];
                    break;
                }
            }
        }
        NSLog(@"did receive bids\n");
        inFetchBids_ = NO;
        if ([self.delegate respondsToSelector:@selector(didReceiveNewBids)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didReceiveNewBids];
            });            
        }
        
    } failure:^(NSData *data, NSError *error) {
        [APP_DELEGATE hideLoadingIndicator];
        NSLog(@"Error: %@\nData: %@", error.localizedDescription, data);
        
        inFetchBids_ = NO;
        if ([self.delegate respondsToSelector:@selector(didFailReceivingBidsError:)]) {
            [self.delegate didFailReceivingBidsError:error];
        }
    }];
     */
    
}

- (void)fetchBidsWithDelegate:(NSObject<ModelManagerDelegate> *)delegate
{
    NSLog(@"fetch bids with delegate\n");
    [APP_DELEGATE showLoadingIndicator];
    self.delegate = delegate;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]] forKey:FETCH_INTERVAL_KEY];

    [[VersionManager shared] setDelegate:self];
    [[VersionManager shared] verifyVersion];
}

- (void)versionManagerDidFinishVerification
{
    if ([[VersionManager shared] canFetchData]) {
        NSLog(@"can fetch data\n");
        [self fetchMetalData];
    }
    else {
        NSLog(@"forbid receive bids \n");
        [APP_DELEGATE hideLoadingIndicator];
        [self.delegate didForbidReceiveBids];
    }
}

- (void)fetchMetalData
{
    if([FIRAuth auth].currentUser){
        [self _fetchBids];
        [self _fetchCurrencies];
    }
    else{
        // Delay execution of my block for 10 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self _fetchBids];
            [self _fetchCurrencies];
        });
    }
}
- (void)updateWithMetal:(Metal *)metal
{
    [dbManager_ updateMetalWithInfo:metal.bidDictionary metalID:metal.metalID];
}

- (void)updatePushWithMetal:(Metal *)metal
{
    [dbManager_ updatePushOptionWithInfo:metal.pushOption.extractDictionary metalID:metal.metalID];
}
- (void)updateKeyCodeValue: (NSString*)keyCode
{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRDatabaseReference* keycodeInfoRef = [[ref child:@"settings"] child:@"keycode"];
    
    NSDictionary* dictionary = @{keyCode: @false
    };
    [keycodeInfoRef updateChildValues:dictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        NSLog(@"Keycode Value udpated");
    }];
}
- (void)verifyKeyCode: (NSString*)keyCode
{    
    self.ref = [[FIRDatabase database] reference];
    [[[self.ref child:@"settings"] child:@"keycode"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot* snapChild;
        int nRetCode = 2;
        while (snapChild = [children nextObject]) {
            if ([keyCode.uppercaseString isEqualToString:snapChild.key.uppercaseString]) {
                if([snapChild.value boolValue] == YES){
                    nRetCode = 0;
                    [self updateKeyCodeValue:snapChild.key];
                    break;
                }
                else{
                    nRetCode = 1;
                }
            }
        }
        [self.delegate didVerifieyKeyCode: nRetCode];
    }];
    /*
    FIRDatabaseReference* keycodeInfoRef = [[self.ref child:@"settings"] child:@"keycode"];
    NSDictionary* dictionaryCode = @{@"JoPCxoEno":@true,
                                     @"VPwI4LOs6":@true,
                                     @"HmWZuh1ph":@true,
                                     @"wS65lV1GZ":@true,
                                     @"dRoClIJOZ":@true,
                                     @"4xTq5zZn4":@true,
                                     @"gUEMcoGis":@true,
                                     @"xPbygFREk":@true,
                                     @"syEoBWLGV":@true,
                                     @"UZKBp2h8g":@true
    };
    [keycodeInfoRef setValue:dictionaryCode withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        NSLog(@"Keycode Value saved");
    }];
     */
}

- (void)_fetchCurrencies
{
    [APP_DELEGATE showLoadingIndicator];
    
    self.ref = [[FIRDatabase database] reference];
    self.udid = [[FIRAuth auth] currentUser].uid;
    [[self.ref child:@"exchangerate"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot* snapChild;
        while (snapChild = [children nextObject]) {
            for (Currency *cur in currencies_) {
                if ([cur.shortname.uppercaseString isEqualToString:snapChild.key.uppercaseString]) {
                    if(snapChild.hasChildren){
                        FIRDataSnapshot* exchangeShapshot =  [snapChild.children nextObject];
                        cur.value = [exchangeShapshot.value doubleValue];
                    }
                }
            }
        }
        [self updateCurrencies];
        [APP_DELEGATE hideLoadingIndicator];
    }];
    /*

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://themoneyconverter.com/rss-feed/USD/rss.xml"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.floatrates.com/daily/usd.xml"]];
    
    [NSURLConnection asyncRequest:request
                          success:^(NSData *data, NSURLResponse *response) {
                              CurrencyParser *parser = [[CurrencyParser alloc] init];
                              parser.delegate = self;
                              [parser parseCurrencyData:data];
                          }
                          failure:^(NSData *data, NSError *error) {
                              NSLog(@"%@", error.localizedDescription);
                          }];
*/
    
}
/*
- (void)_fetchClients
{
    self.ref = [[FIRDatabase database] reference];
    self.udid = [[FIRAuth auth] currentUser].uid;
//    self.udid = @"drr8cB8ajqTS6VK98s4uR8QsMeN2";
    [[[self.ref child:@"clients"] child:self.udid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot* snapChild;
        [[self clients] removeAllObjects];
        while (snapChild = [children nextObject]) {
            if(snapChild.hasChildren){
                FIRDataSnapshot* clientChild = snapChild.value;
                Client* clientItem = [[Client new] autorelease];
                clientItem.clientID = snapChild.key;
                clientItem.street = [clientChild valueForKey:@"address"];
                clientItem.firstname = [clientChild valueForKey:@"first_name"];
                clientItem.lastname = [clientChild valueForKey:@"last_name"];
                clientItem.phone = [clientChild valueForKey:@"phone_number"];
                [self addClient:clientItem];
            }
        }
        [APP_DELEGATE hideLoadingIndicator];
    }];
}
- (void)_fetchPurchase
{
    self.ref = [[FIRDatabase database] reference];
    self.udid = [[FIRAuth auth] currentUser].uid;
    [[[self.ref child:@"transactions"] child:self.udid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot* snapChild;
        while (snapChild = [children nextObject]) {
            if(snapChild.hasChildren){
                NSEnumerator* purchaseEnumerator =  [snapChild children];
                FIRDataSnapshot* purchaseChild;
                while (purchaseChild = [purchaseEnumerator nextObject]) {
                    NSString* purchaseKey = purchaseChild.key;
                    NSString* purchaseValue = purchaseChild.value;
                }
            }
        }
        [APP_DELEGATE hideLoadingIndicator];
    }];
}
 */
- (void)currencyParser:(CurrencyParser *)parser didFinishParsingWithResult:(NSDictionary *)resultDictionary
{
    for (NSString *key in resultDictionary.allKeys) {
        
        for (Currency *cur in currencies_) {
            if ([cur.shortname.uppercaseString isEqualToString:key.uppercaseString]) {
                cur.value = [resultDictionary[key] doubleValue];
            }
        }
    }
    
    [self updateCurrencies];
}

- (void)currencyParserDidFail:(CurrencyParser *)parser
{
}

- (void)_fetchCurrenciesOld
{
//    [APP_DELEGATE showLoadingIndicator];
//    
//    requestCount_ = currencies_.count;
//    for (Currency *cur in currencies_) {
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:CURRENCY_URL(cur.shortname)]];      
//
//        [NSURLConnection asyncRequest:request success:^(NSData *data, NSURLResponse *response) {
//            
//            NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//            json = [json stringByReplacingOccurrencesOfString:@": " withString:@":"];
//            
//            NSArray *comps = [json componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":,"]];
//            if (comps.count > 3) {
//                
//                NSString *fullname = (comps.count < 2 || [comps[1] length] < 4) ? @"" : [comps[1] substringWithRange:NSMakeRange(3, [comps[1] length]-4)];
//                NSString *shortname = response.URL.absoluteString.length < 4 ? @"" : [response.URL.absoluteString substringWithRange:NSMakeRange(response.URL.absoluteString.length-12, 3)];
//                
//                NSString *value = [[comps[3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0] substringFromIndex:1];
//                
//                for (Currency *_cur in currencies_) {
//                    if ([_cur.shortname isEqualToString:shortname]) {
//                        cur.fullname = fullname;
//                        cur.value = value.doubleValue;
//                        break;
//                    }
//                }
//            }
//            
//            requestCount_--;
//            if (requestCount_ == 0) {
//                [APP_DELEGATE hideLoadingIndicator];                
//                [self updateCurrencies];
//            }
//            
//        } failure:^(NSData *data, NSError *error) {
//            requestCount_--;
//            if (requestCount_ == 0) {
//                [APP_DELEGATE hideLoadingIndicator];
//            }
//            NSLog(@"Error: %@\nData: %@", error.localizedDescription, data);
//        }];
//    }
}

- (void)updateCurrencies
{
    if (inFetchBids_) {
        [self performSelector:_cmd withObject:nil afterDelay:1];
        return;
    }
    
    NSMutableArray *curs = [NSMutableArray array];
    for (Currency *_cur in currencies_) {
        [curs addObject:_cur.extractDictionaryWithShort];
    }
    [dbManager_ performSelectorOnMainThread:@selector(updateCurrencies:) withObject:curs waitUntilDone:NO];
}

#pragma mark - Getters

- (Metal *)metalByID:(NSString *)metalID
{
    for (Metal *metal in metals_)
        if (metal.metalID.integerValue == metalID.integerValue)
            return metal;
    return nil;
}

- (Unit *)unitByID:(NSString *)unitID
{
    for (Unit *unit in units_)
        if ([unit.unitID isEqualToString:unitID])
            return unit;
    return nil;
}

#pragma mark - Adding objects

- (BOOL)addClient:(Client *)theClient
{
    theClient.clientID = [dbManager_ insertClientWithInfo:[theClient extractDictionary]];
    if ([theClient.clientID length] > 0) {
        [clients_ addObject:theClient];
        return YES;
    }
    return NO;
}

- (BOOL)addPurchase:(Purchase *)thePurchase
{
    thePurchase.timestamp = [[NSDate date] timeIntervalSince1970];
    thePurchase.purchaseID = [dbManager_ insertPurchaseWithInfo:[thePurchase extractDictionary]];
    if ([thePurchase.purchaseID length] > 0) {
        [purchases_ addObject:thePurchase];
        return YES;
    }
    return NO;
}

- (BOOL)addPurchaseItem:(PurchaseItem *)theItem
{
    Purchase *purchase = [self activePurchase];
    theItem.itemID = [dbManager_ insertPurchaseItemWithInfo:[theItem extractDictionary]];
    if ([theItem.itemID length] > 0) {
        [purchase.items addObject:theItem];
        purchase.price += theItem.price;
        return YES;
    }
    return NO;
}

#pragma mark - Accessors

- (NSString *)clientNameByID:(NSString *)cliendID
{
    for (Client *client in clients_) {
        if ([client.clientID isEqualToString:cliendID]) {
            return client.name;
        }
    }
    return nil;
}

- (Client*) clientByID:(NSString*)clientID
{
    for (Client *client in clients_)
    {
        if ([client.clientID isEqualToString:clientID]) {
            return client;
        }
    }
    return nil;
}

- (NSInteger)selectedUnitIndex
{
    for (NSInteger i = 0; i < units_.count; ++i) {
        if ([[units_[i] unitID] isEqualToString:settings_.unitID]) {
            return i;
        }
    }
    return 0;
}

- (Purchase *)activePurchase
{
    for (Purchase *purchase in purchases_) {
        if (!purchase.isApproved) {
            return purchase;
        }
    }
    
    Purchase *newPurchase = [Purchase new];
    newPurchase.clientID = @"0";
    newPurchase.timestamp = [[NSDate date] timeIntervalSince1970];
    newPurchase.purchaseID = [dbManager_ insertPurchaseWithInfo:@{ @"client_id":newPurchase.clientID, @"isApproved":@"0", @"timestamp":[NSString stringWithFormat:@"%f", newPurchase.timestamp] }];
    [purchases_ addObject:newPurchase];
    [newPurchase release];
    return [purchases_ lastObject];
}

- (NSMutableArray *)purchasesForClient:(Client *)theClient
{
    if (theClient.clientID.integerValue < 1) {
        return nil;
    }
    
    NSMutableArray *res = [NSMutableArray array];
    for (Purchase *purchase in purchases_) {
        if ([theClient.clientID isEqualToString:purchase.clientID]) {
            [res addObject:purchase];
        }
    }
    return res;
}

- (Currency *)currencyForID:(NSString *)curID
{
    for (Currency *cur in currencies_) {
        if (cur.currencyID.integerValue == curID.integerValue) {
            return cur;
        }
    }
    return nil;
}

- (Currency *)selectedCurrency
{
    return [self currencyForID:settings_.currencyID];
}

- (Metal *)metalForID:(NSInteger)metalID
{
    for (Metal *metal in metals_) {
        if (metal.metalID.integerValue == metalID) {
            return metal;
        }
    }
    return nil;
}

- (Unit *)unitForID:(NSInteger)unitID isBase:(BOOL)isBase
{
    NSArray *arr = isBase ? baseUnits_ : units_;
    for (Unit *unit in arr) {
        if (unit.unitID.integerValue == unitID) {
            return unit;
        }
    }
    return nil;
}

- (Unit *)unitForMetal:(Metal *)metal
{
    return [self unitForID:metal.savedUnit isBase:metal.isBaseMetal];
}

- (Unit *)unitForID:(NSInteger)unitID
{
    return [self unitForID:unitID isBase:self.isBaseMetal];
}

- (NSInteger)unitIndexForID:(NSInteger)unitID isBase:(BOOL)isBase
{
    NSArray *arr = isBase ? baseUnits_ : units_;
    for (NSInteger i = 0; i < arr.count; ++i) {
        if ([[arr[i] unitID] integerValue] == unitID) {
            return i;
        }
    }
    return -1;
}

- (NSInteger)unitIndexForID:(NSInteger)unitID
{
    return [self unitIndexForID:unitID isBase:self.isBaseMetal];
}

#pragma mark - Updates

- (void)synchronizeSettings
{
    [dbManager_ updateSettingsWithInfo:settings_.extractDictionary];
}

- (void)synchronizeCompanyWithInfo:(NSDictionary *)info;
{
    [dbManager_ updateCompanyWithInfo:info];
}

- (Company *)fetchCompany
{
    return [[Company alloc] initWithDictionary:[dbManager_ selectCompany]];
}

- (void)approvePurchase
{
    Purchase *purchase = [self activePurchase];
    purchase.isApproved = YES;
    purchase.timestamp = [[NSDate date] timeIntervalSince1970];
    [dbManager_ updatePurchaseWithInfo:@{ @"client_id":purchase.clientID, @"isApproved":@"1", @"timestamp":[NSString stringWithFormat:@"%f", purchase.timestamp] }
                            purchaseID:purchase.purchaseID];
}

- (BOOL)updateClient:(Client *)theClient
{
    return [dbManager_ updateClientWithInfo:theClient.extractDictionary
                                   clientID:theClient.clientID];
}

- (BOOL)updatePurchaseWithNewClient:(Purchase *)thePurchase
{
    return [dbManager_ updatePurchaseWithInfo:@{ @"client_id":thePurchase.clientID }
                                   purchaseID:thePurchase.purchaseID];
}

- (void)updateMetalWithNewBids:(Metal *)theMetal
{
    [dbManager_ updateMetalWithInfo:theMetal.bidDictionary
                            metalID:theMetal.metalID];
}

- (void)updateMetalWithSavedOptions:(Metal *)theMetal
{
    [dbManager_ updateMetalWithInfo:theMetal.savedDictionary
                            metalID:theMetal.metalID];
}

- (void)updateMetal:(Metal *)theMetal withPurity:(NSDictionary *)purity
{
    [dbManager_ updatePurityWithInfo:@{ @"weight":purity.allValues[0] }
                             metalID:theMetal.metalID key:purity.allKeys[0]];
}

- (void)updateMetal:(Metal *)theMetal visibility:(BOOL)isVisible
{
    theMetal.isOn = isVisible;
    [dbManager_ updateMetalWithInfo:@{@"isOn":(isVisible ? @"1" : @"0")}
                            metalID:theMetal.metalID];
    
    if (theMetal.isOn) {
        BOOL added = NO;
        for (NSInteger i = 0; i < turnedOnMetals_.count; ++i) {
            Metal *metal = turnedOnMetals_[i];
            if (metal.metalID.integerValue > theMetal.metalID.integerValue) {
                [turnedOnMetals_ insertObject:theMetal atIndex:i];
                added = YES;
                break;
            }
        }
        if (!added) {
            [turnedOnMetals_ addObject:theMetal];
        }
    }
    else {
        [turnedOnMetals_ removeObject:theMetal];
    }
}

- (void)buyMetal:(Metal *)theMetal
{
    [dbManager_ updateMetalWithInfo:@{@"isAvailable":@"1"}
                            metalID:theMetal.metalID];
    [availableMetals_ addObject:theMetal];
    [turnedOnMetals_ addObject:theMetal];
}

- (void)updateDiamond:(Diamond *)theDiamond
{
    [dbManager_ updateDiamondWithInfo:@{ @"savedValue":theDiamond.savedValue }
                            diamondID:theDiamond.diamondID];
}

- (void)updateAllDiamonds
{
    NSLog(@"DIAMONDS UPDATE");
    
    NSMutableArray *arr = [NSMutableArray array];
    for (Diamond *diamond in diamonds_) {
        [arr addObject:diamond.extractDictionary];
    }
    [dbManager_ updateDiamonds:arr];
}

#pragma mark - Deletes

- (void)deletePurchaseItemByID:(NSString *)purchaseID
{
    [dbManager_ deletePurchaseItemByID:purchaseID];
}

- (void)storeFirstLaunchTimestamp
{
    settings_.firstLaunch = [[NSDate date] timeIntervalSince1970];
    [dbManager_ updateSettingsWithInfo:@{ @"firstLaunch":[NSString stringWithFormat:@"%lf", settings_.firstLaunch] }];
}

#pragma mark - Pro

- (BOOL)isProVersion
{
    return [[VersionManager shared] currentVersion] != VersionExpired;
//    if (settings_.isPro == NO) {
//        return self.isTrialVersion;
//    }
//    return YES;
}

- (void)setProVersion:(BOOL)proVersion
{
    settings_.isPro = proVersion ? 1 : 0;
    NSString *val = proVersion ? @"1" : @"0";
    [dbManager_ updateSettingsWithInfo:@{ @"isPro":val }];
    
    return;
    
    // need this ?
    for (Metal *metal in metals_) {
        if (!metal.isAvailable) {
            [self buyMetal:metal];
        }
    }
}

- (BOOL)isTrialVersion
{
    double now = [[NSDate date] timeIntervalSince1970];
    double delta = now - settings_.firstLaunch;
    return (delta < EXPIRATION_PERIOD);
}

- (BOOL)isFetchIntervalExceeded
{
    double timestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:FETCH_INTERVAL_KEY] doubleValue];
    if (timestamp < 1) {
        return NO;
    }
    
    double now = [[NSDate date] timeIntervalSince1970];
    return (timestamp + FETCH_INTERVAL < now);
}

- (BOOL)needsFetch
{
    return !inFetchBids_ && _needsFetch && [self isFetchIntervalExceeded];
}


#pragma mark - Push services

- (void)updatePushOptionsForMetal:(Metal *)metal withInfo:(NSDictionary *)info
{
    
    if (IS_IOS7) {
        [self _saveMetal:metal withInfo:info];
        return;
    }
    
    PushOptionType isOn = [info[kPushIsOn] integerValue];
    double minVal = [info[kPushMinVal] doubleValue];
    double maxVal = [info[kPushMaxVal] doubleValue];
    
    NSString *url;
    
    switch (isOn) {
        case PushOptionTypeOff:
            url = [NSString stringWithFormat:@"metalname=%@", metal.name];
            break;
        case PushOptionTypeBadge:
            url = [NSString stringWithFormat:@"metalname=%@&badge=1", metal.name];
            break;
        case PushOptionTypeThreshold:
            url = [NSString stringWithFormat:@"metalname=%@&minval=%lf&maxval=%lf", metal.name, minVal, maxVal];
            break;
    }
    
/*
    // Firebase save users
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRDatabaseReference* userinfoRef = [[ref child:@"users"] child: self.udid];
    [userinfoRef setValue:@{@"metalname": metal.name}];

    [APP_DELEGATE showLoadingIndicator];
    NSString *fullURL = [NSString stringWithFormat:@"http://burkardsolutions.com/iphone/insertgeneraluser_new.php?udid=%@&devicetoken=%@&%@",
                         self.udid, self.token, url];
    NSLog(@"REQUEST URL: %@", fullURL);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    
    [NSURLConnection asyncRequest:request
                          success:^(NSData *data, NSURLResponse *response) {
                              
                              NSLog(@"RESPONSE DATA: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
                              
                              [APP_DELEGATE hideLoadingIndicator];
                              
                              [self _saveMetal:metal withInfo:info];
                              
                          }
                          failure:^(NSData *data, NSError *error) {
                              
                              [APP_DELEGATE hideLoadingIndicator];
                              
                              if (metal != nil) {
                                  if (self.settings.pushMetalID.integerValue == metal.metalID.integerValue) {
                                      NSDictionary *dict = [dbManager_ selectPushOptionForMetalID:metal.metalID];
                                      PushOption *option = [[PushOption alloc] initWithDictionary:dict];
                                      metal.pushOption = option;
                                      [option release];
                                  }
                                  else {
                                      metal.pushOption.isOn = PushOptionTypeOff;
                                      [dbManager_ updatePushOptionWithInfo:metal.pushOption.extractDictionary metalID:metal.metalID];
                                  }
                              }
                              
                              if ([self.delegate respondsToSelector:@selector(didFailSendingPushOptions)]) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.delegate didFailSendingPushOptions];
                                  });
                              }
                              
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                              message:@"Changes was not saved"
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              
                              [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                              [alert release];
                          }];
     */
}

- (void)_saveMetal:(Metal *)metal withInfo:(NSDictionary *)info
{
    PushOptionType isOn = [info[kPushIsOn] integerValue];
    double minVal = [info[kPushMinVal] doubleValue];
    double maxVal = [info[kPushMaxVal] doubleValue];
    
    
    if (self.settings.pushMetalID.integerValue != metal.metalID.integerValue) {
        Metal *prevMetal = [self metalByID:self.settings.pushMetalID];
        if (prevMetal != nil && prevMetal.pushOption.isOn == PushOptionTypeBadge && isOn == PushOptionTypeBadge) {
            prevMetal.pushOption.isOn = PushOptionTypeOff;
            [dbManager_ updatePushOptionWithInfo:prevMetal.pushOption.extractDictionary metalID:prevMetal.metalID];
        }
    }
    
    if (metal != nil) {
        metal.pushOption.isOn = isOn;
        if (isOn == PushOptionTypeThreshold) {
            metal.pushOption.minValue = minVal;
            metal.pushOption.maxValue = maxVal;
        }
        else if (isOn == PushOptionTypeBadge) {
            self.settings.pushMetalID = metal.metalID;
        }
    }
    else {
        self.settings.pushMetalID = @"0";
    }
    
    [dbManager_ updatePushOptionWithInfo:metal.pushOption.extractDictionary metalID:metal.metalID];
    [self synchronizeSettings];
    
    if ([self.delegate respondsToSelector:@selector(didSucceedSendingPushOptions)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didSucceedSendingPushOptions];
        });
    }
}

#pragma mark - Memory

- (void)dealloc
{
    [metals_ release];
    [availableMetals_ release];
    [turnedOnMetals_ release];
    [units_ release];
    [baseUnits_ release];
    [purchases_ release];
    [clients_ release];
    [diamonds_ release];
    [settings_ release];
    self.changedMetals = nil;
    [super dealloc];
}

@end
