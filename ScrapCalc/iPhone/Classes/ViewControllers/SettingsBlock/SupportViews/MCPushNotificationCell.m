//
//  MCPushNotificationCell.m
//  ScrapCalc
//
//  Created by Diana on 09.08.13.
//
//

#import "MCPushNotificationCell.h"

@interface MCPushNotificationCell ()
{
}

- (IBAction)editRangeAction:(id)sender;

@end

@implementation MCPushNotificationCell
@synthesize rangeLabel = rangeLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.textLabel setTextColor:[UIColor whiteColor]];
    [self setSwitcher:[[NSBundle mainBundle] loadNibNamed:@"MCTripleSwitcher" owner:self options:nil][0]];
    CGRect frame = self.switcher.frame;
    frame.origin.x = self.frame.size.width - self.switcher.frame.size.width + 205;
    frame.size.height = self.frame.size.height;
    self.switcher.frame = frame;
    [[self contentView] addSubview:self.switcher];
    rangeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.rangeButton.frame.size.width,
                                                                    self.rangeButton.frame.size.height)];
    [rangeLabel_ setUserInteractionEnabled:NO];
    [rangeLabel_ setNumberOfLines:2];
    [rangeLabel_ setTextAlignment:NSTextAlignmentCenter];
    [rangeLabel_ setFont:[UIFont boldSystemFontOfSize:13.0]];
    [rangeLabel_ setAdjustsFontSizeToFitWidth:YES];
    [rangeLabel_ setMinimumScaleFactor:10.0];
    [rangeLabel_ setBackgroundColor:[UIColor clearColor]];
    [[self rangeButton] addSubview:rangeLabel_];
    
}

- (void)setUpWithMetal:(Metal *)metal
{
    self.rangeButton.enabled = (metal.pushOption.isOn == PushOptionTypeThreshold);
    self.textLabel.text = metal.name;
    [rangeLabel_ setText:[self titleForRangeButtonWithMetal:metal]];
    [rangeLabel_ setTextColor:(metal.pushOption.isOn == PushOptionTypeThreshold) ? [UIColor whiteColor] : [UIColor lightGrayColor]];
    [[self switcher] setCurrentType:metal.pushOption.isOn animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)editRangeAction:(id)sender
{
    [[self delegate] cellDidTapButton:self];
}

- (NSString *)titleForRangeButtonWithMetal:(Metal *)metal
{
    return [NSString stringWithFormat:@"%.2f -\n%.2f", metal.pushOption.minValue, metal.pushOption.maxValue];
}

@end
