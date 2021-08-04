//
//  ModalActivityIndicator.m
//  ScarpCalc
//
//  Created by Oleksii Starov on 17.10.10.
//  Copyright 2010 home. All rights reserved.
//

#import "ModalActivityIndicator.h"


@implementation ModalActivityIndicator



- (id)init {
	if (self = [super initWithFrame:CGRectZero]) {
		[self setContentMode:UIViewContentModeScaleToFill];
		
		[self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
		loadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		
		[loadIndicator startAnimating];
		[self addSubview:loadIndicator];
		
//		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
			loadText = [[UILabel alloc] initWithFrame:CGRectZero];
			loadText.font = [UIFont fontWithName:@"Arial" size:18];
			loadText.textColor = [UIColor whiteColor];
			loadText.backgroundColor = [UIColor clearColor];
			loadText.textAlignment = NSTextAlignmentCenter;
			loadText.text = @"Loading data...";
			[self addSubview:loadText];
//		}

		[self setNeedsDisplay];
        [self stop];
        
        cnt_ = 0;
    }
	
    return self;
}

- (void)layoutSubviews {
	[self setFrame:[[self superview] bounds]];
	[loadIndicator setCenter:[self center]];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGFloat generalWidth = [[self superview] frame].size.width;
	CGFloat generalHeight = [[self superview] frame].size.height;
	
//	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		[loadText setFrame:CGRectMake(generalWidth / 4, (CGFloat)9 / 16 * generalHeight, generalWidth / 2, 20)];
//	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rrect = CGRectMake(generalWidth / 4, generalHeight / 3, generalWidth / 2, generalHeight / 3);
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetLineWidth(context, 2.0);

	CGColorRef c = [[UIColor blackColor] CGColor];
	CGContextSetFillColorWithColor(context, c);
	
	CGColorRef bc = [[UIColor whiteColor] CGColor];
	CGContextSetStrokeColorWithColor(context, bc);
	
	CGFloat radius = 10;
	
	CGFloat minx = CGRectGetMinX(rrect);
	CGFloat midx = CGRectGetMidX(rrect);
	CGFloat maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect);
	CGFloat midy = CGRectGetMidY(rrect);
	CGFloat maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)dealloc {
	
	[loadIndicator release];
//	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		[loadText release];
//	}
	
    [super dealloc];
}

- (void)start
{
//    if (cnt_ == 0) {
        [self setHidden:NO];
        [self.superview bringSubviewToFront:self];
//        [[[UIApplication sharedApplication] keyWindow] setUserInteractionEnabled:NO];        
//    }
//    cnt_++;
}

- (void)stop
{
//    cnt_--;
//    if (cnt_ <= 0) {
//        cnt_ = 0;
        [self setHidden:YES];
//        [[[UIApplication sharedApplication] keyWindow] setUserInteractionEnabled:YES];
//    }
}

@end
