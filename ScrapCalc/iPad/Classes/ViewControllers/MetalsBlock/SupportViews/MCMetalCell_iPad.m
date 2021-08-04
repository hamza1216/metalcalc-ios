//
//  MCMetalCell_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import "MCMetalCell_iPad.h"

@implementation MCMetalCell_iPad

- (void)awakeFromNib
{
    self.priceLabel.font = FONT_MYRIAD_BOLD(self.priceLabel.font.pointSize);    
}

- (void)setupWithType:(MCMetalCellType)type andMetal:(Metal *)metal
{
    UIImage *nameImage; 
    
    if (metal == nil) {
        nameImage = MCMetalCellNameImage(kDiamondsName, type);
        self.priceLabel.text = @"";
    }
    else {
        nameImage = MCMetalCellNameImage(metal.name, type);
        self.priceLabel.text = metal.priceString;
    }    
       
    CGSize imageSize = nameImage.size;
    CGFloat y = (self.backgroundImageView.frame.size.height / 2 - imageSize.height) / 2 + 2;
    
    self.nameImageView.frame = CGRectMake(self.nameImageView.frame.origin.x, y, imageSize.width, imageSize.height);
    self.nameImageView.image = nameImage;    
    
    self.backgroundImageView.image  = MCMetalCellBackgroundImage(type);
    self.arrowImageView.image       = MCMetalCellArrowImage(type);
}

@end
