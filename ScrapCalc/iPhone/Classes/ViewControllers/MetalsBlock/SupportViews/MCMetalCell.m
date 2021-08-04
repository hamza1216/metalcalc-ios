//
//  MCMetalCell.m
//  ScrapCalc
//
//  Created by word on 12.04.13.
//
//

#import "MCMetalCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MCMetalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundNew.png"]];
        self.backgroundView = imgView;
        [imgView release];
        
        metalLabel_ = [[self getNewLabelWithFrame:METAL_NAME_FRAME font:22 bold:YES] retain];
        metalLabel_.numberOfLines = 2;
        unitLabel_ = [[self getNewLabelWithFrame:METAL_UNIT_FRAME font:10 bold:YES] retain];
        unitLabel_.textAlignment = NSTextAlignmentCenter;
        priceLabel_ = [[self getNewLabelWithFrame:METAL_PRICE_FRAME font:32 bold:YES] retain];
        priceLabel_.textAlignment = NSTextAlignmentRight;
        
        iconView_ = [[UIImageView alloc] initWithFrame:METAL_ICON_FRAME];
        [self.contentView addSubview:iconView_];
    }
    return self;
}

- (UILabel *)getNewLabelWithFrame:(CGRect)frame font:(CGFloat)font bold:(BOOL)bold
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = bold ? [UIFont boldSystemFontOfSize:font] : [UIFont systemFontOfSize:font];
    [self.contentView addSubview:label];
    return [label autorelease];
}

- (void)setMetalName:(NSString *)metal
{
    metalLabel_.text = metal;
}

- (void)setUnitText:(NSString *)unit
{
    unitLabel_.text = unit;
}

- (void)setPrice:(NSString *)price
{
    priceLabel_.text = price;
}

- (void)setIcon:(UIImage *)icon
{
    iconView_.image = icon;
}

- (void)configSimple
{
    metalLabel_.frame = METAL_NAME_FRAME;
    iconView_.frame = METAL_ICON_FRAME;
    priceLabel_.hidden = unitLabel_.hidden = NO;
}

- (void)configDiamond
{
    metalLabel_.frame = DIAMOND_LABEL_FRAME;
    iconView_.frame = DIAMOND_ICON_FRAME;
    priceLabel_.hidden = unitLabel_.hidden = YES;
}

- (void)dealloc
{
    [metalLabel_ release];
    [unitLabel_ release];
    [priceLabel_ release];
    [iconView_ release];
    [super dealloc];
}

@end
