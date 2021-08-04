//
//  MCPickerPopover.m
//  ScrapCalc
//
//  Created by Diana on 14.10.13.
//
//

#import "MCPickerPopover.h"

@interface MCPickerPopover ()<SPPickerViewDelegate, SPPickerViewDataSource>

@end

@implementation MCPickerPopover

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.picker.rowFont = FONT_MYRIAD_BOLD(18);
}


#pragma mark - public

- (void)reloadData
{
    [self.picker reloadData];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated
{
    [self.picker selectRow:row inComponent:0 animated:animated];
}

- (void)show
{
    self.hidden = NO;
    [self.picker showPicker];
    [self.picker reloadData];
}

- (void)hide
{
    self.hidden = YES;
}

#pragma mark - delegate, datasource

- (NSInteger)numberOfComponentsInPickerView:(SPPickerView *)pickerView
{
    return [[self dataSource] numberOfComponentsInPickerView:pickerView];
}

- (NSInteger)pickerView:(SPPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self dataSource] pickerView:pickerView numberOfRowsInComponent:component];
}

- (NSString *)pickerView:(SPPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self delegate] pickerView:pickerView titleForRow:row forComponent:component];
}

- (void)pickerView:(SPPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    return [[self delegate] pickerView:pickerView didSelectRow:row inComponent:component];
}

@end
