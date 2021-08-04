//
//  Settings.m
//  ScrapCalc
//
//  Created by word on 28.03.13.
//
//

#import "Settings.h"

@implementation Settings

@synthesize unitID;
@synthesize currencyID;
@synthesize weight;
@synthesize spot;
@synthesize isPro;
@synthesize firstLaunch;
@synthesize showPercent;

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"unit_id"]) self.unitID = [NSString stringWithFormat:@"%d", (int)[value integerValue]];
    else if ([key isEqualToString:@"currency_id"]) self.currencyID = [NSString stringWithFormat:@"%d", (int)[value integerValue]];
    else [super setValue:value forKey:key];
}

#pragma mark - SQLite table compatibility

- (NSString *)keyForProperty:(NSString *)theProperty
{
    if ([theProperty isEqualToString:@"unitID"]) return @"unit_id";
    if ([theProperty isEqualToString:@"currencyID"]) return @"currency_id";
    return theProperty;
}

- (void)dealloc
{
    [unitID release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SETTINGS: %@ %f %f}", unitID, weight, spot];
}

@end
