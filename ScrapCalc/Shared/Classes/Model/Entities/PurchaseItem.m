//
//  PurchaseItem.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "PurchaseItem.h"

@implementation PurchaseItem

@synthesize itemID;
@synthesize purchaseID;
@synthesize purityName;
@synthesize metal;
@synthesize unit;
@synthesize weight;
@synthesize price;

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.itemID = [NSString stringWithFormat:@"%d", [value intValue]];
    else if ([key isEqualToString:@"purchase_id"]) self.purchaseID = [NSString stringWithFormat:@"%d", [value intValue]];
    else if ([key isEqualToString:@"purity_name"]) self.purityName = value;
    else [super setValue:value forKey:key];
}

- (NSString *)keyForProperty:(NSString *)theProperty
{
    if ([theProperty isEqualToString:@"purchaseID"]) return @"purchase_id";
    if ([theProperty isEqualToString:@"purityName"]) return @"purity_name";
    return theProperty;
}

- (NSMutableDictionary *)extractDictionary
{
    NSMutableDictionary *dict = [super extractDictionary];
    dict[@"metal"] = dict[@"unit"] = [NSNull null];
    dict[@"metal_id"] = self.metal.metalID;
    dict[@"unit_id"] = self.unit.unitID;
    
    return dict;
}

- (void)dealloc
{
    [itemID release];
    [purchaseID release];
    [purityName release];
    [metal release];
    [unit release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@_%@:{ metal:%@, purity:%@, unit:%@, weight:%f, price:%f },", itemID, purchaseID, metal, purityName, unit, weight, price];
}

@end
