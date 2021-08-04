//
//  PushOption.h
//  ScrapCalc
//
//  Created by Domovik on 09.08.13.
//
//

#import "BaseEntity.h"


typedef NS_ENUM (NSInteger, PushOptionType) {
    PushOptionTypeThreshold,
    PushOptionTypeOff,
    PushOptionTypeBadge    
};


@interface PushOption : BaseEntity

@property (nonatomic, assign) PushOptionType isOn;
@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double maxValue;

@end
