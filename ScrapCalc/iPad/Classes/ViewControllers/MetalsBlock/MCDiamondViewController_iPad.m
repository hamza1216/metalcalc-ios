//
//  MCDiamondViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 05.08.13.
//
//

#import "MCDiamondViewController_iPad.h"
#import "MCBaseViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>


@interface MCDiamondViewController_iPad ()
{
    UIImageView *_bgImageView;
}

@end


@implementation MCDiamondViewController_iPad

#pragma mark - IBActions

- (IBAction)rotateAction:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.containerView.transform = CGAffineTransformRotate(self.containerView.transform, M_PI);
    }];
}

- (IBAction)backAction:(id)sender
{
    [self.delegate didReceiveBackAction];
}

#pragma mark - Copy BaseDetailVC behavior

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.containerView.backgroundColor = [UIColor clearColor];
    
    _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calculator_background.png"]];
    _bgImageView.autoresizingMask = 0;
    
    [self.view insertSubview:_bgImageView belowSubview:self.containerView];
    [self _setupBackgroundForOrientation:self.interfaceOrientation];
}

 - (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)_setupBackgroundForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        _bgImageView.frame = DETAIL_VC_FRAME_PORTRAIT;
        self.contentView.frame = DIAMOND_CONTENT_FRAME_PORTRAIT;
        self.backButton.hidden = self.rotateButton.hidden = NO;
    }
    else {
        _bgImageView.frame = DETAIL_VC_FRAME_LANDSCAPE;
        self.contentView.frame = DIAMOND_CONTENT_FRAME_LANDSCAPE;
        self.backButton.hidden = self.rotateButton.hidden = YES;
    }
    [self _setupContainerView];
    self.scroll.frame = CGRectMake(0, self.scroll.frame.origin.y, self.contentView.frame.size.width, self.scroll.frame.size.height);
}

- (void)_setupContainerView
{
    CGFloat d = 7;
    CGRect frame = _bgImageView.frame;
    frame.origin.x += d;
    frame.origin.y += d;
    frame.size.width -= 2*d;
    frame.size.height -= 2*d;
    
    self.containerView.frame = frame;
    self.containerView.autoresizingMask = 0;
}

- (void)setupForPortrait
{
    [self _setupBackgroundForOrientation:UIInterfaceOrientationPortrait];
}

- (void)setupForLandscape
{
    [self _setupBackgroundForOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (void)dealloc
{
    [_bgImageView release];
    [super dealloc];
}

@end
