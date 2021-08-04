//
//  PurchaseCell_iPad.h
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import <UIKit/UIKit.h>

#define PURCHASE_CELL_HEIGHT        65
#define PURCHASE_SINGLE_FRAME       CGRectMake(8, 0, 280, PURCHASE_CELL_HEIGHT)
#define PURCHASE_NUMBER_FRAME_LANDSCAPE       CGRectMake(8, PURCHASE_CELL_HEIGHT/2-21, 280, 21)
#define PURCHASE_NUMBER_FRAME_PORTRAIT       CGRectMake(8, PURCHASE_CELL_HEIGHT/2-21, 560, 21)
#define PURCHASE_CLIENT_FRAME_LANDSCAPE       CGRectMake(8, PURCHASE_CELL_HEIGHT/2+1,  280, 21)
#define PURCHASE_CLIENT_FRAME_PORTRAIT      CGRectMake(8, PURCHASE_CELL_HEIGHT/2+1,  560, 21)
#define PURCHASE_ARROW_FRAME        CGRectMake(self.frame.size.width-40, (PURCHASE_CELL_HEIGHT-28)/2, 28, 28)
#define PURCHASE_SEPARATOR_FRAME    CGRectMake(0, self.contentView.frame.size.height-2, self.contentView.frame.size.width, 2)

@interface MCPurchaseCell_iPad : UITableViewCell
{
    UIImageView *bgView_;
    UIImageView *bgSelectedView_;
    UILabel *numberLabel_;
    UILabel *clientLabel_;
    UIImageView *arrowImageView_;
}

- (void)setNumber:(NSString *)theNumber;
- (void)setClient:(NSString *)theClientName;
-(void)updatePurchaseCell:(BOOL)isPortrait;
@end
