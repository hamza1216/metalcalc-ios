//
//  MCCalculatorTopSlideView.m
//  ScrapCalc
//
//  Created by Domovik on 31.07.13.
//
//

#import "MCCalculatorTopSlideView.h"
#import "NSString+NumbersFormats.h"


@interface MCCalculatorTopSlideView ()
{
    UIImageView *_backgroundView;
    CGRect _touchZone;
    CGPoint _touchBeganPoint;
}

@property (nonatomic, assign) Metal *currentMetal;

@end


@implementation MCCalculatorTopSlideView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    self.backgroundColor = [UIColor clearColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:_backgroundView atIndex:0];
    
    self.chartsView.alpha = 0;
}

- (void)awakeFromNib
{
    self.manualPriceTextField.font = FONT_MYRIAD_BOLD(68);
}

#pragma mark - Override

static const CGSize touchZoneSize = (CGSize) {108, 50};

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _touchZone = CGRectMake((frame.size.width - touchZoneSize.width) / 2 - 15, frame.size.height - touchZoneSize.height, touchZoneSize.width, touchZoneSize.height);
}

#pragma mark - Public

- (void)setIsPortrait:(BOOL)isPortrait
{
    _isPortrait = isPortrait;
    [self _setupAnimated:NO];
}

- (void)setIsFullSize:(BOOL)isFullSize animated:(BOOL)animated
{
    self.isFullSize = isFullSize;
    [self _setupAnimated:animated];
}

- (void)updateForMetal:(Metal *)metal
{
    self.currentMetal = metal;
    
    self.priceLabel.text = [NSString stringWithPrice:metal.bidPrice];
    self.datetimeLabel.text = metal.bidDatetime;
    
    if ([metal.bidPercent isEqualToString:@"0.0000%"] && metal.bidChange == 0.0) {
        self.changeLabel.text = @"0.00% 0.0000%";
        self.changeLabel.textColor = ColorFromHexFormat(CHANGE_GRAY_COLOR);
    }
    else {        
        BOOL plus = ([metal.bidPercent hasPrefix:@"+"]);
        self.changeLabel.text = [NSString stringWithFormat:@"%@%.2lf %@", (plus ? @"+" : @""), metal.bidChange, metal.bidPercent];
        
        NSInteger color = plus ? CHANGE_GREEN_COLOR : CHANGE_RED_COLOR;
        self.changeLabel.textColor = ColorFromHexFormat(color);
    }
    
    [self.chartsView updateForMetal:metal];
}

#pragma mark - Private

- (void)_setupAnimated:(BOOL)animated
{
    NSString *imageName = nil;
    CGRect frame, chartsFrame;
    
    if (self.isFullSize) {
        imageName = TOPSLIDE_BG_NORM_FULL;
        frame = self.isPortrait ? TOP_SLIDE_FRAME_FULL_P : TOP_SLIDE_FRAME_FULL_L;
    }
    else if (self.isPortrait) {
        imageName = TOPSLIDE_BG_NORM_PORTRAIT;
        frame = TOP_SLIDE_FRAME_PORTRAIT;
    }
    else {
        imageName = TOPSLIDE_BG_NORM_LANDSCAPE;
        frame = TOP_SLIDE_FRAME_LANDSCAPE;
    }
    
    chartsFrame = self.isPortrait ? CHARTS_FRAME_PORTRAIT : CHARTS_FRAME_LANDSCAPE;
    self.chartsView.frame = chartsFrame;
//    self.chartsView.alpha = self.isFullSize ? 0 : 1;
    
    
    SEL delegateSelector = self.isFullSize ? @selector(topSlideWillResizeToFullMode) : @selector(topSlideWillResizeToNormalMode);
    if ([self.delegate respondsToSelector:delegateSelector]) {
        [self.delegate performSelector:delegateSelector];
    }
    
    AnimationBlock block = ^{
        _backgroundView.image = [UIImage imageNamed:imageName];
        self.frame = frame;
        self.chartsView.alpha = self.isFullSize ? 1 : 0;
    };
    
    CompletionBlock completionBlock = ^(BOOL f){
    };
    
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:block
                         completion:completionBlock];
    }
    else {
        block();
        completionBlock(YES);
    }
}

#pragma mark - Label Delegate

- (void)labelDidReceiveLongTap:(MCBoldLabel *)label
{
    self.priceLabel.text = [NSString stringWithFormat:@"%.2lf", self.currentMetal.bidPrice];
//    self.manualPriceTextField.text = [NSString stringWithFormat:@"%.2lf", self.currentMetal.bidPrice];
    
    // this "if" appeared with NumPad
    if ([self.delegate respondsToSelector:@selector(showOrHideNumPadForTextField:)]) {
        [self.delegate showOrHideNumPadForTextField:(DotTextField *)self.priceLabel];
        return;
    }
    
    self.priceLabel.hidden = !(self.manualPriceTextField.hidden = NO);
    [self.manualPriceTextField becomeFirstResponder];
}

#pragma mark - TextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // it was before NumPad
//    self.priceLabel.hidden = !(self.manualPriceTextField.hidden = YES);
//    self.currentMetal.bidPrice = self.manualPriceTextField.text.doubleValue * [[[ModelManager shared] selectedCurrency] value];
    
    self.currentMetal.bidPrice = self.priceLabel.text.doubleValue * [[[ModelManager shared] selectedCurrency] value];
    [[ModelManager shared] updateMetalWithNewBids:self.currentMetal];
    
    if ([self.delegate respondsToSelector:@selector(topSlideDidChangeMetalPrice)]) {
        [self.delegate topSlideDidChangeMetalPrice];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.priceLabel.text = [NSString stringWithPrice:self.currentMetal.bidPrice];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    NSString *pattern = @"^[0-9.]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    
    NSString *tmp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (tmp.doubleValue > 999999) {
        return NO;
    }
    
    NSInteger delta = tmp.length - [tmp stringByReplacingOccurrencesOfString:@"." withString:@""].length;
    if (delta > 1) {
        return NO;
    }
    
    static NSInteger maxDecimalLength = 2;
    NSRange dotRange = [tmp rangeOfString:@"."];
    if (dotRange.location != NSNotFound && tmp.length - dotRange.location > maxDecimalLength+1) {
        return NO;
    }
    
    if (string.length > 0 && [string characterAtIndex:0] == '.' && textField.text.length < 1) {
        textField.text = @"0";
    }
    if ([textField.text isEqualToString:@"0"] && ([string doubleValue] != 0 || [string isEqualToString:@"0"])) {
        textField.text = @"";
    }
    
    return YES;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.manualPriceTextField resignFirstResponder];
    
    _touchBeganPoint = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_touchZone, _touchBeganPoint)) {
        _touchBeganPoint = CGPointZero;
    }
}

static const CGFloat yToStartMove = 5;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (CGPointEqualToPoint(_touchBeganPoint, CGPointZero)) {
        return;
    }
    
    CGPoint currentTouch = [[touches anyObject] locationInView:self];
    
    if (currentTouch.y > _touchBeganPoint.y) {
        if (!self.isFullSize && (currentTouch.y - _touchBeganPoint.y) >= yToStartMove) {
            self.isFullSize = YES;
            _touchBeganPoint = CGPointZero;
            [self _setupAnimated:YES];
        }
    }
    else {
        if (self.isFullSize && (_touchBeganPoint.y - currentTouch.y) >= yToStartMove) {
            self.isFullSize = NO;
            _touchBeganPoint = CGPointZero;
            [self _setupAnimated:YES];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchBeganPoint = CGPointZero;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Memory management

- (void)dealloc
{
    [_backgroundView release];
    self.chartsView = nil;
    [super dealloc];
}

@end
