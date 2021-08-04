//
//  MCBoldCondLabel.m
//  ScrapCalc
//
//  Created by word on 31.05.13.
//
//

#import "MCBoldCondLabel.h"

@implementation MCBoldCondLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = FONT_MYRIAD_BOLDCOND(self.font.pointSize);
}

@end
