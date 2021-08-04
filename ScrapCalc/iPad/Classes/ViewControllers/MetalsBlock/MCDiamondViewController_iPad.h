//
//  MCDiamondViewController_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 05.08.13.
//
//

#import "MCDiamondViewController.h"
#import "MCScrollView.h"
#import "MCBoldCondLabel.h"

#define DIAMOND_CONTENT_FRAME_PORTRAIT      CGRectMake(10, 90, 674, 600)
#define DIAMOND_CONTENT_FRAME_LANDSCAPE     CGRectMake(10, 16, 660, 600)


@protocol MCDiamondViewControllerDelegate

- (void)didReceiveBackAction;

@end


@interface MCDiamondViewController_iPad : MCDiamondViewController

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *contentView;

@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *rotateButton;

@property (nonatomic, assign) NSObject<MCDiamondViewControllerDelegate> *delegate;

- (IBAction)rotateAction:(id)sender;
- (IBAction)backAction:(id)sender;

- (void)setupForPortrait;
- (void)setupForLandscape;

@end
