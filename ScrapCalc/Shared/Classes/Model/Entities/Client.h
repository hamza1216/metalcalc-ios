//
//  Client.h
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "BaseEntity.h"

@interface Client : BaseEntity

@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;
@property (nonatomic, readonly) NSString *name; // firstname+lastname
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSMutableArray *purchases;

- (NSComparisonResult)compare:(Client *)arg;

@end
