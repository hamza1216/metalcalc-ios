//
//  Settings.h
//  ScrapCalc
//
//  Created by word on 28.03.13.
//
//

#import "BaseEntity.h"

@interface Settings : BaseEntity

@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, copy) NSString *currencyID;
@property (nonatomic, assign) double weight;
@property (nonatomic, assign) double spot;
@property (nonatomic, assign) NSInteger isPro;
@property (nonatomic, assign) double firstLaunch;
@property (nonatomic, assign) NSInteger showPercent;
@property (nonatomic, copy) NSString *pushMetalID;

@end
