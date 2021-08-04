//
//  Currency.m
//  ScrapCalc
//
//  Created by word on 17.04.13.
//
//

#import "Currency.h"

@implementation Currency

@synthesize currencyID;
@synthesize shortname;
@synthesize fullname;
@synthesize value;

- (void)setValue:(id)val forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.currencyID = [NSString stringWithFormat:@"%d", [val intValue]];
    else [super setValue:val forKey:key];
}

- (NSMutableDictionary *)extractDictionary
{
    NSMutableDictionary *dict = [super extractDictionary];
    dict[@"currencyID"] = [NSNull null];
    dict[@"shortname"] = [NSNull null];
    return dict;
}

- (NSMutableDictionary *)extractDictionaryWithShort
{
    NSMutableDictionary *dict = [super extractDictionary];
    dict[@"currencyID"] = [NSNull null];
    return dict;
}

- (void)dealloc
{
    [self setShortname:nil];
    [self setFullname:nil];
    [super dealloc];
}

@end
