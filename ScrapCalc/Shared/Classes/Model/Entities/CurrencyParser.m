//
//  CurrencyParser.m
//  ScrapCalc
//
//  Created by Domovik on 13.11.13.
//
//

#import "CurrencyParser.h"

static NSString* const kParseKeyItem        	= @"item";
static NSString* const kParseKeyTarget       	= @"targetCurrency";
static NSString* const kParseKeyRate            = @"exchangeRate";


@interface CurrencyParser ()

@property (nonatomic, assign) BOOL isInsideItem;
@property (nonatomic, copy) NSString *processingTag;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, retain) NSMutableDictionary *resultDictionary;
@property (nonatomic, copy) NSString *rate;
@end


@implementation CurrencyParser

- (void)parseCurrencyData:(NSData *)data
{
    self.resultDictionary = [NSMutableDictionary dictionary];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.processingTag = elementName;
    if ([elementName isEqualToString:kParseKeyItem]) {
        self.isInsideItem = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kParseKeyItem]) {
        
        if (self.target.length && self.rate.length) {
            self.resultDictionary[self.target] = self.rate;
        }
        
        self.target = nil;
        self.rate = nil;
        
        self.isInsideItem = NO;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\t\n"]];
    
    if (!self.isInsideItem || string.length < 1) {
        return;
    }
    
    if ([self.processingTag isEqualToString:kParseKeyTarget]) {
        self.target = string;
    }
    else if ([self.processingTag isEqualToString:kParseKeyRate]) {
        self.rate = string;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.delegate currencyParser:self didFinishParsingWithResult:self.resultDictionary];
    [parser release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self.delegate currencyParserDidFail:self];
    [parser release];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    [self.delegate currencyParserDidFail:self];
    [parser release];
}


#pragma mark - Memory

- (void)dealloc
{
    self.resultDictionary = nil;
    self.target = nil;
    self.rate = nil;
    self.processingTag = nil;
    [super dealloc];
}


@end
