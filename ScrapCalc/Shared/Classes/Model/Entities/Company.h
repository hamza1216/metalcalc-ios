//
//  Company.h
//  ScrapCalc
//
//  Created by jhpassion on 7/7/14.
//
//

#import <Foundation/Foundation.h>

@interface Company : BaseEntity

@property (nonatomic, retain) NSString      *name;
@property (nonatomic, retain) NSString      *country;
@property (nonatomic, retain) NSString      *state;
@property (nonatomic, retain) NSString      *city;
@property (nonatomic, retain) NSString      *zip;
@property (nonatomic, retain) NSString      *street;

@end
