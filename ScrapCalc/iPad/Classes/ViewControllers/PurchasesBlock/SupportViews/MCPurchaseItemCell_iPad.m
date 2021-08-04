//
//  MCPurchaseItemCell_iPad.m
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCPurchaseItemCell_iPad.h"

#define PI_H    PURCHASEITEM_CELL_HEIGHT
#define PI_X    8

#define PURITEM_WEIGHT_FRAME    CGRectMake(  15, 0, 108, PI_H)
#define PURITEM_UNIT_FRAME      CGRectMake( 138, 0, 114, PI_H)
#define PURITEM_PURITY_FRAME    CGRectMake(267, 0, 54, PI_H)
#define PURITEM_METAL_FRAME     CGRectMake(336, 0, 116, PI_H)
#define PURITEM_PRICE_FRAME     CGRectMake(467, 0, 160, PI_H)

#define PURITEM_WEIGHT_FRAME_   CGRectMake(  5, 0, 48, PI_H)
#define PURITEM_UNIT_FRAME_     CGRectMake( 58, 0, 57, PI_H)
#define PURITEM_PURITY_FRAME_   CGRectMake(120, 0, 27, PI_H)
#define PURITEM_METAL_FRAME_    CGRectMake(152, 0, 58, PI_H)
#define PURITEM_PRICE_FRAME_    CGRectMake(215, 0, 72, PI_H)

#define BTN_E   22
#define PURITEM_BUTTON_FRAME    CGRectMake(self.frame.size.width-BTN_E-6, (PI_H-BTN_E)/2, BTN_E, BTN_E)

#define PURITEM_SEPARATOR_FRAME CGRectMake(0, self.contentView.frame.size.height-2, self.contentView.frame.size.width, 2)

@implementation MCPurchaseItemCell_iPad

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        weightLabel_    = [[self getNewLabelWithFrame:PURITEM_WEIGHT_FRAME] retain];
        unitLabel_      = [[self getNewLabelWithFrame:PURITEM_UNIT_FRAME]   retain];
        purityLabel_    = [[self getNewLabelWithFrame:PURITEM_PURITY_FRAME] retain];
        metalLabel_     = [[self getNewLabelWithFrame:PURITEM_METAL_FRAME]  retain];
        priceLabel_     = [[self getNewLabelWithFrame:PURITEM_PRICE_FRAME]  retain];
        
        separatorImageView_ = [[UIImageView alloc] initWithFrame:PURITEM_SEPARATOR_FRAME];
        separatorImageView_.image = [UIImage imageNamed:@"separator_full.png"];
        [self.contentView addSubview:separatorImageView_];
        
        button_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        button_.frame = PURITEM_BUTTON_FRAME;
        [button_ setBackgroundImage:[UIImage imageNamed:@"calc_remove_button.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:button_];
        
        self.configureWithButton = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    separatorImageView_.frame = PURITEM_SEPARATOR_FRAME;
}

- (UILabel *)getNewLabelWithFrame:(CGRect)theFrame
{
    UILabel *label = [[UILabel alloc] initWithFrame:theFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:23];
    label.minimumScaleFactor = 9;
    label.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:label];
    return [label autorelease];
}

- (void)setWeight:(NSString *)theWeight
{
    weightLabel_.text = theWeight;
}

- (void)setUnit:(NSString *)theUnit
{
    unitLabel_.text = theUnit;
}

- (void)setPurity:(NSString *)thePurity
{
    purityLabel_.text = thePurity;
}

- (void)setMetal:(NSString *)theMetal
{
    metalLabel_.text = theMetal;
}

- (void)setPrice:(NSString *)thePrice
{
    priceLabel_.text = thePrice;
}

- (void)setupWithPurchaseItem:(PurchaseItem *)thePurchaseItem
{
    [self setWeight:[NSString stringWithWeight:thePurchaseItem.weight]];
    [self setUnit:thePurchaseItem.unit.shortName.uppercaseString];
    [self setPurity:thePurchaseItem.purityName];
    [self setMetal:thePurchaseItem.metal.name.uppercaseString];
    [self setPrice:[NSString stringWithPrice:thePurchaseItem.price]];
}

- (void)setConfigureWithButton:(BOOL)yesOrNo
{
    _configureWithButton = yesOrNo;
    button_.hidden = !self.configureWithButton;
    [self setupFrames];
}

- (void)setupFrames
{
    if (self.configureWithButton) {
        weightLabel_.frame = PURITEM_WEIGHT_FRAME_;
        unitLabel_.frame = PURITEM_UNIT_FRAME_;
        purityLabel_.frame = PURITEM_PURITY_FRAME_;
        metalLabel_.frame = PURITEM_METAL_FRAME_;
        priceLabel_.frame = PURITEM_PRICE_FRAME_;
    }
    else {
        weightLabel_.frame = PURITEM_WEIGHT_FRAME;
        unitLabel_.frame = PURITEM_UNIT_FRAME;
        purityLabel_.frame = PURITEM_PURITY_FRAME;
        metalLabel_.frame = PURITEM_METAL_FRAME;
        priceLabel_.frame = PURITEM_PRICE_FRAME;
    }
}

- (void)dealloc
{
    [weightLabel_ release];
    [unitLabel_ release];
    [purityLabel_ release];
    [metalLabel_ release];
    [priceLabel_ release];
    [button_ release];
    [separatorImageView_ release];
    [super dealloc];
}

@end
