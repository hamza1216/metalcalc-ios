//
//  Currency2.h
//  ScrapCalc
//
//  Created by word on 17.04.13.
//
//

#import "BaseEntity.h"

#define CURRENCY_URL(s)     [[@"http://www.google.com/ig/calculator?hl=en&q=1" stringByAppendingString:s] stringByAppendingString:@"%3D%3FUSD"]


@interface Currency : BaseEntity

@property (nonatomic, copy) NSString *currencyID;
@property (nonatomic, copy) NSString *shortname;
@property (nonatomic, copy) NSString *fullname;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) double value;

- (NSMutableDictionary *)extractDictionaryWithShort;

@end
