//
//  MCChartsView_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 07.08.13.
//
//

#import "MCChartsView_iPad.h"


@interface MCChartsView_iPad ()

@property (nonatomic, assign) Metal *currentMetal;
@property (nonatomic, assign) ChartsPeriod currentPeriod;
@property (nonatomic, strong) NSMutableArray *menuButtons;

@end


@implementation MCChartsView_iPad


#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.menuButtons = [NSMutableArray array];
    [self _createMenu];
}


#pragma mark - Private

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    NSLog(@"Charts: %@", NSStringFromCGRect(frame));
    
    [self _resizeSubviews];
    [self _updateMenu];
}

- (void)_resizeSubviews
{
    CGFloat bottomHeight = self.frame.size.height / 5.5;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    self.backgroundChartView.frame = CGRectMake(0, 0, w, bottomHeight * 4.8);
    self.backgroundMenuView.frame = CGRectMake(0, h - bottomHeight, w, bottomHeight);
    self.menuView.frame = self.backgroundMenuView.frame;
    
    CGFloat xInset = 74, yInset = 8;
    CGFloat cw = w - 2 * xInset;
    CGFloat ch =self.backgroundChartView.frame.size.height - 2 * yInset;
    
    self.chartView.frame = CGRectMake(0, 0, cw, ch);
    self.chartView.center = self.backgroundChartView.center;
}

- (void)_createMenu
{    
    for (NSInteger i = 0; i < ChartsPeriodCount; ++i) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.tag = 27;
        lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        lbl.userInteractionEnabled = NO;
        
        lbl.backgroundColor = [UIColor clearColor];
        lbl.shadowOffset = CGSizeMake(0, 1);
        lbl.shadowColor = [UIColor blackColor];
        
        lbl.font = FONT_MYRIAD_BOLD(36);
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = ChartsTitleFromPeriod(i);
        
        [btn addSubview:lbl];
        [lbl release];
        
        btn.tag = i;
        [btn addTarget:self action:@selector(periodChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.menuButtons addObject:btn];
        [self.menuView addSubview:btn];
    }
    [self _updateMenu];
    [self _setButton:self.menuButtons[0] selected:YES];
}

- (void)_setButton:(UIButton *)sender selected:(BOOL)selected
{
    NSInteger color = selected ? 0xde8b14 : 0xFFFFFF;
    [(UILabel *)[sender viewWithTag:27] setTextColor:ColorFromHexFormat(color)];
}

- (void)_updateMenu
{
    NSMutableArray *buttons = [NSMutableArray array];
    NSInteger totalWidth = 0;
    
    for (UIButton *btn in self.menuButtons) {
        if (!btn.hidden) {
            [buttons addObject:btn];
            totalWidth += 2 * WidthForButtonIndex(btn.tag);
        }
    }
    
    CGFloat deltaX = (self.menuView.frame.size.width - totalWidth) / buttons.count;
    CGFloat x = deltaX / 2, y = 0, h = self.menuView.frame.size.height + 10, w;
    
    for (UIButton *btn in buttons) {
        btn.frame = CGRectMake(x, y, (w=2*WidthForButtonIndex(btn.tag)), h);
        x += w + deltaX;
    }
}

- (void)_downloadImage
{
    self.chartView.image = nil;
    if (MetalShortcut(self.currentMetal.name).length > 0) {
        self.chartView.image = ImageFromURL(self.currentMetal.name, self.currentPeriod);
    }
    else {
        self.chartView.image = ImageForBaseMetal(self.currentMetal.name.lowercaseString, self.currentPeriod);
    }
}


- (void)periodChanged:(UIButton *)sender
{
    if (self.currentPeriod == sender.tag) {
        return;
    }
    
    [self _setButton:self.menuButtons[self.currentPeriod] selected:NO];
    [self _setButton:sender selected:YES];
    
    self.currentPeriod = sender.tag;
    
    self.chartView.image = nil;
    [self performSelectorInBackground:@selector(_downloadImage) withObject:nil];
}



#pragma mark - Public

- (void)updateForMetal:(Metal *)metal
{
    BOOL wasBase = self.currentMetal.isBaseMetal;
    BOOL isBase = metal.isBaseMetal;
    
    self.currentMetal = metal;
    [self performSelectorInBackground:@selector(_downloadImage) withObject:nil];
    
    if (wasBase != isBase) {
        [self.menuButtons[ChartsPeriod10years] setHidden:isBase];
        [self _updateMenu];
    }
}


#pragma mark - Memory

- (void)dealloc
{
    [self.menuButtons removeAllObjects];
    self.menuButtons = nil;
    [super dealloc];
}


@end
