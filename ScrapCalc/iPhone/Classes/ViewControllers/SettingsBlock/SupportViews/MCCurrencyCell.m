//
//  MCCurrencyCell.m
//  ScrapCalc
//
//  Created by word on 22.04.13.
//
//

#import "MCCurrencyCell.h"

@implementation MCCurrencyCell

@synthesize button = btn_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.textLabel.textColor = [UIColor whiteColor];
               
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = [UIImage imageNamed:@"purchase_cell_bg.png"];
        [self setBackgroundView:bgView];
        [bgView release];
        
        btn_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        btn_.frame = CGRectMake(self.frame.size.width-92, 4, 62, self.frame.size.height-8);
        btn_.userInteractionEnabled = NO;
        [self.contentView addSubview:btn_];
        
        UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 2)];
        separator.image = [UIImage imageNamed:@"separator_full.png"];
        [self.contentView addSubview:separator];
        [separator release];
    }
    return self;
}

- (void)makeSelectedCell:(BOOL)sel
{
    if (sel) {
        [btn_ setTitleColor:[UIColor colorWithRed:0.6f green:0.71f blue:0.92f alpha:1] forState:UIControlStateNormal];
        self.textLabel.textColor = [UIColor colorWithRed:0.6f green:0.71f blue:0.92f alpha:1];
    }
    else {
        [btn_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setFullText:(NSString *)text
{
    self.textLabel.text = text;
}

- (void)setShortText:(NSString *)text
{
    [btn_ setTitle:text forState:UIControlStateNormal];
}

- (void)dealloc
{
    [btn_ release];
    [super dealloc];
}

@end
