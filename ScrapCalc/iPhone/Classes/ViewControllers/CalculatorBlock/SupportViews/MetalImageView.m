//
//  MetalImageView.m
//  ScrapCalc
//
//  Created by word on 24.04.13.
//
//

#import "MetalImageView.h"

@implementation MetalImageView

@synthesize name;

- (void)setSelected:(BOOL)selected
{    
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@%@.png", self.name.lowercaseString, (selected ? @"01" : @"02"), (IS_IPAD ? @"_ipad" : @"")]];;
}

@end
