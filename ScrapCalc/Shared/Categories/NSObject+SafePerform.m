//
//  NSObject+SafePerform.m
//  ScrapCalc
//
//  Created by Domovik on 14.08.13.
//
//

#import "NSObject+SafePerform.h"

@implementation NSObject (SafePerform)

- (BOOL)safePerformSelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector]) {
        [self performSelector:aSelector];
        return YES;
    }
    return NO;
}

@end
