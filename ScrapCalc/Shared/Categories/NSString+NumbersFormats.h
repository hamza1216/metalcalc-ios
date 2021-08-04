//
//  NSString+NumbersFormats.h
//  ScrapCalc
//
//  Created by word on 26.03.13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (NumbersFormats)

+ (NSString *)stringWithDouble:(double)price;
+ (NSString *)stringWithPrice:(double)price;
+ (NSString *)stringWithPercent:(double)percent;
+ (NSString *)stringWithWeight:(double)weight;

@end
