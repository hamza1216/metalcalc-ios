//
//  SPPickerElement.h
//  PickerView
//
//  Created by Diana on 26.09.13.
//
//

#import <UIKit/UIKit.h>
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@protocol SPPickerElementDataSource, SPPickerElementDelegate;

@interface SPPickerElement : UIScrollView <UIScrollViewDelegate>
{
    NSMutableSet *recycledViews;
    NSMutableSet *visibleViews;
    
    int rowsCount;
}

@property (nonatomic, unsafe_unretained) id <SPPickerElementDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id <SPPickerElementDelegate> pickerDelegate;


@property (nonatomic, unsafe_unretained) int selectedRow;
@property (nonatomic, strong) UIFont *rowFont;
@property (nonatomic, strong) UIColor *rowTextColor;
@property (nonatomic, strong) UIColor *selectedRowTextColor;
@property(nonatomic, unsafe_unretained) CGFloat rowIndent;

- (void)reloadData;

- (void)selectRow:(NSUInteger)row animated:(BOOL)animated;

@end


@protocol SPPickerElementDataSource <NSObject>

- (NSInteger)numberOfRowsInPickerElement:(SPPickerElement *)pickerElement;

- (NSString *)pickerElement:(SPPickerElement *)pickerElement titleForRow:(NSInteger)row;

@end

@protocol SPPickerElementDelegate <NSObject>

- (void)pickerElement:(SPPickerElement *)pickerElement didSelectRow:(NSInteger)row;

@end