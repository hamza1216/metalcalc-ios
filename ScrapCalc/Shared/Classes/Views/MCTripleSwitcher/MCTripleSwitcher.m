//
//  MCTripleSwitcher.m
//  ScrapCalc
//
//  Created by Diana on 29.08.13.
//
//

#import "MCTripleSwitcher.h"
#import <QuartzCore/QuartzCore.h>

#define lampHeight 12
#define lampWidht 12
#define deltaX 200

#define FIRST_BUTTON_FRAME(frame) CGRectMake(25,frame.origin.y,frame.size.width,frame.size.height)
#define SECOND_BUTTON_FRAME(frame) CGRectMake(105,frame.origin.y,frame.size.width,frame.size.height)
#define THIRD_BUTTON_FRAME(frame) CGRectMake(185,frame.origin.y,frame.size.width,frame.size.height)

#define FIRST_BUTTON_FRAME_IN_SHORT_MODE(frame) CGRectMake(5,frame.origin.y,frame.size.width,frame.size.height)

@interface MCTripleSwitcher ()
{
}
@property (nonatomic, retain) IBOutlet UIView *tresholdView;
@property (nonatomic, retain) IBOutlet UIView *offView;
@property (nonatomic, retain) IBOutlet UIView *badgeView;
@property (nonatomic, retain) IBOutlet UIButton *badgeButton;
@property (nonatomic, retain) IBOutlet UIButton *offButton;
@property (nonatomic, retain) IBOutlet UIButton *tresholdButton;
@property (nonatomic, retain) IBOutlet UIImageView *badgeLamp;
@property (nonatomic, retain) IBOutlet UIImageView *tresholdLamp;
@property (nonatomic, retain) IBOutlet UIImageView *offLamp;

@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *tapG;
           
- (IBAction)tapOnView:(id)sender;
- (IBAction)badgeWasChosed:(id)sender;
- (IBAction)offWasChosed:(id)sender;
- (IBAction)tresholdWasChosed:(id)sender;

@end

@implementation MCTripleSwitcher

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self customInit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)customInit
{
    [self setBackgroundColor:[UIColor clearColor]];
    UIImage *bg = [[UIImage imageNamed:@"back_long"] stretchableImageWithLeftCapWidth:30 topCapHeight:0];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [bgView setImage:bg];
    [self insertSubview:bgView atIndex:0];
    self.badgeView.layer.cornerRadius = 2.0;
    self.tresholdView.layer.cornerRadius = 2.0;
    self.offView.layer.cornerRadius = 2.0;
    
}

- (void)tapOnView:(id)sender
{
    [self show];
}

- (void)badgeWasChosed:(id)sender
{
    if(self.isFullSize)
    {
        [self setCurrentType:PushOptionTypeBadge animated:YES];
        [[self delegate] tripleSwitcher:self didChangeValue:PushOptionTypeBadge];
        [self hide];
    }
    else
    {
        [self show];
    }
}

- (void)offWasChosed:(id)sender
{
    if(self.isFullSize)
    {
        [self setCurrentType:PushOptionTypeOff animated:YES];
        [[self delegate] tripleSwitcher:self didChangeValue:PushOptionTypeOff];
        [self hide];
    }
    else
    {
        [self show];
    }
}

- (void)tresholdWasChosed:(id)sender
{
    if(self.isFullSize)
    {
        [self setCurrentType:PushOptionTypeThreshold animated:YES];
        [[self delegate] tripleSwitcher:self didChangeValue:PushOptionTypeThreshold];
        [self hide];
    }
    else        
    {
        [self show];
    }
    
}

- (void)setCurrentType:(PushOptionType)currentType animated:(BOOL)animated
{
    _currentType = currentType;
    [self setUpButtonsView];
    [self setUpButtonsFramesAnimated:animated];
}

- (void)setUpButtonsFramesAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated?1.0:0 animations:^{
    switch (self.currentType) {
        case PushOptionTypeBadge:
        {
            [[self badgeView] setFrame:FIRST_BUTTON_FRAME_IN_SHORT_MODE(self.badgeView.frame)];
            [[self tresholdView] setFrame:THIRD_BUTTON_FRAME(self.tresholdView.frame)];
            [[self offView] setFrame:SECOND_BUTTON_FRAME(self.offView.frame)];
        }
            break;
        case PushOptionTypeOff:
        {
            [[self offView] setFrame:FIRST_BUTTON_FRAME_IN_SHORT_MODE(self.offView.frame)];
            [[self tresholdView] setFrame:SECOND_BUTTON_FRAME(self.tresholdView.frame)];
            [[self badgeView] setFrame:THIRD_BUTTON_FRAME(self.badgeView.frame)];
        }
            break;
        case PushOptionTypeThreshold:
        {
            [[self tresholdView] setFrame:FIRST_BUTTON_FRAME_IN_SHORT_MODE(self.tresholdView.frame)];
            [[self offView] setFrame:SECOND_BUTTON_FRAME(self.offView.frame)];
            [[self badgeView] setFrame:THIRD_BUTTON_FRAME(self.badgeView.frame)];
        }
            break;
        default:
            break;
    }
    } completion:^(BOOL finished) {
    }];
}

- (void)setDefaultFrames
{
    [[self tresholdView] setFrame:FIRST_BUTTON_FRAME(self.tresholdView.frame)];
    [[self offView] setFrame:SECOND_BUTTON_FRAME(self.offView.frame)];
    [[self badgeView] setFrame:THIRD_BUTTON_FRAME(self.badgeView.frame)];
}

- (void)setUpButtonsView
{
    switch (self.currentType) {
        case PushOptionTypeBadge:
        {
            [self setBadgeButtonSelected];
        }
            break;
        case PushOptionTypeOff:
        {
            [self setOffButonSelected];
        }
            break;
        case PushOptionTypeThreshold:
        {
            [self setTresholdButtonSelected];
        }
            break;
            
        default:
            break;
    }
}

- (void)setBadgeButtonSelected
{
    [self.badgeLamp setImage:[self onlampImage]];
    [self.offLamp setImage:[self offLampImage]];
    [self.tresholdLamp setImage:[self offLampImage]];
    [self.badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.offButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.tresholdButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)setOffButonSelected
{
    [self.badgeLamp setImage:[self offLampImage]];
    [self.offLamp setImage:[self onlampImage]];
    [self.tresholdLamp setImage:[self offLampImage]];
    [self.badgeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.offButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.tresholdButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)setTresholdButtonSelected
{
    [self.badgeLamp setImage:[self offLampImage]];
    [self.offLamp setImage:[self offLampImage]];
    [self.tresholdLamp setImage:[self onlampImage]];
    [self.badgeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.offButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.tresholdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setBgForSelectedButtonSelected:(BOOL)selected
{
    UIColor *color = selected?[UIColor colorWithWhite:0.0 alpha:0.65]:[UIColor clearColor];
    switch (self.currentType) {
        case PushOptionTypeBadge:
        {
            [[self badgeView] setBackgroundColor:color];
        }
            break;
        case PushOptionTypeOff:
        {
            [[self offView] setBackgroundColor:color];
        }
            break;
        case PushOptionTypeThreshold:
        {
            [[self tresholdView] setBackgroundColor:color];
        }
            break;
        default:
            break;
    }
}

- (UIImage *)onlampImage
{
    return [UIImage imageNamed:@"lamp_on"];
}

- (UIImage *)offLampImage
{
    return [UIImage imageNamed:@"lamp_off"];
}

#pragma mark - public

- (void)show
{
    if(self.isFullSize)
        return;
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.frame;
        frame.origin.x -= deltaX;
        self.frame = frame;
        [self setDefaultFrames];
        [self setBgForSelectedButtonSelected:YES];
    } completion:^(BOOL finished) {
        self.isFullSize = YES;
        self.tapG.enabled = NO;
    }];   

}

- (void)hide
{
    if(!self.isFullSize)
        return;
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.frame;
        frame.origin.x += deltaX;
        self.frame = frame;
        [self setBgForSelectedButtonSelected:NO];
    } completion:^(BOOL finished) {        
        self.isFullSize = NO;
        self.tapG.enabled = YES;
    }];

}

@end
