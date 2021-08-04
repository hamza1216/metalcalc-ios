//
//  MCPickerPopover.h
//  ScrapCalc
//
//  Created by Diana on 14.10.13.
//
//

#import <UIKit/UIKit.h>
#import "SPPickerView.h"

@class MCPickerPopover;

@protocol  MCPickerPopoverDelegate <NSObject>

@optional

- (void)picker:(MCPickerPopover *)picker didSelectRow:(NSUInteger)row;

@end

@interface MCPickerPopover : UIView

@property (nonatomic, retain) IBOutlet SPPickerView *picker;
@property (nonatomic, assign) id<SPPickerViewDataSource> dataSource;
@property (nonatomic, assign) id<SPPickerViewDelegate> delegate;

- (void)reloadData;
- (void)selectRow:(NSInteger)row animated:(BOOL)animated;
- (void)show;
- (void)hide;

@end
