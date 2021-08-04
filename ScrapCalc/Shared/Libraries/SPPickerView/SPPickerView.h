#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol SPPickerViewDataSource;
@protocol SPPickerViewDelegate;

@interface SPPickerView : UIView <UIScrollViewDelegate> {
    
    NSInteger componentsCount_;
    NSMutableArray *contentViews_;
    
    UIToolbar *toolBar_;
    UILabel *toolBarTitleLabel_;
}

@property (nonatomic, unsafe_unretained) id <SPPickerViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id <SPPickerViewDelegate> delegate;
@property (nonatomic, readwrite, strong) UIView *backgroundMaskView;
@property (nonatomic, readwrite, strong) UIView *contentBackgroundView;
@property (nonatomic, readwrite, strong) UIView *selectedRowView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *rowFont;
@property (nonatomic, strong) UIColor *rowTextColor;
@property (nonatomic, assign) CGFloat selectedRowViewWidth;
@property (nonatomic, strong) UIColor *selectedRowTextColor;


@property (nonatomic, assign) BOOL toolBarHidden;
@property (nonatomic, strong) NSString *toolBarTitle;

@property(nonatomic, unsafe_unretained) BOOL isHidden;

- (id)initWithFrame:(CGRect)frame backgroundImage:(NSString *)backgroundImage shadowImage:(NSString *)shadowImage glassImage:(NSString *)glassImage title:(NSString *)title;


- (void)reloadData;

- (void)hidePicker;

- (void)showPicker;

- (void)selectRow:(NSUInteger)row inComponent:(NSUInteger)component animated:(BOOL)animated;

@end


@protocol SPPickerViewDataSource <NSObject>

- (NSInteger)numberOfComponentsInPickerView:(SPPickerView *)pickerView;

- (NSInteger)pickerView:(SPPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end


@protocol SPPickerViewDelegate <NSObject>

@optional
- (CGFloat)pickerView:(SPPickerView *)pickerView widthForComponent:(NSInteger)component;

- (void)pickerView:(SPPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

- (NSString *)pickerView:(SPPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

// TODO: implement usage of this two methods

- (NSString *)pickerView:(SPPickerView *)pickerView viewForRow:(UIView *)view forComponent:(NSInteger)component;

- (UIView *)pickerView:(SPPickerView *)pickerView viewForSelectedRow:(UIView *)view forComponent:(NSInteger)component;

@end