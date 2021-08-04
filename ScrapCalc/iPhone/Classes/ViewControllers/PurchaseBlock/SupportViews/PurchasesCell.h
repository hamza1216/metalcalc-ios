//
//  PurchaseCell.h
//  ScrapCalc
//
//  Created by word on 18.03.13.
//
//

#import <UIKit/UIKit.h>

#define PURCHASE_CELL_HEIGHT        68
#define PURCHASE_SINGLE_FRAME       CGRectMake(8, 0, 280, PURCHASE_CELL_HEIGHT)
#define PURCHASE_NUMBER_FRAME       CGRectMake(8, PURCHASE_CELL_HEIGHT/2-19, 280, 19)
#define PURCHASE_CLIENT_FRAME       CGRectMake(8, PURCHASE_CELL_HEIGHT/2+1,  280, 19)
#define PURCHASE_ARROW_FRAME        CGRectMake(self.frame.size.width-40, (PURCHASE_CELL_HEIGHT-28)/2, 28, 28)
#define PURCHASE_SEPARATOR_FRAME    CGRectMake(0, PURCHASE_CELL_HEIGHT-2, self.contentView.frame.size.width, 2)

@interface PurchasesCell : UITableViewCell {
    UILabel *numberLabel_;
    UILabel *clientLabel_;
    UIImageView *separatorImageView_;
}

- (void)setNumber:(NSString *)theNumber;
- (void)setClient:(NSString *)theClientName;

@end
