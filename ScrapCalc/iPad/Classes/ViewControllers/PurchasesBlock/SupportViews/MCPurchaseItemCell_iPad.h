//
//  MCPurchaseItemCell_iPad.h
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import <UIKit/UIKit.h>

#define PURCHASEITEM_CELL_HEIGHT    60

@interface MCPurchaseItemCell_iPad : UITableViewCell
{
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
