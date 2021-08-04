//
//  MCSemiboldLabel.m
//  ScrapCalc
//
//  Created by word on 26.04.13.
//
//

#import "MCSemiboldLabel.h"

@implementation MCSemiboldLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = FONT_MYRIAD_SEMIBOLD(self.font.pointSize);
}

@end
