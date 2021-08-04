//
//  ClientsCell.m
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "ClientsCell.h"

@implementation ClientsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [self setBackgroundView:bgView];
        [bgView release];
        
        iconView_ = [[UIImageView alloc] initWithFrame:CLIENT_ICON_FRAME];
        iconView_.image = [UIImage imageNamed:@"client_default_avatar.png"];
        [self.contentView addSubview:iconView_];
        
        nameLabel_ = [[UILabel alloc] initWithFrame:CLIENT_NAME_FRAME];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = [UIColor whiteColor];
        nameLabel_.font = [UIFont boldSystemFontOfSize:17];
        nameLabel_.minimumScaleFactor = 12;
        nameLabel_.adjustsFontSizeToFitWidth = YES;
        nameLabel_.numberOfLines = 2;
        [self.contentView addSubview:nameLabel_];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CLIENT_ARROW_FRAME];
        arrowImageView.image = [UIImage imageNamed:@"purchase_arrow.png"];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView release];
        
        separatorImageView_ = [[UIImageView alloc] initWithFrame:CLIENT_SEPARATOR_FRAME];
        separatorImageView_.image = [UIImage imageNamed:@"separator_full.png"];
        [self.contentView addSubview:separatorImageView_];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    separatorImageView_.frame = CLIENT_SEPARATOR_FRAME;
}

- (void)setIcon:(UIImage *)icon
{
    iconView_.image = icon;
}

- (void)setDefaultIcon
{
    iconView_.image = [UIImage imageNamed:@"client_default_avatar.png"];
}

- (void)setName:(NSString *)name
{
    nameLabel_.text = name;
}

- (void)dealloc
{
    [iconView_ release];
    [nameLabel_ release];
    [separatorImageView_ release];
    [super dealloc];
}

@end
