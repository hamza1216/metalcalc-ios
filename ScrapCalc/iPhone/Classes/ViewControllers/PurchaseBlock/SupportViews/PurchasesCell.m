//
//  PurchaseCell.m
//  ScrapCalc
//
//  Created by word on 18.03.13.
//
//

#import "PurchasesCell.h"

@implementation PurchasesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [self setBackgroundView:bgView];
        [bgView release];
        
        numberLabel_ = [[UILabel alloc] initWithFrame:PURCHASE_NUMBER_FRAME];
        numberLabel_.backgroundColor = [UIColor clearColor];
        numberLabel_.textColor = [UIColor whiteColor];
        numberLabel_.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:numberLabel_];
        
        clientLabel_ = [[UILabel alloc] initWithFrame:PURCHASE_CLIENT_FRAME];
        clientLabel_.backgroundColor = [UIColor clearColor];
        clientLabel_.textColor = [UIColor whiteColor];
        clientLabel_.font = [UIFont systemFontOfSize:17];
        clientLabel_.adjustsFontSizeToFitWidth = YES;
        clientLabel_.minimumScaleFactor = 12;
        [self.contentView addSubview:clientLabel_];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:PURCHASE_ARROW_FRAME];
        arrowImageView.image = [UIImage imageNamed:@"purchase_arrow.png"];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView release];
        
        separatorImageView_ = [[UIImageView alloc] initWithFrame:PURCHASE_SEPARATOR_FRAME];
        separatorImageView_.image = [UIImage imageNamed:@"separator_full.png"];
        [self.contentView addSubview:separatorImageView_];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    separatorImageView_.frame = PURCHASE_SEPARATOR_FRAME;
}

- (void)setNumber:(NSString *)theNumber
{
    numberLabel_.text = theNumber;
}

- (void)setClient:(NSString *)theClientName
{
    clientLabel_.text = theClientName;
    if (theClientName.length < 1) {
        clientLabel_.hidden = YES;
        numberLabel_.frame = PURCHASE_SINGLE_FRAME;
    }
    else {
        clientLabel_.hidden = NO;
        clientLabel_.frame = PURCHASE_CLIENT_FRAME;
        numberLabel_.frame = PURCHASE_NUMBER_FRAME;
    }
}

- (void)dealloc
{
    [numberLabel_ release];
    [clientLabel_ release];
    [separatorImageView_ release];
    [super dealloc];
}

@end
