//
//  PurchaseItemCell.h
//  ScrapCalc
//
//  Created by word on 19.03.13.
//
//

#import <UIKit/UIKit.h>
#import "PurchaseItem.h"

#define PURCHASEITEM_CELL_HEIGHT    40


@interface PurchaseItemCell : UITableViewCell {
    UIImageView *backgroundView_;
    UILabel *weightLabel_;
    UILabel *unitLabel_;
    UILabel *purityLabel_;
    UILabel *metalLabel_;
    UILabel *priceLabel_;
    UIButton *button_;
    UIImageView *separatorImageView_;
}

@property (nonatomic, assign) BOOL configureWithButton;
@property (nonatomic, readonly) UIButton *button;

- (void)setWeight:(NSString *)theWeight;
- (void)setUnit:(NSString *)theUnit;
- (void)setPurity:(NSString *)thePurity;
- (void)setMetal:(NSString *)theMetal;
- (void)setPrice:(NSString *)thePrice;
- (void)setupWithPurchaseItem:(PurchaseItem *)thePurchaseItem;

@end
