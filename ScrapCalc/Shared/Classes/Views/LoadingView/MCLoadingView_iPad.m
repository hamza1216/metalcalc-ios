//
//  MCLoadingView_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 06.08.13.
//
//

#import "MCLoadingView_iPad.h"


@interface MCLoadingView_iPad ()
{
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_loadTextLabel;
}

@end


@implementation MCLoadingView_iPad

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self _createLoadTextLabel];
    [self _createActivityIndicator];
    [self hide];
}

#pragma mark - DrawRect Override

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, true);
	CGContextSetLineWidth(context, 4.0);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:LOADING_ALPHA].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:LOADING_ALPHA].CGColor);
    
    CGFloat cx = CGRectGetMidX(rect);
    CGFloat cy = CGRectGetMidY(rect);
    
    CGFloat r = LOADING_RADIUS;
    CGFloat w = LOADING_WIDTH;
    CGFloat h = LOADING_HEIGHT;
    
    CGFloat x = cx - w / 2;
    CGFloat y = cy - h / 2;
    
    CGFloat ex = x + w;
    CGFloat ey = y + h;
    
    CGContextMoveToPoint(context, x, cy);
    CGContextAddArcToPoint(context,  x,  y, cx,  y, r);
    CGContextAddArcToPoint(context, ex,  y, ex, cy, r);
    CGContextAddArcToPoint(context, ex, ey, cx, ey, r);
    CGContextAddArcToPoint(context,  x, ey,  x,  y, r);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Private

- (void)_createActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _activityIndicator.center = self.center;
    [self addSubview:_activityIndicator];
}

- (void)_createLoadTextLabel
{    
    _loadTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _loadTextLabel.font = FONT_MYRIAD_SEMIBOLD(30);
    _loadTextLabel.textColor = [UIColor whiteColor];
    _loadTextLabel.backgroundColor = [UIColor clearColor];
    _loadTextLabel.textAlignment = NSTextAlignmentCenter;
    _loadTextLabel.text = @"Loading data...";
    [self addSubview:_loadTextLabel];
}

#pragma mark - Public

- (void)show
{
    [_activityIndicator startAnimating];
    
    CGRect frame = self.bounds;
    frame.origin.y += LOADING_HEIGHT / 2;
    frame.size.height -= frame.origin.y;
    _loadTextLabel.frame = frame;
    
    [self.superview bringSubviewToFront:self];
    self.superview.userInteractionEnabled = NO;
    self.hidden = NO;
    [self setNeedsDisplay];
}

- (void)hide
{
    [_activityIndicator stopAnimating];
    self.superview.userInteractionEnabled = YES;
    self.hidden = YES;
}

#pragma mark - Memory management

- (void)dealloc
{
    [_activityIndicator release];
    [_loadTextLabel release];
    [super dealloc];
}

@end
