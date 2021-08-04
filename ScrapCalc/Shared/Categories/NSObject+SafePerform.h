//
//  NSObject+SafePerform.h
//  ScrapCalc
//
//  Created by Domovik on 14.08.13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (SafePerform)

- (BOOL)safePerformSelector:(SEL)aSelector;

@end
