//
//  MCChartsView.m
//  ScrapCalc
//
//  Created by word on 24.04.13.
//
//

#import "MCChartsView.h"

#define CHART_PERIOD_BUTTON_TAG     10027500


@interface MCChartsView ()

@property (nonatomic, copy) NSString *selectedMetal;
@property (nonatomic, assign) ChartsPeriod selectedPeriod;

@end


@implementation MCChartsView

@synthesize selectedMetal;
@synthesize selectedPeriod;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    UIImageView *bgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calc_pulldown.png"]];
    bgv.frame = self.bounds;
    bgv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:bgv atIndex:0];
    [bgv release];
    
    CGFloat x = 25, y = 80;
    chartImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, self.frame.size.width-2*x, self.frame.size.height-2*y-32)];
//    chartImageView_.image = ImageFromURL(@"gold", ChartsPeriod1year);
    [self addSubview:chartImageView_];
    
    CGFloat by = chartImageView_.frame.size.height + chartImageView_.frame.origin.y + 20;
    CGFloat h = 30;
    
    x -= 7;
    for (NSInteger i = 0; i < ChartsPeriodCount; ++i) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat w = WidthForButtonIndex(i);
        btn.frame = CGRectMake(x, by, w, h);
        x += w;
        
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [btn setTitle:ChartsTitleFromPeriod(i) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.tag = CHART_PERIOD_BUTTON_TAG + i;
        [btn addTarget:self action:@selector(periodChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }
    
    UIButton *firstBtn = (UIButton *)[self viewWithTag:CHART_PERIOD_BUTTON_TAG];
    [firstBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self periodChanged:firstBtn];
    
    CGFloat tw = 80, th = 50;
    touchZone_ = CGRectMake((self.frame.size.width - tw) / 2, self.frame.size.height - th, tw, th);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat w = 80, h = 50;
    touchZone_ = CGRectMake((self.frame.size.width - w) / 2, self.frame.size.height - h, w, h);
}

- (void)arrangeButtons:(BOOL)forBase
{
    UIButton *lastButton = (UIButton *)[self viewWithTag:CHART_PERIOD_BUTTON_TAG+ChartsPeriod10years];
    lastButton.hidden = forBase;
    
    CGFloat x = 18;
    CGFloat by = chartImageView_.frame.size.height + chartImageView_.frame.origin.y + 20;
    CGFloat h = 30;

    for (NSInteger i = 0; i < ChartsPeriodCount; ++i) {
        UIButton *btn = (UIButton *)[self viewWithTag:CHART_PERIOD_BUTTON_TAG+i];
        
        CGFloat w = WidthForButtonIndex(i) + (forBase ? 7.2 : 0);
        btn.frame = CGRectMake(x, by, w, h);
        x += w;
    }
}

- (void)changeMetal:(Metal *)metal
{
    chartImageView_.image = nil;
    
    self.selectedMetal = metal.name;
    [self arrangeButtons:(MetalShortcut(self.selectedMetal).length < 1)];
    
    [self performSelectorInBackground:@selector(downloadImage) withObject:nil];
}

- (void)periodChanged:(UIButton *)sender
{
    if (self.selectedPeriod == sender.tag - CHART_PERIOD_BUTTON_TAG) {
        return;
    }
    
    [(UIButton *)[self viewWithTag:self.selectedPeriod + CHART_PERIOD_BUTTON_TAG] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    self.selectedPeriod = sender.tag - CHART_PERIOD_BUTTON_TAG;
    chartImageView_.image = nil;
    [self performSelectorInBackground:@selector(downloadImage) withObject:nil];
}

- (void)downloadImage
{
    chartImageView_.image = nil;
    if (MetalShortcut(self.selectedMetal).length > 0) {
        chartImageView_.image = ImageFromURL(self.selectedMetal, self.selectedPeriod);
    }
    else {
        chartImageView_.image = ImageForBaseMetal(self.selectedMetal.lowercaseString, self.selectedPeriod);
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    properTouch_ = (touchZone_.origin.x <= location.x && location.x <= touchZone_.origin.x + touchZone_.size.width &&
                    touchZone_.origin.y <= location.y && location.y <= touchZone_.origin.y + touchZone_.size.height);
    startTouchPoint_ = location;
    simpleTap_ = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat y = [[touches anyObject] locationInView:self].y;
    if (properTouch_ && ABS(y - startTouchPoint_.y) >= 5) {
        if (y > startTouchPoint_.y) {
            if ([delegate respondsToSelector:@selector(chartsShouldMoveDown)]) {
                [delegate chartsShouldMoveDown];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(chartsShouldMoveUp)]) {
                [delegate chartsShouldMoveUp];
            }
        }
        properTouch_ = NO;
    }
    simpleTap_ = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (simpleTap_) {
        if ([delegate respondsToSelector:@selector(chartsSimpleTap)]) {
            [delegate chartsSimpleTap];
        }
    }
}

- (void)dealloc
{
    [chartImageView_ release];
    [super dealloc];
}

@end
