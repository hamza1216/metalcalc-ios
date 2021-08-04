//
//  Metal.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "BaseEntity.h"
#import "PushOption.h"

@interface Metal : BaseEntity

@property (nonatomic, copy) NSString *metalID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSMutableArray *purities;
@property (nonatomic, assign) double bidPrice;
@property (nonatomic, assign) double bidChange;
@property (nonatomic, assign) double bidTimestamp;
@property (nonatomic, assign) double purchasePrice;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) BOOL isAvailable;
@property (nonatomic, assign) NSInteger priceUnit;
@property (nonatomic, assign) double savedWeight;
@property (nonatomic, assign) NSInteger savedUnit;
@property (nonatomic, assign) double savedSpot;
@property (nonatomic, copy) NSString *savedPurity;
@property (nonatomic, retain) PushOption *pushOption;

- (NSString *)priceString;
- (double)bidPriceRaw;

- (void)setBidChangeWithPercent:(double)percent;
- (NSString *)bidDatetime;
- (NSString *)bidPercent;
- (NSDictionary *)bidDictionary;
- (NSDictionary *)savedDictionary;

- (void)setTimestampWithDateTime:(NSString *)datetime;
- (NSString *)imageName;
- (BOOL)isBaseMetal;

@end
