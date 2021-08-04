//
//  BaseEntity.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import <Foundation/Foundation.h>

@interface BaseEntity : NSObject

- (void)customInit;
- (id)initWithDictionary:(NSDictionary *)theDictionary;
- (NSMutableDictionary *)extractDictionary;
- (NSString *)keyForProperty:(NSString *)theProperty;

@end
