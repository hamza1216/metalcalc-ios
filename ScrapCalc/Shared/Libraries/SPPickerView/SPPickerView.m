#import <CoreGraphics/CoreGraphics.h>
#import "SPPickerView.h"
#import "SPPickerElement.h"

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define ROW_SPACE 39.0
#define TOOLBAR_HEIGHT 44
#define TOOLBAR_TITLE_WIDTH_OFFSET 80
#define MAX_PICKER_WIDTH 320
#define DEFAULT_COMPONENT_WIDTH(components) MAX_PICKER_WIDTH/components

#define TOOLBAR_TITLE_DEFAULT               @"SPPickerView"

#define IMAGE_VIEW_WITH_IMAGE_NAME(name)    [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]]
#define BACKGROUND_MASK_VIEW_DEFAULT        IMAGE_VIEW_WITH_IMAGE_NAME(@"PickerBG")
#define CONTENT_BACKGROUND_VIEW_DEFAULT     IMAGE_VIEW_WITH_IMAGE_NAME(@"PickerShadow")
#define SELECTED_ROW_VIEW_DEFAULT           IMAGE_VIEW_WITH_IMAGE_NAME(@"pickerGlass")

@interface SPPickerView() <SPPickerElementDataSource, SPPickerElementDelegate>

@end

@implementation SPPickerView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
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

- (id)initWithFrame:(CGRect)frame backgroundImage:(NSString *)backgroundImage shadowImage:(NSString *)shadowImage glassImage:(NSString *)glassImage title:(NSString *)title {
    self = [super initWithFrame:frame];    
    if (self)
    {
        [self _customInitialization];
    }
    return self;
}

- (void)_customInitialization
{
    //self.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
    
    self.isHidden = YES;
    //[self _setUpToolbar];
    [self _setupBackgroundView];
    self.backgroundMaskView.userInteractionEnabled = NO;
    [self _setupContentView];
    [self _setupSelectedView];
}

#pragma mark - public

- (void)reloadData
{
    [self layoutContentViews];
    [self bringSubviewToFront:self.backgroundMaskView];
    for (SPPickerElement *element in contentViews_)
    {
        [element reloadData];
    }
}


#pragma mark - SPPickerElementDataSource

- (NSInteger)numberOfRowsInPickerElement:(SPPickerElement *)pickerElement
{
    NSInteger componentIndex = [contentViews_ indexOfObject:pickerElement];
    return [[self dataSource] pickerView:self numberOfRowsInComponent:componentIndex];
}

- (NSString *)pickerElement:(SPPickerElement *)pickerElement titleForRow:(NSInteger)row
{
    NSInteger componentIndex = [contentViews_ indexOfObject:pickerElement];
    return [[self delegate] pickerView:self titleForRow:row forComponent:componentIndex];
}

#pragma mark - SPPickerElementDelegate

- (void)pickerElement:(SPPickerElement *)pickerElement didSelectRow:(NSInteger)row
{
    NSInteger componentIndex = [contentViews_ indexOfObject:pickerElement];
    [[self delegate] pickerView:self didSelectRow:row inComponent:componentIndex];
}

#pragma mark - Picker Trigger
- (void)hidePicker {
    if (!self.isHidden) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            //self.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
        }];
        self.isHidden = YES;
    }
}

- (void)showPicker {
    if (self.isHidden) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            //self.frame = CGRectMake(0, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
        }];
        self.isHidden = NO;
    }
}

- (void)selectRow:(NSUInteger)row inComponent:(NSUInteger)component animated:(BOOL)animated
{
    SPPickerElement *element = [contentViews_ objectAtIndex:component];
    [element selectRow:row animated:animated];
}


#pragma mark - setters

- (void)setSelectedRowViewWidth:(CGFloat)selectedRowViewWidth
{
    CGRect frame = _selectedRowView.frame;
    frame.size.width = selectedRowViewWidth;
    _selectedRowView.frame = frame;
}

- (void)setToolBarHidden:(BOOL)toolBarHidden
{
    _toolBarHidden = toolBarHidden;
    toolBar_.hidden = toolBarHidden;
}

- (void)setToolBarTitle:(NSString *)toolBarTitle
{
    toolBarTitleLabel_.text = toolBarTitle;
    _toolBarTitle = toolBarTitle;
}

- (void)setBackgroundMaskView:(UIView *)backgroundMaskView
{
    [_backgroundMaskView removeFromSuperview];
    _backgroundMaskView = backgroundMaskView;
    [self _setupBackgroundView];
}

- (void)setContentBackgroundView:(UIView *)contentBackgroundView
{
    [_contentBackgroundView removeFromSuperview];
    _contentBackgroundView = contentBackgroundView;
    [self _setupContentView];
}

- (void)setSelectedRowView:(UIView *)selectedRowView
{
    [_selectedRowView removeFromSuperview];
    _selectedRowView = selectedRowView;
    [self _setupSelectedView];
}

- (void)setRowFont:(UIFont *)rowFont
{
    _rowFont = rowFont;
    for(SPPickerElement *elem in contentViews_)
    {
        [elem setRowFont:rowFont];
    }
}

- (void)setRowTextColor:(UIColor *)rowTextColor
{
    _rowTextColor = rowTextColor;
    for(SPPickerElement *elem in contentViews_)
    {
        [elem setRowTextColor:rowTextColor];
    }
}

- (void)setSelectedRowTextColor:(UIColor *)selectedRowTextColor
{
    _selectedRowTextColor = selectedRowTextColor;
    for(SPPickerElement *elem in contentViews_)
    {
        [elem setSelectedRowTextColor:selectedRowTextColor];
    }
}


#pragma mark - Private Methods
- (UIBarButtonItem *)_toolbarTitleItem
{
    UILabel *toolbarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0, self.frame.size.width - TOOLBAR_TITLE_WIDTH_OFFSET, 21.0)];
    toolbarTitleLabel.text = self.title.length?self.title:TOOLBAR_TITLE_DEFAULT;
    toolbarTitleLabel.backgroundColor = [UIColor clearColor];
    toolbarTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    toolbarTitleLabel.textColor = RGBACOLOR(255, 255, 255, 1);
    toolBarTitleLabel_ = toolbarTitleLabel;
    return [[UIBarButtonItem alloc] initWithCustomView:toolbarTitleLabel];
}

- (void)_setUpToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TOOLBAR_HEIGHT)];
    toolbar.tintColor = RGBACOLOR(254, 172, 64, 1);
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:nil action:@selector(hidePicker)];
    UIBarButtonItem *placeHolderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:[self _toolbarTitleItem], placeHolderButton, doneButton, nil]];
    toolBar_ = toolbar;
    [self addSubview:toolbar];
}

- (void)_setupBackgroundView
{
    if(!self.backgroundMaskView)
    {
        UIImageView *bgImageView = BACKGROUND_MASK_VIEW_DEFAULT;
        _backgroundMaskView = bgImageView;
    }
    self.backgroundMaskView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.backgroundMaskView.userInteractionEnabled = NO;
    [self addSubview:self.backgroundMaskView];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.backgroundMaskView.frame.size.width, self.backgroundMaskView.frame.size.height);
}

- (void)_setupContentView
{
    if(!self.contentBackgroundView)
    {
        UIImageView *bgImageView = CONTENT_BACKGROUND_VIEW_DEFAULT;
        _contentBackgroundView = bgImageView;
    }
    self.contentBackgroundView.userInteractionEnabled = NO;
    self.contentBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.contentBackgroundView];
}

- (void)_setupSelectedView
{
    if(!self.selectedRowView)
    {
        UIImageView *bgImageView = SELECTED_ROW_VIEW_DEFAULT;
        _selectedRowView = bgImageView;
    }
    self.selectedRowView.frame = CGRectMake(32, 115.0 - TOOLBAR_HEIGHT, _selectedRowView.frame.size.width - 32, _selectedRowView.frame.size.height);
    [self addSubview:self.selectedRowView];
}

- (UIScrollView *)contentViewWithIndex:(NSInteger)index width:(CGFloat)widht
{
    CGFloat componentWidth = DEFAULT_COMPONENT_WIDTH([[self dataSource] numberOfComponentsInPickerView:self]);
    SPPickerElement *contentView = [[SPPickerElement alloc] initWithFrame:CGRectMake(index*componentWidth,
                                                                                     60 - TOOLBAR_HEIGHT,
                                                                                     componentWidth, self.frame.size.height - 70 + TOOLBAR_HEIGHT)];
    return contentView;
}

- (void)layoutContentViews
{
    if(componentsCount_ != [[self dataSource] numberOfComponentsInPickerView:self])
    {
        for(UIView *aView in contentViews_)
        {
            [aView removeFromSuperview];
        }
        [contentViews_ removeAllObjects];
        contentViews_ = [NSMutableArray new];
    }
    else
    {
        return;
    }
    for(int i=0; i<[[self dataSource] numberOfComponentsInPickerView:self]; i++)
    {
        //CGFloat width = [[self delegate] pickerView:self widthForComponent:i];
        SPPickerElement *component = (SPPickerElement *)[self contentViewWithIndex:i width:0];
        component.dataSource = self;
        component.pickerDelegate = self;
        component.rowFont = self.rowFont;
        component.rowTextColor = self.rowTextColor;
        component.selectedRowTextColor = self.selectedRowTextColor;
        [self addSubview:component];
        [contentViews_ addObject:component];
    }
}

@end
