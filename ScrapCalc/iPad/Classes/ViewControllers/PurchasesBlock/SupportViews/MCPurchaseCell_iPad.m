//
//  PurchaseCell_iPad.m
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCPurchaseCell_iPad.h"

@implementation MCPurchaseCell_iPad

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        bgView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        [self setBackgroundView:bgView_];
        
        bgSelectedView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        [self setSelectedBackgroundView:bgSelectedView_];
        
        numberLabel_ = [[UILabel alloc] initWithFrame:PURCHASE_NUMBER_FRAME_LANDSCAPE];
        numberLabel_.backgroundColor = [UIColor clearColor];
        numberLabel_.textColor = [UIColor whiteColor];
        numberLabel_.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:numberLabel_];
        
        clientLabel_ = [[UILabel alloc] initWithFrame:PURCHASE_CLIENT_FRAME_LANDSCAPE];
        clientLabel_.backgroundColor = [UIColor clearColor];
        clientLabel_.textColor = [UIColor whiteColor];
        clientLabel_.font = [UIFont systemFontOfSize:17];
        clientLabel_.adjustsFontSizeToFitWidth = YES;
        clientLabel_.minimumScaleFactor = 12;
        [self.contentView addSubview:clientLabel_];
        
        arrowImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purchases_list_arrow_norm"]];
        self.accessoryView = arrowImageView_;
        [arrowImageView_ release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        arrowImageView_.image = [UIImage imageNamed:@"purchases_list_arrow_norm"];
    }
    else
    {
        arrowImageView_.image = [UIImage imageNamed:@"purchases_list_arrow_sel"];
    }

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setNumber:(NSString *)theNumber
{
    numberLabel_.text = theNumber;
}

- (void)setClient:(NSString *)theClientName
{
    clientLabel_.text = theClientName;
}

-(void)updatePurchaseCell:(BOOL)isPortrait
{
    bgView_.frame = [self bounds];
    bgSelectedView_.frame = [self bounds];
    if(isPortrait)
    {
        bgView_.image = [UIImage imageNamed:@"purchases_content_element_back_norm"];
        bgSelectedView_.image = [UIImage imageNamed:@"purchases_content_element_back_sel"];
        numberLabel_.frame = PURCHASE_NUMBER_FRAME_PORTRAIT;
    }
    else
    {
        bgView_.image = [UIImage imageNamed:@"purchases_content_element_back_norm_short"];
        bgSelectedView_.image = [UIImage imageNamed:@"purchases_content_element_back_sel_short"];
        numberLabel_.frame = PURCHASE_NUMBER_FRAME_LANDSCAPE;
    }
    if(clientLabel_.text.length < 1)
    {
        clientLabel_.hidden = YES;
        numberLabel_.frame = PURCHASE_SINGLE_FRAME;
    }
}

-(void)dealloc
{
    [bgView_ release];
    [bgSelectedView_ release];
    [numberLabel_ release];
    [clientLabel_ release];
    [super dealloc];
}

@end
