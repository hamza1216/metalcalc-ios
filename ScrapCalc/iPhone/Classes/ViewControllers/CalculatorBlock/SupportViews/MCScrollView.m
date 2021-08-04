//
//  MCScrollView.m
//  ScrapCalc
//
//  Created by word on 21.03.13.
//
//

#import "MCScrollView.h"
#import "MetalImageView.h"

#define SCROLL_BASE_OFFSET  100500
#define SCROLL_BASE_TAG     100
#define SCROLL_FONT         [UIFont boldSystemFontOfSize:22]


@interface MCScrollView() 

@property (nonatomic, retain) MetalImageView *currentLabel;

@end


@implementation MCScrollView

@synthesize dataSource;
@synthesize pageWidth;
@synthesize scrollDelegate;
@synthesize currentLabel;

#pragma mark - Init

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
    delta = IS_IPAD ? 25 : 15;
    
    scroll_ = [[UIScrollView alloc] initWithFrame:self.bounds];
    scroll_.contentSize = CGSizeMake(SCROLL_BASE_OFFSET * 2, scroll_.frame.size.height);
    scroll_.contentOffset = CGPointMake(SCROLL_BASE_OFFSET, 0);
    scroll_.showsHorizontalScrollIndicator = NO;
    scroll_.delegate = self;
    [self addSubview:scroll_];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollDidReceiveTouch:)];
    [scroll_ addGestureRecognizer:gr];
    [gr release];
    
    visibleLabels_ = [NSMutableArray new];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat center = scroll_.contentOffset.x + scroll_.frame.size.width / 2;
    CGFloat dr = center - (self.currentLabel.frame.origin.x + self.currentLabel.frame.size.width + delta / 2);
    if (dr > 0) {
        
        NSInteger ind = currentLabel.tag - SCROLL_BASE_TAG + 1;
        if (ind >= dataSource.count)
            ind = 0;
        ind += SCROLL_BASE_TAG;
        
        MetalImageView *next = (MetalImageView *)[self viewWithTag:ind];
        [self setupLabel:currentLabel isSelected:NO];
        [self setupLabel:next isSelected:YES];
        
        self.currentLabel = next;
        
        if (visibleLabels_.count) {
            MetalImageView *label = [self labelToRightOrLeft:YES fromLabel:[visibleLabels_ lastObject]];
            [scroll_ addSubview:label];
            
            [visibleLabels_[0] removeFromSuperview];
            [visibleLabels_ removeObjectAtIndex:0];
            [visibleLabels_ addObject:label];
        }        
        return;
    }
    
    CGFloat dl = currentLabel.frame.origin.x - center - delta / 2;
    if (dl > 0) {
        NSInteger ind = currentLabel.tag - SCROLL_BASE_TAG - 1;
        if (ind < 0)
            ind = dataSource.count - 1;
        ind += SCROLL_BASE_TAG;
        
        MetalImageView *next = (MetalImageView *)[self viewWithTag:ind];
        [self setupLabel:currentLabel isSelected:NO];
        [self setupLabel:next isSelected:YES];
        
        self.currentLabel = next;
        
        if (visibleLabels_.count) {
            MetalImageView *label = [self labelToRightOrLeft:NO fromLabel:visibleLabels_[0]];
            [scroll_ addSubview:label];
            
            [[visibleLabels_ lastObject] removeFromSuperview];
            [visibleLabels_ removeLastObject];
            [visibleLabels_ insertObject:label atIndex:0];
        }        
        return;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateScroll];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // TODO: think how to improve scrolling
    
//    NSLog(@"__BEFORE__: %@", NSStringFromCGPoint(*targetContentOffset));
//    
//    CGFloat dx = (*targetContentOffset).x + scroll_.center.x - self.currentLabel.center.x;
//    (*targetContentOffset).x -= dx;
//    
//    NSLog(@"__AFTER__: %@", NSStringFromCGPoint(*targetContentOffset));
}

- (void)updateScrollAnimated:(BOOL)animated
{
    CGFloat dx = scroll_.contentOffset.x + scroll_.center.x - self.currentLabel.center.x;
    [scroll_ setContentOffset:CGPointMake(scroll_.contentOffset.x - dx, 0) animated:animated];
    
    if (scroll_.contentOffset.x + 2 * scroll_.frame.size.width > scroll_.contentSize.width ||
        scroll_.contentOffset.x - 2 * scroll_.frame.size.width < 0) {
        
        CGFloat dx = scroll_.contentOffset.x - SCROLL_BASE_OFFSET;
        scroll_.contentOffset = CGPointMake(SCROLL_BASE_OFFSET, 0);
        
        for (UIView *view in visibleLabels_) {
            view.center = CGPointMake(view.center.x - dx, view.center.y);
        }
    }
    
    [self sendDelegateMessage];
}

- (void)updateScroll
{
    [self updateScrollAnimated:YES];
}

- (void)sendDelegateMessage
{    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollDidChangeIndex:)]) {
        [self.scrollDelegate scrollDidChangeIndex:(self.currentLabel.tag-SCROLL_BASE_TAG)%(dataSource.count/dsMultiplier_)];
    }
}

#pragma mark - Private

- (void)setupLabel:(MetalImageView *)theLabel isSelected:(BOOL)isSelected
{
    [theLabel setSelected:isSelected];
//    if (isSelected) {
//        theLabel.textColor = [UIColor orangeColor];
//    }
//    else {
//        theLabel.textColor = [UIColor whiteColor];
//    }
}

- (MetalImageView *)getLabelWithText:(NSString *)theText
{
    MetalImageView *imgv = [[MetalImageView alloc] initWithFrame:CGRectZero];
    imgv.name = theText;
    [imgv setSelected:NO];
    imgv.frame = CGRectMake(0, 0, imgv.image.size.width, imgv.image.size.height);
    return [imgv autorelease];
    
    /*UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor blackColor];
    
    label.font = SCROLL_FONT;
    label.text = [theText lowercaseString];

    CGSize size = [theText sizeWithFont:SCROLL_FONT constrainedToSize:self.frame.size];
    label.frame = CGRectMake(0, 0, size.width, size.height);
    
    [self setupLabel:label isSelected:NO];
    return [label autorelease];*/
}

- (MetalImageView *)labelToRightOrLeft:(BOOL)toRight fromLabel:(UILabel *)fromLabel
{
    NSInteger index = fromLabel.tag - SCROLL_BASE_TAG;
    NSInteger nextIndex = toRight ? (index + 1) % dataSource.count : (index == 0 ? dataSource.count - 1 : index - 1);
    
    MetalImageView *imgv = [[self getLabelWithText:dataSource[nextIndex]] retain];
    imgv.tag = nextIndex + SCROLL_BASE_TAG;
    
    CGFloat x = toRight ? fromLabel.frame.origin.x + fromLabel.frame.size.width + delta : fromLabel.frame.origin.x - imgv.frame.size.width - delta;
    imgv.frame = CGRectMake(x, 0, imgv.frame.size.width, scroll_.frame.size.height);
    
    return [imgv autorelease];
}

#pragma mark - Scroll gesture recognizer

- (void)scrollDidReceiveTouch:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:scroll_];
    //location.x += scroll_.contentOffset.x;
    
    for (MetalImageView *label in visibleLabels_) {
        if (CGRectContainsPoint(label.frame, location)) {
            if (label != self.currentLabel) {
                CGFloat dx = label.center.x - scroll_.center.x - scroll_.contentOffset.x;
                [scroll_ setContentOffset:CGPointMake(scroll_.contentOffset.x + dx, 0) animated:YES];
                
                NSInteger ind = 0;
                for (; ind < visibleLabels_.count; ++ind) {
                    if (visibleLabels_[ind] == currentLabel)
                        break;
                }
                
                NSInteger cnt = 0;
                for (NSInteger i = 0; i < visibleLabels_.count; ++i) {
                    if (visibleLabels_[i] == label) {
                        cnt = ABS(ind-i);
                        break;
                    }
                }
                
                if (dx > 0) {
                    for (NSInteger i = 0; i < cnt; ++i) {
                        MetalImageView *lbl = [self labelToRightOrLeft:YES fromLabel:[visibleLabels_ lastObject]];
                        [scroll_ addSubview:lbl];
                        [visibleLabels_[0] removeFromSuperview];
                        [visibleLabels_ removeObjectAtIndex:0];
                        [visibleLabels_ addObject:lbl];
                    }
                }
                else {
                    for (NSInteger i = 0; i < cnt; ++i) {
                        MetalImageView *lbl = [self labelToRightOrLeft:NO fromLabel:visibleLabels_[0]];
                        [scroll_ addSubview:lbl];
                        [[visibleLabels_ lastObject] removeFromSuperview];
                        [visibleLabels_ removeLastObject];
                        [visibleLabels_ insertObject:lbl atIndex:0];
                    }
                }
                
                [self setupLabel:self.currentLabel isSelected:NO];
                self.currentLabel = label;
                [self sendDelegateMessage];
            }
            break;
        }
    }
}

#pragma mark - Public

- (void)reloadData
{
    dsMultiplier_ = 1;
    if (self.dataSource.count < 8) {
        [self.dataSource addObjectsFromArray:[NSArray arrayWithArray:self.dataSource]];
        dsMultiplier_ = 2;
    }
    
    // center label
    MetalImageView *flbl = [self getLabelWithText:self.dataSource[0]];
    flbl.tag = SCROLL_BASE_TAG;
    flbl.frame = CGRectMake(SCROLL_BASE_OFFSET + (scroll_.frame.size.width-flbl.frame.size.width)/2, 0, flbl.frame.size.width, scroll_.frame.size.height);
    [flbl setSelected:YES];
    [scroll_ addSubview:flbl];
    self.currentLabel = flbl;
    
    [visibleLabels_ removeAllObjects];
    [visibleLabels_ addObject:flbl];
    
    NSInteger ind = 0;
    CGFloat nxt;
    MetalImageView *lbl = flbl;
    // to right
    do {
        ind = (ind + 1) % self.dataSource.count;
        nxt = lbl.frame.origin.x + lbl.frame.size.width + delta;
        
        lbl = [self getLabelWithText:self.dataSource[ind]];
        lbl.tag = SCROLL_BASE_TAG + ind;
        lbl.frame = CGRectMake(nxt, 0, lbl.frame.size.width, scroll_.frame.size.height);
        [scroll_ addSubview:lbl];
        [visibleLabels_ addObject:lbl];
    }
    while (nxt < SCROLL_BASE_OFFSET + scroll_.frame.size.width * 1.3);
    
    ind = 0;
    lbl = flbl;    
    // to left
    do {
        ind = (ind == 0) ? (self.dataSource.count-1) : (ind-1);      
        nxt = lbl.frame.origin.x - delta;
        
        lbl = [self getLabelWithText:self.dataSource[ind]];
        lbl.tag = SCROLL_BASE_TAG + ind;
        lbl.frame = CGRectMake(nxt - lbl.frame.size.width, 0, lbl.frame.size.width, scroll_.frame.size.height);
        [scroll_ addSubview:lbl];
        [visibleLabels_ insertObject:lbl atIndex:0];
    }
    while (nxt > SCROLL_BASE_OFFSET - scroll_.frame.size.width * 0.3);
}

- (CGFloat)widthOfName:(NSString *)name
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_01%@.png", name.lowercaseString, (IS_IPAD ? @"_ipad" : @"")]].size.width;
}

- (void)setupForItem:(NSInteger)item
{
    if (item < 0 || item >= self.dataSource.count) {
        return;
    }
    
    NSInteger curIndex = self.currentLabel.tag - SCROLL_BASE_TAG;
    if (item == curIndex) {
        return;
    }
    
    CGFloat offset = 0;
    
    while (item > curIndex) {
        NSInteger newIndex = (curIndex + 1) % self.dataSource.count;
        
        NSString *text1 = self.dataSource[curIndex];
        NSString *text2 = self.dataSource[newIndex];
        //offset += [text1 sizeWithFont:SCROLL_FONT].width/2 + [text2 sizeWithFont:SCROLL_FONT].width/2 + delta;
        offset += [self widthOfName:text1]/2 + [self widthOfName:text2]/2 + delta;
        
        curIndex = newIndex;        
        
        MetalImageView *lbl = [self labelToRightOrLeft:YES fromLabel:[visibleLabels_ lastObject]];
        [scroll_ addSubview:lbl];
        [visibleLabels_[0] removeFromSuperview];
        [visibleLabels_ removeObjectAtIndex:0];
        [visibleLabels_ addObject:lbl];
    }
    
    while (item < curIndex) {
        NSInteger newIndex = curIndex == 0 ? self.dataSource.count-1 : curIndex-1;
        
        NSString *text1 = self.dataSource[curIndex];
        NSString *text2 = self.dataSource[newIndex];
        //offset -= ([text1 sizeWithFont:SCROLL_FONT].width/2 + [text2 sizeWithFont:SCROLL_FONT].width/2 + delta);
        offset -= ([self widthOfName:text1]/2 + [self widthOfName:text2]/2 + delta);
        
        curIndex = newIndex;
        
        MetalImageView *lbl = [self labelToRightOrLeft:NO fromLabel:visibleLabels_[0]];
        [scroll_ addSubview:lbl];
        [[visibleLabels_ lastObject] removeFromSuperview];
        [visibleLabels_ removeLastObject];
        [visibleLabels_ insertObject:lbl atIndex:0];
    }
    
    CGPoint newOffset = CGPointMake(scroll_.contentOffset.x + offset, scroll_.contentOffset.y);
    CGFloat x = newOffset.x + scroll_.frame.size.width/2;
    
    for (MetalImageView *next in visibleLabels_) {
        
        if (next.frame.origin.x > x) {
            continue;
        }
        if (next.frame.origin.x + next.frame.size.width < x) {
            continue;
        }
        
        [self setupLabel:currentLabel isSelected:NO];
        [self setupLabel:next isSelected:YES];
        self.currentLabel = next;
        
        break;
    }
    
    scroll_.contentOffset = newOffset;
    [self sendDelegateMessage];
}

#pragma mark - Memory

- (void)dealloc
{
    [visibleLabels_ release];
    [scroll_ release];
    [super dealloc];
}

@end
