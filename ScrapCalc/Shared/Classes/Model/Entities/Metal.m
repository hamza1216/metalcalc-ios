//
//  Metal.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "Metal.h"
#import "ModelManager.h"

@implementation Metal

@synthesize metalID;
@synthesize name;
@synthesize purities;
@synthesize bidPrice;
@synthesize bidChange;
@synthesize bidTimestamp;
@synthesize purchasePrice;
@synthesize isAvailable;
@synthesize isOn;
@synthesize priceUnit;
@synthesize savedWeight;
@synthesize savedUnit;
@synthesize savedSpot;
@synthesize savedPurity;

- (void)customInit
{
    [super customInit];
    self.purities = [NSMutableArray array];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.metalID = [NSString stringWithFormat:@"%d",[value intValue]];
    else [super setValue:value forKey:key];
}

- (NSString *)priceString
{
    return [NSString stringWithPrice:self.bidPrice];
}

- (void)setTimestampWithDateTime:(NSString *)datetime
{    
    NSDateFormatter *formatter = [NSDateFormatter new];
//    formatter.dateFormat = @"MM/dd/yyyy HH:mm";
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ssZ";
    NSDate *date = [formatter dateFromString:datetime];
    self.bidTimestamp = [date timeIntervalSince1970];
    [formatter release];
}

- (NSString *)bidDatetime
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"dd/MM/yy HH:mm";
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ssZ";
    NSString *res = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:bidTimestamp]];
    [formatter release];
    return res;
}

- (double)bidPrice
{
    return bidPrice * [[[ModelManager shared] selectedCurrency] value];
}

- (double)bidPriceRaw
{
    return bidPrice;
}

- (double)bidChange
{
    return bidChange * [[[ModelManager shared] selectedCurrency] value];
}

- (NSString *)bidPercent
{
    double percent = (bidPrice == bidChange ? 0 : 100 * bidChange / (bidPrice - bidChange));
    return [NSString stringWithFormat:@"%@%.4lf%%", (percent > 0 ? @"+" : @""), percent];
}

- (NSDictionary *)bidDictionary
{
    NSString *price = [NSString stringWithFormat:@"%f", bidPrice];
    NSString *change = [NSString stringWithFormat:@"%f", bidChange];
    NSString *timestamp = [NSString stringWithFormat:@"%f", bidTimestamp];
    
    return @{ @"bidPrice":price, @"bidChange":change, @"bidTimestamp":timestamp };
}

- (NSDictionary *)savedDictionary
{
    NSString *weight = [NSString stringWithFormat:@"%f", self.savedWeight];
    NSString *unit = [NSString stringWithFormat:@"%d", (int)self.savedUnit];
    NSString *spot = [NSString stringWithFormat:@"%f", self.savedSpot];
    
    return @{ @"savedWeight":weight, @"savedUnit":unit, @"savedPurity":self.savedPurity, @"savedSpot":spot };
}

- (void)setBidChangeWithPercent:(double)percent
{
    bidChange = bidPrice - bidPrice / (1 + percent / 100);
}

- (NSString *)imageName
{
    return [NSString stringWithFormat:@"metal_%d.png", self.metalID.intValue-1];
}

- (BOOL)isBaseMetal
{
    if ([self.name.lowercaseString isEqualToString:@"gold"]) return NO;
    if ([self.name.lowercaseString isEqualToString:@"silver"]) return NO;
    if ([self.name.lowercaseString isEqualToString:@"platinum"]) return NO;
    if ([self.name.lowercaseString isEqualToString:@"palladium"]) return NO;
    return YES;
}

- (void)dealloc
{
    [metalID release];
    [name release];
    [purities release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Metal '%@'(%@): %.2lf [%f] %@ (%@) $%.2lf", name, metalID, bidPrice, bidTimestamp, (isAvailable ? @"avail" : @"NOT avail"), (isOn ? @"ON" : @"OFF"), purchasePrice];
}

@end
