//
//  Purchase.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "BaseEntity.h"

@interface Purchase : BaseEntity

@property (nonatomic, copy) NSString *purchaseID;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, readonly) NSString *datetime;
@property (nonatomic, readonly) NSString *number;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, assign) BOOL isApproved;

- (NSComparisonResult)compare:(Purchase *)arg;

@end
