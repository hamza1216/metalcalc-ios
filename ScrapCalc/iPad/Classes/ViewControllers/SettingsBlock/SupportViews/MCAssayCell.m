//
//  MCAssayCell.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCAssayCell.h"

@implementation MCAssayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    self.textField.frame = CGRectMake(0, 0, self.textField.frame.size.width, 60);
    self.textField.center = self.center;
}

@end
