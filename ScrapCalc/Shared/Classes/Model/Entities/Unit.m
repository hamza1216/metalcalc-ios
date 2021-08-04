//
//  Unit.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "Unit.h"

@implementation Unit

@synthesize unitID;
@synthesize name;
@synthesize shortName;
@synthesize weight;

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) self.unitID = [NSString stringWithFormat:@"%d", (int)[value integerValue]];
    else if ([key isEqualToString:@"short_name"]) self.shortName = value;
    else [super setValue:value forKey:key];
}

- (void)dealloc
{
    [unitID release];
    [name release];
    [shortName release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{%@:%@:%f}", unitID, name, weight];
}

@end
