//
//  MCMetalCellNew.h
//  ScrapCalc
//
//  Created by word on 23.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Metal.h"

#define METAL_CELL_NEW_HEIGHT   52

@interface MCMetalCellNew : UITableViewCell {
    UILabel *nameLabel_;
    UILabel *priceLabel_;
    UILabel *changeLabel_;
}

- (void)setupWithMetal:(Metal *)metal;
- (void)setupWithDiamond;

@end
