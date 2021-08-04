//
//  MCRegularLabel.m
//  ScrapCalc
//
//  Created by word on 26.04.13.
//
//

#import "MCRegularLabel.h"

@implementation MCRegularLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = FONT_MYRIAD_REGULAR(self.font.pointSize);
}

@end
