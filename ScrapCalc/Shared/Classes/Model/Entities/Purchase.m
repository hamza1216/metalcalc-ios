//
//  Purchase.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "Purchase.h"

#define ID_LEN  5

@interface Purchase ()

@property (nonatomic, copy) NSString *formattedDatetime;
@property (nonatomic, copy) NSString *formattedID;

@end

@implementation Purchase

@synthesize purchaseID;
@synthesize clientID;
@synthesize price;
@synthesize timestamp;
@synthesize items;
@synthesize formattedDatetime;
@synthesize formattedID;
@synthesize isApproved;

- (void)customInit
{
    [super customInit];
    self.items = [NSMutableArray array];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.purchaseID = [NSString stringWithFormat:@"%d", [value intValue]];
    else if ([key isEqualToString:@"client_id"]) self.clientID = [NSString stringWithFormat:@"%d", [value intValue]];
    //else if ([key isEqualToString:@"total_price"]) self.price = [value doubleValue];
    else [super setValue:value forKey:key];
}

- (NSString *)keyForProperty:(NSString *)theProperty
{
    if ([theProperty isEqualToString:@"clientID"]) return @"client_id";
    if ([theProperty isEqualToString:@"price"]) return @"total_price";
    return [super keyForProperty:theProperty];
}

- (void)dealloc
{
    [purchaseID release];
    [items release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{id:%@, items:[%@], time:%f, approved:%@}", purchaseID, items, timestamp, (isApproved ? @"TRUE" : @"FALSE")];
}

- (void)setTimestamp:(double)theTimestamp
{
    timestamp = theTimestamp;
    self.formattedDatetime = nil;
}

- (NSString *)datetime
{
    if (self.formattedDatetime == nil) {
        NSDateFormatter *format = [NSDateFormatter new];
        format.dateFormat = @"MMMM dd, YYYY";
        
        self.formattedDatetime = [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timestamp]];
        [format release];
    }  
    
    return self.formattedDatetime;
}

- (NSString *)number
{
    if (self.formattedID == nil) {
        NSString *res = self.purchaseID;
        NSInteger dlen = ID_LEN - res.length;
        for (NSInteger i = 0; i < dlen; ++i) {
            res = [@"0" stringByAppendingString:res];
        }
        self.formattedID = res;
    }
    return self.formattedID;
}

- (NSComparisonResult)compare:(Purchase *)arg
{
    NSInteger a = arg.purchaseID.integerValue;
    NSInteger b = self.purchaseID.integerValue;
    if (a < b) return NSOrderedAscending;
    if (a > b) return NSOrderedDescending;
    return NSOrderedSame;
}

@end
