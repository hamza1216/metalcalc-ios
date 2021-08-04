//
//  NSString+NumbersFormats.m
//  ScrapCalc
//
//  Created by word on 26.03.13.
//
//

#import "NSString+NumbersFormats.h"
#import "ModelManager.h"

@implementation NSString (NumbersFormats)

+ (NSString *)stringWithDouble:(double)price
{
    NSString *str = [NSString stringWithFormat:@"%lf", price];
    while ([str hasSuffix:@"0"]) {
        str = [str substringToIndex:str.length-2];
    }
    
    NSRange dotRange = [str rangeOfString:@"."];
    if (dotRange.location == NSNotFound || (str.length-dotRange.location < 3)) {
        str = [NSString stringWithFormat:@"%.2lf", price];
        dotRange.location = str.length-3;        
    }
    
    NSMutableString *res = [NSMutableString string];
    for (NSInteger cnt = 0, i = dotRange.location+2; i >= 0; --i, ++cnt) {
        if (cnt > 3 && (cnt%3 == 0)) {
            [res insertString:@"," atIndex:0];
        }
        [res insertString:[NSString stringWithFormat:@"%c", [str characterAtIndex:i]] atIndex:0];
    }
    return res;
}

+ (NSString *)stringWithPrice:(double)price
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.currencyCode = [[[ModelManager shared] selectedCurrency] shortname];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSString *res = [formatter stringFromNumber:[NSNumber numberWithDouble:price]];
    if ([res rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
        price = 0;
        res = [formatter stringFromNumber:[NSNumber numberWithDouble:price]];
    }
    
    [formatter release];
    return res;
}

+ (NSString *)stringWithPercent:(double)percent
{
    NSMutableString *res = [NSMutableString string];
    if (percent > 0.0) {
        [res appendString:@"+"];
    }
    [res appendFormat:@"%f", percent];
    
    NSInteger dotIndex = [res rangeOfString:@"."].location;
    NSInteger lastIndex = res.length - 1;
    
    while (lastIndex - dotIndex > 2 && [res characterAtIndex:lastIndex] == '0') {
        [res deleteCharactersInRange:NSMakeRange(lastIndex, 1)];
        lastIndex--;
    }
    
    return res;
}

+ (NSString *)stringWithWeight:(double)weight
{
    NSString *res = [NSString stringWithFormat:@"%.2lf", weight];
    if ([res hasSuffix:@".00"]) {
        res = [res substringToIndex:res.length-3];
    }
    else if ([res hasSuffix:@"0"]) {
        res = [res substringToIndex:res.length-1];
    }
    return res;
}

@end
