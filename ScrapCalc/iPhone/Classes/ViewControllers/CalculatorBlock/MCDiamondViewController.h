//
//  MCDiamondViewController.h
//  ScrapCalc
//
//  Created by word on 29.05.13.
//
//

#import "BaseViewController.h"
#import "MCScrollView.h"
#import "MCBoldCondLabel.h"

@interface MCDiamondViewController : BaseViewController <MCScrollViewDelegate>

@property (nonatomic, retain) IBOutlet MCScrollView *scroll;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet MCBoldCondLabel *sizeLabel;
@property (nonatomic, retain) IBOutlet MCBoldCondLabel *caratLabel;

- (IBAction)sliderValueChanged:(UISlider *)sender;

@end
