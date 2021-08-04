//
//  MCSettingsCell_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCSettingsCell_iPad.h"

@implementation MCSettingsCell_iPad

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
    self.backgroundImageView.image = [UIImage imageNamed:(selected ? SETTINGS_CELL_BG_IMAGE_SEL : SETTINGS_CELL_BG_IMAGE_NORM)];
}

- (void)setCellType:(MCSettingsCellType)cellType
{
    _cellType = cellType;
    
    switch (cellType)
    {
        case MCSettingsCellTypeDisclosure:
            self.onOff.hidden = !(self.arrowImageView.hidden = NO);
            self.arrowImageView.frame = SETTINGS_CELL_ARROW_FRAME;
            self.arrowImageView.center = CGPointMake(self.frame.size.width - 40, self.backgroundImageView.center.y);
            self.arrowImageView.image = [UIImage imageNamed:SETTINGS_CELL_ARR_IMAGE_NORM];
            break;
            
        case MCSettingsCellTypeCheckbox:
            self.onOff.hidden = !(self.arrowImageView.hidden = NO);
            self.arrowImageView.frame = SETTINGS_CELL_CHECK_FRAME;
            self.arrowImageView.center = CGPointMake(self.frame.size.width - 40, self.backgroundImageView.center.y);
            self.arrowImageView.image = self.isChecked ? [UIImage imageNamed:SETTINGS_CELL_CHECK_IMAGE_SEL] : nil;
            break;
            
        case MCSettingsCellTypeOnOff:
            self.onOff.hidden = !(self.arrowImageView.hidden = YES);
            self.onOff.center = CGPointMake(self.frame.size.width - 40, self.backgroundImageView.center.y);
            break;
            
        case MCSettingsCellTypeNone:
            self.onOff.hidden = self.arrowImageView.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)setIsChecked:(BOOL)isChecked
{
    [self setIsChecked:isChecked animated:YES];
}

- (void)setIsChecked:(BOOL)isChecked animated:(BOOL)animated
{
    _isChecked = isChecked;
    [self.onOff setOn:isChecked animated:animated];
}

- (IBAction)valueChanged:(UISwitch *)sender
{
    [self.delegate cell:self didChangeValue:sender.isOn];
}

@end
