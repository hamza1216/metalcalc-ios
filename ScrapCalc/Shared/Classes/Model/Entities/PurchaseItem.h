//
//  PurchaseItem.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "BaseEntity.h"
#import "Metal.h"
#import "Unit.h"

@interface PurchaseItem : BaseEntity

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *purchaseID;
@property (nonatomic, copy) NSString *purityName;
@property (nonatomic, retain) Metal *metal;
@property (nonatomic, retain) Unit *unit;
@property (nonatomic, assign) double weight;
@property (nonatomic, assign) double price;

@end
