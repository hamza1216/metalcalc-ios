//
//  MCTripleSlider.m
//  ScrapCalc
//
//  Created by Diana on 28.08.13.
//
//

#import "MCTripleSlider.h"
#import "TVCalibratedSlider.h"

#define TRESHOLD_TAG 223
#define OFF_TAG 892
#define BADGE_TAG 382

@interface MCTripleSlider () <TVCalibratedSliderDelegate>

@property (nonatomic, retain)  TVCalibratedSlider *programmaticallyCreatedSlider;
@property (nonatomic, retain) IBOutlet  TVCalibratedSlider *scaledSlider;
@property (nonatomic, retain) IBOutlet UIView *container;

@end

@implementation MCTripleSlider
@synthesize scaledSlider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor clearColor]];
    self.container.backgroundColor = [UIColor clearColor];
    
    TVCalibratedSliderRange range;
    range.maximumValue = 2;
    range.minimumValue = 0;
    
    [scaledSlider setRange:range];
    [scaledSlider setValue:1];
    [scaledSlider setTextColorForHighlightedState:[UIColor blackColor]];
    [scaledSlider setStyle:TavicsaStyle];
    [scaledSlider setMaximumTrackImage:nil withCapInsets:UIEdgeInsetsZero forState:nil];
    [scaledSlider setMinimumTrackImage:nil withCapInsets:UIEdgeInsetsZero forState:nil];
    [scaledSlider setThumbImage:@"switcher_norm" forState:UIControlStateNormal];
    [scaledSlider setThumbImage:@"switcher_sel" forState:UIControlStateHighlighted];
    scaledSlider.tvSliderValueChangedBlock = ^(id sender){
        NSLog(@"The value is %d",[(TVCalibratedSlider *)sender value]);
        [self willSwitchToType:[(TVCalibratedSlider *)sender value]];
    };
    [scaledSlider setDelegate:self];
    
    UITapGestureRecognizer *tapOnSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [tapOnSlider setNumberOfTapsRequired:1];
    [self.scaledSlider addGestureRecognizer:tapOnSlider];
}


- (void)willSwitchToType:(PushOptionType)type
{
    UIImage *onlamp = [UIImage imageNamed:@"lamp_on"];
    UIImage *offlamp = [UIImage imageNamed:@"lamp_off"];
    switch (type) {
        case PushOptionTypeBadge:
        {
            [(UIImageView *)[self viewWithTag:BADGE_TAG] setImage:onlamp];
            [(UIImageView *)[self viewWithTag:TRESHOLD_TAG] setImage:offlamp];
            [(UIImageView *)[self viewWithTag:OFF_TAG] setImage:offlamp];
        }
            break;
        case PushOptionTypeOff:
        {
            [(UIImageView *)[self viewWithTag:BADGE_TAG] setImage:offlamp];
            [(UIImageView *)[self viewWithTag:OFF_TAG] setImage:onlamp];
            [(UIImageView *)[self viewWithTag:TRESHOLD_TAG] setImage:offlamp];
        }
            break;
        case PushOptionTypeThreshold:
        {
            [(UIImageView *)[self viewWithTag:BADGE_TAG] setImage:offlamp];
            [(UIImageView *)[self viewWithTag:OFF_TAG] setImage:offlamp];
            [(UIImageView *)[self viewWithTag:TRESHOLD_TAG] setImage:onlamp];
        }
            break;
            
        default:
            break;
    }
}

- (void)didSwitchToType:(PushOptionType)type
{
    NSLog(@"Slider %@ was changed to %d", self, type);
    _currentType = type;
    [self willSwitchToType:type];
    [[self delegate] tripleSlider:self didChangeValue:type];
}

- (void)setCurrentType:(PushOptionType)currentType
{
    _currentType = currentType;
    [self willSwitchToType:currentType];
    [[self scaledSlider] setValue:currentType];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        TVCalibratedSlider *sl = (TVCalibratedSlider *)[sender view];
        int lenght = abs(sl.range.minimumValue - sl.range.maximumValue);
        float widhtOfSection = sl.frame.size.width/lenght;
        float index = [sender locationOfTouch:[sender numberOfTouches]-1 inView:sl].x/widhtOfSection;
        int roundInd = roundf(index);
        [sl setValue:sl.range.minimumValue + roundInd];
        [self valueChanged:sl];
    }
    
}

- (void)valueChanged:(TVCalibratedSlider *)sender
{
    [self didSwitchToType:sender.value];
}

@end
