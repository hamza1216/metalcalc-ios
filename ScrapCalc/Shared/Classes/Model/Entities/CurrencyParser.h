//
//  CurrencyParser.h
//  ScrapCalc
//
//  Created by Domovik on 13.11.13.
//
//

#import <Foundation/Foundation.h>


@class CurrencyParser;

@protocol CurrencyParserDelegate

- (void)currencyParser:(CurrencyParser *)parser didFinishParsingWithResult:(NSDictionary *)resultDictionary;
- (void)currencyParserDidFail:(CurrencyParser *)parser;

@end


@interface CurrencyParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, assign) NSObject<CurrencyParserDelegate> *delegate;

- (void)parseCurrencyData:(NSData *)data;

@end
