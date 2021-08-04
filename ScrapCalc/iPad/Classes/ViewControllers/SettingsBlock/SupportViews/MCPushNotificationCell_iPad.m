//
//  MCPushNotificationCell_iPad.m
//  ScrapCalc
//
//  Created by Diana on 30.08.13.
//
//

#import "MCPushNotificationCell_iPad.h"

@implementation MCPushNotificationCell_iPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGRect frame = self.switcher.frame;
    frame.origin.x = self.frame.size.width - self.switcher.frame.size.width + 357;
    frame.size.height = self.backgroundImageView.frame.size.height;
    frame.origin.y += 2;
    self.switcher.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    self.backgroundImageView.image = [UIImage imageNamed:(selected ? SETTINGS_CELL_BG_IMAGE_SEL : SETTINGS_CELL_BG_IMAGE_NORM)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setUpWithMetal:(Metal *)metal
{
    self.rangeButton.enabled = (metal.pushOption.isOn == PushOptionTypeThreshold);
    self.titleLabel.text = metal.name;
    [self.rangeButton setTitle:[self titleForRangeButtonWithMetal:metal] forState:UIControlStateNormal];
    [self.rangeLabel setTextColor:(metal.pushOption.isOn == PushOptionTypeThreshold) ? [UIColor whiteColor] : [UIColor lightGrayColor]];
    [[self switcher] setCurrentType:metal.pushOption.isOn animated:NO];
}

- (NSString *)titleForRangeButtonWithMetal:(Metal *)metal
{
    return [NSString stringWithFormat:@"%.2f - %.2f", metal.pushOption.minValue, metal.pushOption.maxValue];
}

@end
