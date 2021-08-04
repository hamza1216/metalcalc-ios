//
//  MCClientCell_iPad.m
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import "MCClientCell_iPad.h"

@implementation MCClientCell_iPad

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        bgView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        [self setBackgroundView:bgView_];
        [bgView_ release];
        
        bgSelectedView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        [self setSelectedBackgroundView:bgSelectedView_];
        [bgSelectedView_ release];
        
        iconView_ = [[UIImageView alloc] initWithFrame:CLIENT_ICON_FRAME];
        iconView_.image = [UIImage imageNamed:@"nophoto_little"];
        [self.contentView addSubview:iconView_];
        nameLabel_ = [[UILabel alloc] initWithFrame:CLIENT_NAME_FRAME];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = [UIColor whiteColor];
        nameLabel_.font = [UIFont boldSystemFontOfSize:17];
        nameLabel_.minimumScaleFactor = 12;
        nameLabel_.adjustsFontSizeToFitWidth = YES;
        nameLabel_.numberOfLines = 2;
        [self.contentView addSubview:nameLabel_];
        
        arrowImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_arrow_norm"]];
        self.accessoryView = arrowImageView_;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        arrowImageView_.image = [UIImage imageNamed:@"list_arrow_sel"];
    }
    else
    {
        arrowImageView_.image = [UIImage imageNamed:@"list_arrow_norm"];
    }
    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setIcon:(UIImage *)icon
{
    iconView_.image = icon;
}

- (void)setName:(NSString *)name
{
    nameLabel_.text = name;
}

-(void)updateClientCell:(BOOL)isPortrait
{
    bgView_.frame = [self bounds];
    bgSelectedView_.frame = [self bounds];
    iconView_.image = [UIImage imageNamed:@"nophoto_little"];
    if(isPortrait)
    {
        bgView_.image = [UIImage imageNamed:@"content_element_back_norm"];
        bgSelectedView_.image = [UIImage imageNamed:@"content_element_back_sel"];
        CGRect nameFrame = nameLabel_.frame;
        nameFrame.size.width = CLIENT_NAME_WIDTH_FULL;
        nameLabel_.frame = nameFrame;
    }
    else
    {
        bgView_.image = [UIImage imageNamed:@"content_element_back_norm_short"];
        bgSelectedView_.image = [UIImage imageNamed:@"content_element_back_sel_short"];
        CGRect nameFrame = nameLabel_.frame;
        nameFrame.size.width = CLIENT_NAME_WIDTH_SHORT;
        nameLabel_.frame = nameFrame;
    }
}

- (void)dealloc
{
    [iconView_ release];
    [nameLabel_ release];
    [arrowImageView_ release];
    [super dealloc];
}



@end
