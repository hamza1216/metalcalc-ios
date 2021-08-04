//
//  Unit.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "BaseEntity.h"

@interface Unit : BaseEntity

@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, assign) double weight;

@end
