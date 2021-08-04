//
//  MCChartsView.h
//  ScrapCalc
//
//  Created by word on 24.04.13.
//
//

#import <UIKit/UIKit.h>
#import "ModelManager.h"


typedef NS_ENUM(NSInteger, ChartsPeriod) {
    ChartsPeriod30days,
    ChartsPeriod60days,
    ChartsPeriod6months,
    ChartsPeriod1year,
    ChartsPeriod5years,
    ChartsPeriod10years,
    ChartsPeriodCount
};


NS_INLINE NSString *
ChartsTitleFromPeriod(ChartsPeriod period)
{
    switch (period) {
        case ChartsPeriod30days: return @"30-day";
        case ChartsPeriod60days: return @"60-day";
        case ChartsPeriod6months: return @"6mo";
        case ChartsPeriod1year: return @"1yr";
        case ChartsPeriod5years: return @"5yr";
        case ChartsPeriod10years: return @"10yr";
        default: return @"";
    }
}

NS_INLINE NSString *
ChartsURLFromPeriod(ChartsPeriod period)
{
    switch (period) {
        case ChartsPeriod30days: return @"0030lnb";
        case ChartsPeriod60days: return @"0060lnb";
        case ChartsPeriod6months: return @"0182nyb";
        case ChartsPeriod1year: return @"0365nyb";
        case ChartsPeriod5years: return @"1825nyb";
        case ChartsPeriod10years: return @"3650nyb";
        default: return @"";
    }
}

NS_INLINE NSString *
ChartsBaseURLFromPeriod(ChartsPeriod period)
{
    switch (period) {
        case ChartsPeriod30days: return @"30d";
        case ChartsPeriod60days: return @"60d";
        case ChartsPeriod6months: return @"6m";
        case ChartsPeriod1year: return @"1y";
        case ChartsPeriod5years: return @"5y";
        default: return @"";
    }
}

NS_INLINE CGFloat
WidthForButtonIndex(ChartsPeriod period)
{
    switch (period) {
        case ChartsPeriod30days:    return 62;
        case ChartsPeriod60days:    return 62;
        case ChartsPeriod6months:   return 41;
        case ChartsPeriod1year:     return 37;
        case ChartsPeriod5years:    return 37;
        case ChartsPeriod10years:   return 37;
        default: return 0;
    }
}

NS_INLINE NSString *
MetalShortcut(NSString *metalname)
{
    metalname = metalname.lowercaseString;
    if ([metalname isEqualToString:@"gold"]) return @"au";
    if ([metalname isEqualToString:@"silver"]) return @"ag";
    if ([metalname isEqualToString:@"platinum"]) return @"pt";
    if ([metalname isEqualToString:@"palladium"]) return @"pd";
    return @"";
}

NS_INLINE NSString *
ImageURLWithMetalAndPeriod(NSString *metal, ChartsPeriod period)
{
    return [NSString stringWithFormat:@"http://www.kitco.com/LFgif/%@%@.gif", MetalShortcut(metal), ChartsURLFromPeriod(period)];
}

NS_INLINE UIImage *
ImageFromURL(NSString *metal, ChartsPeriod period)
{
    NSString *url = ImageURLWithMetalAndPeriod(metal, period);
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
}

NS_INLINE UIImage *
ImageForBaseMetal(NSString *metal, ChartsPeriod period)
{
    NSString *url = [NSString stringWithFormat:@"http://www.kitconet.com/charts/metals/base/spot-%@-%@-Large.gif", metal, ChartsBaseURLFromPeriod(period)];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
}


@protocol MCChartsViewDelegate

@optional
- (void)chartsShouldMoveUp;
- (void)chartsShouldMoveDown;
- (void)chartsSimpleTap;

@end

@interface MCChartsView : UIView {
    CGRect touchZone_;
    BOOL properTouch_;
    CGPoint startTouchPoint_;
    
    UIImageView *chartImageView_;
    BOOL simpleTap_;
}

@property (nonatomic, assign) IBOutlet NSObject<MCChartsViewDelegate> *delegate;

- (void)changeMetal:(Metal *)metal;

@end
