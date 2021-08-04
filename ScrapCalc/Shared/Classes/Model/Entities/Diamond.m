//
//  Diamond.m
//  ScrapCalc
//
//  Created by word on 30.05.13.
//
//

#import "Diamond.h"

@implementation Diamond

@synthesize diamondID;
@synthesize name;
@synthesize savedValue;
@synthesize values;

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.diamondID = [NSString stringWithFormat:@"%d",[value intValue]];
    else [super setValue:value forKey:key];
}

- (NSMutableDictionary *)extractDictionary
{
    NSMutableDictionary *dict = [super extractDictionary];
    dict[@"diamondID"] = [NSNull null];
    dict[@"values"] = [NSNull null];
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@\n%@", NSStringFromClass(self.class), self.name, self.values];
}

- (void)dealloc
{
    [values release];
    self.diamondID = nil;
    self.name = nil;
    [super dealloc];
}

@end
