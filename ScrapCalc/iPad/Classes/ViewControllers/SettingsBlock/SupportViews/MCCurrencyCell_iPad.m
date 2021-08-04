//
//  MCCurrencyCell_iPad.m
//  ScrapCalc
//
//  Created by Diana on 14.08.13.
//
//

#import "MCCurrencyCell_iPad.h"

@implementation MCCurrencyCell_iPad

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[self.button titleLabel] setFont:FONT_MYRIAD_SEMIBOLD(self.button.titleLabel.font.pointSize)];
    //[self.textLabel setBackgroundColor:[UIColor clearColor]];
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_element_back_norm"]];
    self.backgroundView = bg;
    [bg release];
    
    UIImageView *selBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_element_back_sel"]];
    self.selectedBackgroundView = selBG;
    [selBG release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)makeSelectedCell:(BOOL)sel
{
    if (sel) {
        [self.button setTitleColor:[UIColor colorWithRed:0.6f green:0.71f blue:0.92f alpha:1] forState:UIControlStateNormal];
        self.titleLabel.textColor = [UIColor colorWithRed:0.6f green:0.71f blue:0.92f alpha:1];
    }
    else {
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setFullText:(NSString *)text
{
    self.titleLabel.text = text;
}

- (void)setShortText:(NSString *)text
{
    [self.button setTitle:text forState:UIControlStateNormal];
}

- (void)dealloc
{
    [super dealloc];
}

@end
