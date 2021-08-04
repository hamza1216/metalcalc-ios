//
//  MCMetalCell.h
//  ScrapCalc
//
//  Created by word on 12.04.13.
//
//

#import <UIKit/UIKit.h>

#define METAL_CELL_HEIGHT   100

#define METAL_NAME_FRAME    CGRectMake(67, METAL_CELL_HEIGHT/2-25, 200, 24)
#define METAL_UNIT_FRAME    CGRectMake(self.frame.size.width/2, METAL_CELL_HEIGHT/2-20, self.frame.size.width/2-28, 20)
#define METAL_PRICE_FRAME   CGRectMake(0, METAL_CELL_HEIGHT/2, self.frame.size.width-28, METAL_CELL_HEIGHT/2)
#define METAL_ICON_FRAME    CGRectMake(3, 15, 70, 80)

#define DIAMOND_ICON_FRAME  CGRectMake( 3, 9, 77, 67)
#define DIAMOND_LABEL_FRAME CGRectMake(90, (METAL_CELL_HEIGHT-50)/2, 200, 50)

@interface MCMetalCell : UITableViewCell {
    UILabel *metalLabel_;
    UILabel *unitLabel_;
    UILabel *priceLabel_;
    UIImageView *iconView_;
}

- (void)setMetalName:(NSString *)metal;
- (void)setUnitText:(NSString *)unit;
- (void)setPrice:(NSString *)price;
- (void)setIcon:(UIImage *)icon;

- (void)configSimple;
- (void)configDiamond;

@end
