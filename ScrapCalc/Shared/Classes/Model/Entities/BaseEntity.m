//
//  BaseEntity.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "BaseEntity.h"
#include <objc/runtime.h>

@implementation BaseEntity

- (id)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)theDictionary
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:theDictionary];
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    @try {
        [super setValue:value forUndefinedKey:key];
    }
    @catch (NSException *exception) {
        //NSLog(@"%@", exception.description);
    }
    @finally {
        
    }
}

- (NSMutableDictionary *)extractDictionary
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSArray *properties = [[self class] getClassProperties];    
	for (NSUInteger i = 0; i < [properties count]; ++i) {
        
		NSString *_name = [properties objectAtIndex:i];        
		id value = [self valueForKey:_name];        
		if (value == nil) {
			value = [NSNull null];
		}
        
		[dict setObject:value forKey:[self keyForProperty:_name]];
	}    
	return dict;
}

- (NSString *)keyForProperty:(NSString *)theProperty
{
    return theProperty;
}

+ (NSMutableArray *)getClassProperties
{
	NSMutableArray *array = nil;
    
	if ([self superclass] != [NSObject class]) {
		array = (NSMutableArray *)[[self superclass] getClassProperties];
	}
    else {
		array = [NSMutableArray array];
	}
    
	NSUInteger cnt = 0;
	objc_property_t *properties = class_copyPropertyList([self class], &cnt);
    
	for (NSUInteger i = 0; i < cnt; ++i) {
		NSString *name = [NSString stringWithUTF8String:property_getName(properties[i])];
		[array addObject:name];
	}
    
	free(properties);    
	return array;
}

@end
