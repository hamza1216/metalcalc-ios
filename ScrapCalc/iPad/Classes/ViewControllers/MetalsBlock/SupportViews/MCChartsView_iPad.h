//
//  MCChartsView_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 07.08.13.
//
//

#import "MCChartsView.h"

@interface MCChartsView_iPad : UIView

@property (nonatomic, strong) IBOutlet UIImageView *backgroundChartView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundMenuView;

@property (nonatomic, strong) IBOutlet UIImageView *chartView;
@property (nonatomic, strong) IBOutlet UIView *menuView;

- (void)updateForMetal:(Metal *)metal;

@end
