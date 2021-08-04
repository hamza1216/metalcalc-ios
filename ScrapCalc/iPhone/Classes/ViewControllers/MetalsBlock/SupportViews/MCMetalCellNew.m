//
//  MCMetalCellNew.m
//  ScrapCalc
//
//  Created by word on 23.04.13.
//
//

#import "MCMetalCellNew.h"
#import "NSString+NumbersFormats.h"

@implementation MCMetalCellNew

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [self setBackgroundView:bgView];
        [bgView release];
        
        nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 92, METAL_CELL_NEW_HEIGHT)];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = ColorFromHexFormat(0xde8b14);
        nameLabel_.shadowColor = [UIColor blackColor];
        nameLabel_.shadowOffset = CGSizeMake(0,0);
        nameLabel_.minimumScaleFactor = 12 / nameLabel_.font.pointSize;
        nameLabel_.adjustsFontSizeToFitWidth = YES;
        nameLabel_.font = FONT_MYRIAD_BOLD(17);
        [self.contentView addSubview:nameLabel_];
        
        priceLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(98, 4, 120, METAL_CELL_NEW_HEIGHT)];
        priceLabel_.backgroundColor = [UIColor clearColor];
        priceLabel_.textColor = ColorFromHexFormat(0xffffff);
        priceLabel_.shadowColor = [UIColor blackColor];
        priceLabel_.shadowOffset = CGSizeMake(0,0);
        priceLabel_.textAlignment = NSTextAlignmentRight;
        priceLabel_.minimumScaleFactor = 13 / priceLabel_.font.pointSize;
        priceLabel_.adjustsFontSizeToFitWidth = YES;
        priceLabel_.font = FONT_MYRIAD_BOLD(18);
        [self.contentView addSubview:priceLabel_];
        
        changeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(226, 4, 90, METAL_CELL_NEW_HEIGHT)];
        changeLabel_.backgroundColor = [UIColor clearColor];
        changeLabel_.shadowColor = [UIColor blackColor];
        changeLabel_.shadowOffset = CGSizeMake(0,0);
        changeLabel_.textAlignment = NSTextAlignmentCenter;
        changeLabel_.minimumScaleFactor = 8 / changeLabel_.font.pointSize;
        changeLabel_.adjustsFontSizeToFitWidth = YES;
        changeLabel_.font = FONT_MYRIAD_BOLD(14);
        [self.contentView addSubview:changeLabel_];
        
        UIImageView *separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, METAL_CELL_NEW_HEIGHT-1, self.frame.size.width, 2)];
        separatorImageView.image = [UIImage imageNamed:@"separator_full.png"];
        [self.contentView addSubview:separatorImageView];
        [separatorImageView release];
    }
    return self;
}

- (void)setupWithMetal:(Metal *)metal
{
    priceLabel_.hidden = changeLabel_.hidden = NO;
    
    nameLabel_.frame = CGRectMake(6, 4, 90, METAL_CELL_NEW_HEIGHT);
    nameLabel_.text = metal.name.uppercaseString;
    priceLabel_.text = [NSString stringWithPrice:metal.bidPrice];
    
    if ([metal.bidPercent isEqualToString:@"0.0000%"] && metal.bidChange == 0.0) {
        changeLabel_.text = @"0.00% 0.0000%";
        changeLabel_.textColor = ColorFromHexFormat(0x868686);
        return;
    }
    
    BOOL plus = ([metal.bidPercent hasPrefix:@"+"]);
    
    changeLabel_.text = [NSString stringWithFormat:@"%.2lf %@", metal.bidChange, metal.bidPercent];
    if (plus) {
        changeLabel_.text = [@"+" stringByAppendingString:changeLabel_.text];
    }
    
    if ([changeLabel_.text hasPrefix:@"+"]) {
        changeLabel_.textColor = ColorFromHexFormat(0x2d6910);        
    }
    else {
        changeLabel_.textColor = ColorFromHexFormat(0xba0000);        
    }
}

- (void)setupWithDiamond
{
    priceLabel_.hidden = changeLabel_.hidden = YES;
    nameLabel_.frame = CGRectMake(6, 4, 280, METAL_CELL_NEW_HEIGHT);
    nameLabel_.text = @"DIAMOND CALCULATOR";
}

- (void)dealloc
{
    [nameLabel_ release];
    [priceLabel_ release];
    [changeLabel_ release];
    [super dealloc];
}

@end
