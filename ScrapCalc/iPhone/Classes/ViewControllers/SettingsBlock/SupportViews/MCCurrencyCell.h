//
//  MCCurrencyCell.h
//  ScrapCalc
//
//  Created by word on 22.04.13.
//
//

#import <UIKit/UIKit.h>

@interface MCCurrencyCell : UITableViewCell {
    UIButton *btn_;
}

@property (nonatomic, readonly) UIButton *button;

- (void)makeSelectedCell:(BOOL)selected;
- (void)setFullText:(NSString *)text;
- (void)setShortText:(NSString *)text;

@end
