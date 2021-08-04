//
//  MCCurrencyCell_iPad.h
//  ScrapCalc
//
//  Created by Diana on 14.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCSettingsCell_iPad.h"

@interface MCCurrencyCell_iPad : MCSettingsCell_iPad

@property (nonatomic, retain) IBOutlet UIButton *button;

- (void)makeSelectedCell:(BOOL)selected;
- (void)setFullText:(NSString *)text;
- (void)setShortText:(NSString *)text;
@end
