//
//  Client.m
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "Client.h"

@implementation Client

@synthesize clientID;
@synthesize firstname;
@synthesize lastname;
@synthesize phone;
@synthesize email;
@synthesize state;
@synthesize city;
@synthesize street;
@synthesize zip;
@synthesize icon;
@synthesize purchases;

- (void)customInit
{
    [super customInit];
    self.purchases = [NSMutableArray array];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.clientID = [NSString stringWithFormat:@"%d", [value intValue]];
    else if ([key isEqualToString:@"icon"]) self.icon = [UIImage imageWithData:value];
    else [super setValue:value forKey:key];
}

- (NSString *)name
{
    if (self.firstname.length < 1 && self.lastname.length < 1)
        return @"";
    if (self.firstname.length < 1)
        return self.lastname;
    if (self.lastname.length < 1)
        return self.firstname;
    return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
}

- (NSComparisonResult)compare:(Client *)arg
{
    NSComparisonResult res = [self.lastname compare:arg.lastname];
    if (res == NSOrderedSame)
        return [self.firstname compare:arg.firstname];
    return res;
}

#pragma mark - SQLite table compatibility

- (NSMutableDictionary *)extractDictionary
{
    NSMutableDictionary *dict = [super extractDictionary];
    dict[@"id"] = dict[@"name"] = dict[@"purchases"] = [NSNull null];
    return dict;
}

- (NSString *)keyForProperty:(NSString *)theProperty
{
    if ([theProperty isEqualToString:@"clientID"]) return @"id";
    return theProperty;
}

#pragma mark - Debug

- (NSString *)description
{
    return [NSString stringWithFormat:@"{id:%@, name:%@, purchases:%@}", clientID, self.name, purchases];
}

#pragma mark - Memory

- (void)dealloc
{
    [clientID release];
    [firstname release];
    [lastname release];
    [phone release];
    [email release];
    [state release];
    [city release];
    [street release];
    [zip release];
    [icon release];
    [purchases release];
    [super dealloc];
}

@end
