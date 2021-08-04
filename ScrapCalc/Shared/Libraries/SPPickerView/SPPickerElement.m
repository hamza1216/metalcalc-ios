//
//  SPPickerElement.m
//  PickerView
//
//  Created by Diana on 26.09.13.
//
//

#import "SPPickerElement.h"
#define ROW_SPACE 39.0
#define CONTENT_OFFSET_Y 20
#define ROW_TEXT_COLOR_DEFAULT [UIColor blackColor]

@implementation SPPickerElement

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _customInitialization];
        [self setup];
        // Initialization code
    }
    return self;
}

- (void)_customInitialization
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self setDelegate:self];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)setup
{
    self.rowFont = [UIFont boldSystemFontOfSize:24.0];
    self.rowIndent = 50.0;
    self.selectedRow = 0;
    rowsCount = 0;
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
}

#pragma mark - Custom getters/setters

- (void)setSelectedRow:(int)selectedRow
{
    if (selectedRow >= rowsCount)
        return;
    
    [self setContentOffset:CGPointMake(0.0, ROW_SPACE * selectedRow) animated:NO];
    _selectedRow = selectedRow;
}

- (void)setRowFont:(UIFont *)rowFont
{
    for (UILabel *aLabel in visibleViews)
    {
        aLabel.font = rowFont;
    }
    
    for (UILabel *aLabel in recycledViews)
    {
        aLabel.font = rowFont;
    }
    _rowFont = rowFont;
}

- (void)setRowIndent:(CGFloat)rowIndent
{
    for (UILabel *aLabel in visibleViews)
    {
        CGRect frame = aLabel.frame;
        frame.origin.x = rowIndent;
        frame.size.width = self.frame.size.width - rowIndent;
        aLabel.frame = frame;
    }
    
    for (UILabel *aLabel in recycledViews)
    {
        CGRect frame = aLabel.frame;
        frame.origin.x = rowIndent;
        frame.size.width = self.frame.size.width - rowIndent;
        aLabel.frame = frame;
    }
    _rowIndent = rowIndent;
}


#pragma mark - public

- (void)reloadData
{
    self.selectedRow = 0;
    rowsCount = 0;
    
    for (UIView *aView in visibleViews)
        [aView removeFromSuperview];
    
    for (UIView *aView in recycledViews)
        [aView removeFromSuperview];
    
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
    
    rowsCount = (int)[self.dataSource numberOfRowsInPickerElement:self];
    [self setContentOffset:CGPointMake(0.0, CONTENT_OFFSET_Y) animated:NO];
    self.contentSize = CGSizeMake(self.frame.size.width, ROW_SPACE * rowsCount + 3 * ROW_SPACE);
    [self tileViews];
}

- (void)selectRow:(NSUInteger)row animated:(BOOL)animated
{
    if (row >= rowsCount)
        return;
    
    [self setContentOffset:CGPointMake(0.0, ROW_SPACE * row + CONTENT_OFFSET_Y) animated:animated];
    _selectedRow = (int)row;
}

#pragma mark - private

- (void)determineCurrentRow
{
    NSLog(@"determine");
    CGFloat delta = self.contentOffset.y;
    NSLog(@"delta %f", delta);
    CGFloat floatPosition = delta/ROW_SPACE;
    NSLog(@"float position %f", floatPosition);
    int position = roundf(floatPosition);
    NSLog(@"Chosen position %d", position);
    int prevPosition = self.selectedRow;
    self.selectedRow = position;
    [self configureView:[self visibleViewForIndex:prevPosition] atIndex:prevPosition];//deselect previous label
    [self configureView:[self visibleViewForIndex:position] atIndex:position];//select current label
    [UIView animateWithDuration:0.2 animations:^{
        [self setContentOffset:CGPointMake(0.0, ROW_SPACE * position + CONTENT_OFFSET_Y) animated:YES];
    }];
    
    [self.pickerDelegate pickerElement:self didSelectRow:self.selectedRow];
}

- (void)didTap:(id)sender
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
    CGPoint point = [tapRecognizer locationInView:self];
    int steps = floor(point.y / ROW_SPACE) - 2;
    if(self.selectedRow + steps < 0 || steps > rowsCount)
        return;
    [self makeSteps:steps];
}

- (void)makeSteps:(int)steps
{
    int prevPosition = self.selectedRow;    
    self.selectedRow = steps;
    [self configureView:[self visibleViewForIndex:prevPosition] atIndex:prevPosition];//deselect previous label
    [self configureView:[self visibleViewForIndex:self.selectedRow] atIndex:self.selectedRow];//select current label
    [UIView animateWithDuration:0.2 animations:^{
        [self setContentOffset:CGPointMake(0.0, ROW_SPACE * self.selectedRow + CONTENT_OFFSET_Y) animated:YES];
    }];
    [self.pickerDelegate pickerElement:self didSelectRow:self.selectedRow];
}

- (void)configureView:(UIView *)view atIndex:(NSUInteger)index
{
    UILabel *label = (UILabel *)view;
    label.text = [self.dataSource pickerElement:self titleForRow:index];
    CGRect frame = label.frame;
    frame.origin.y = ROW_SPACE * index + 78.0;
    label.frame = frame;
    if(self.selectedRow == index)
    {
        label.textColor = self.selectedRowTextColor?self.selectedRowTextColor:ROW_TEXT_COLOR_DEFAULT;
    }
    else
    {
        label.textColor = self.rowTextColor?self.rowTextColor:ROW_TEXT_COLOR_DEFAULT;
    }
}

#pragma mark - recycle queue

- (UIView *)dequeueRecycledView
{
    UIView *aView = [recycledViews anyObject];
    
    if (aView)
        [recycledViews removeObject:aView];
    return aView;
}


- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (UIView *aView in visibleViews)
    {
        int viewIndex = aView.frame.origin.y / ROW_SPACE - 2;
        if (viewIndex == index)
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (UIView *)visibleViewForIndex:(NSUInteger)index
{
    for (UIView *aView in visibleViews)
    {
        int viewIndex = aView.frame.origin.y / ROW_SPACE - 2;
        if (viewIndex == index)
        {
            return aView;
        }
    }
    return nil;
}

- (void)tileViews
{
    // Calculate which pages are visible
    CGRect visibleBounds = self.bounds;
    int firstNeededViewIndex = floorf(CGRectGetMinY(visibleBounds) / ROW_SPACE) - 2;
    int lastNeededViewIndex  = floorf((CGRectGetMaxY(visibleBounds) / ROW_SPACE)) - 2;
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);
    lastNeededViewIndex  = MIN(lastNeededViewIndex, rowsCount - 1);
    
    // Recycle no-longer-visible pages
    for (UIView *aView in visibleViews)
    {
        int viewIndex = aView.frame.origin.y / ROW_SPACE - 2;
        if (viewIndex < firstNeededViewIndex || viewIndex > lastNeededViewIndex)
        {
            [recycledViews addObject:aView];
            [aView removeFromSuperview];
        }
    }
    
    [visibleViews minusSet:recycledViews];
    
    // add missing pages
    for (int index = firstNeededViewIndex; index <= lastNeededViewIndex; index++)
    {
        if (![self isDisplayingViewForIndex:index])
        {
            UILabel *label = (UILabel *)[self dequeueRecycledView];
            
            if (label == nil)
            {
                label = [[UILabel alloc] initWithFrame:CGRectMake(self.rowIndent, 0, self.frame.size.width - self.rowIndent, ROW_SPACE)];
                label.backgroundColor = [UIColor clearColor];
                label.font = self.rowFont;
                label.textColor = RGBACOLOR(0.0, 0.0, 0.0, 0.75);
            }
            
            [self configureView:label atIndex:index];
            [self addSubview:label];
            [visibleViews addObject:label];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tileViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self determineCurrentRow];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self determineCurrentRow];
}

@end
