//
//  MCDiamondViewController.m
//  ScrapCalc
//
//  Created by word on 29.05.13.
//
//

#import "MCDiamondViewController.h"
#import "ModelManager.h"

@interface MCDiamondViewController ()

@property (nonatomic, retain) Diamond *currentDiamond;
@property (nonatomic, assign) BOOL needsUpdate;

@end

@implementation MCDiamondViewController

@synthesize scroll;
@synthesize slider;
@synthesize sizeLabel;
@synthesize caratLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"slider_ipad.png"] forState:UIControlStateNormal];
    
    UIImage *minImage = [[UIImage imageNamed:@"slider_body_ipad.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_back_ipad.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [self.slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    if (scroll.dataSource.count < 1) {
        NSMutableArray *ds = [NSMutableArray array];
        for (Diamond *diam in [[ModelManager shared] diamonds]) {
            [ds addObject:diam.name];
        }
        scroll.dataSource = ds;
        scroll.scrollDelegate = self;
        [scroll reloadData];
    }
    
    self.currentDiamond = [[ModelManager shared] diamonds][0];
    [self setupScreenForDiamond:self.currentDiamond];
    
    [self performSelector:@selector(updateDiamondSavedValue) withObject:nil afterDelay:3];
    
    if (IS_IOS7) {
        for (UIView *sv in self.view.subviews) {
            CGRect frame = sv.frame;
            frame.origin.y += 20;
            sv.frame = frame;
        }
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }
}

- (void)viewDidUnload
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewDidUnload];
}

- (void)scrollDidChangeIndex:(NSInteger)theIndex
{
    Diamond *diam = [[ModelManager shared] diamonds][theIndex];
    [self setupScreenForDiamond:diam];
}

- (void)setupScreenForDiamond:(Diamond *)diamond
{
    if (self.currentDiamond != diamond) {
        self.currentDiamond = diamond;
    }    
    
    slider.minimumValue = 0;
    slider.maximumValue = diamond.values.count-1;
    slider.value = diamond.savedValue.floatValue;
    
    [self sliderValueChanged:slider];
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    self.currentDiamond.savedValue = [NSString stringWithFormat:@"%f", sender.value];
    NSInteger index = (NSInteger)round(sender.value);
    self.sizeLabel.text = [self.currentDiamond.values[index] allKeys][0];
    self.caratLabel.text = [[self.currentDiamond.values[index] allValues][0] stringByAppendingString:@" ct"];
    
    self.needsUpdate = YES;
}

- (void)updateDiamondSavedValue
{
    if (self.needsUpdate) {
        [[ModelManager shared] updateAllDiamonds];
        self.needsUpdate = NO;
    }
    [self performSelector:_cmd withObject:nil afterDelay:3];
}

@end
