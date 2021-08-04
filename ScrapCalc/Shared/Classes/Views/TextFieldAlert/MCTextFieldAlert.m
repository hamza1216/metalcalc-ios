//
//  MCTextFieldAlert.m
//  ScrapCalc
//
//  Created by Diana on 14.10.13.
//
//

#import "MCTextFieldAlert.h"
#import <QuartzCore/QuartzCore.h>

@interface MCTextFieldAlert ()
{
    UIView *layout_;
}

@property (nonatomic, strong) IBOutlet UIButton *okButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UILabel *minLabel;
@property (nonatomic, strong) IBOutlet UILabel *maxLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

@implementation MCTextFieldAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _customInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _customInitialization];
    }
    return self;
}

- (void)_customInitialization
{
    self.layer.cornerRadius = 10;
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_portrait"]];
    [bg setFrame:self.bounds];
    [bg setContentMode:UIViewContentModeCenter];
    [self insertSubview:bg atIndex:0];
    UIView *transpLayer = [[UIView alloc] initWithFrame:self.bounds];
    [transpLayer setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    [self insertSubview:transpLayer aboveSubview:bg];
    
    [[[self okButton] titleLabel] setFont:FONT_MYRIAD_BOLD(16)];
    [[[self cancelButton] titleLabel] setFont:FONT_MYRIAD_BOLD(16)];
    [[self titleLabel] setFont:FONT_MYRIAD_BOLD(16)];
    [[self minLabel] setFont:FONT_MYRIAD_REGULAR(14)];
    [[self maxLabel] setFont:FONT_MYRIAD_REGULAR(14)];
}

#pragma mark - public 

- (void)showOnView:(UIView *)view
{
    CGRect frame = self.frame;
    frame.origin.x = view.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = view.frame.size.height/2 - frame.size.height/2 - (IS_IPAD ? 140 : 80);
    self.frame = frame;
    [view addSubview:self];
    self.hidden = NO;
    
    layout_ = [[UIView alloc] initWithFrame:view.bounds];
    layout_.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [view insertSubview:layout_ belowSubview:self];
    [layout_ release];
}

#pragma mark - actions

- (IBAction)okAction:(id)sender
{
    [self setHidden:YES];
    [layout_ removeFromSuperview];
    if([[self delegate] respondsToSelector:@selector(alertViewdidClickOkButton:)])
        [[self delegate] alertViewdidClickOkButton:self];
    [self removeFromSuperview];
}

- (IBAction)cancelAction:(id)sender
{
    [self setHidden:YES];
    [layout_ removeFromSuperview];
    if([[self delegate] respondsToSelector:@selector(alertViewdidClickCancelButton:)])
        [[self delegate] alertViewdidClickCancelButton:self];
    [self removeFromSuperview];
}


@end
