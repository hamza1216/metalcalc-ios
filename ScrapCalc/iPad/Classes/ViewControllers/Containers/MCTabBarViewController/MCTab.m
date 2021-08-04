//
//  MCTab.m
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import "MCTab.h"

@implementation MCTab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [[self icon] setHighlighted:selected];
    [[self background] setHighlighted:selected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
