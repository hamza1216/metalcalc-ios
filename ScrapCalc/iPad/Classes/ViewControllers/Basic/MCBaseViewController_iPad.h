//
//  MCBaseViewController_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "MCBaseViewControllerProtocol.h"
#import "MCSplitViewController.h"
#import "MCNavigationController.h"
#import "MCToolbarView.h"
#import "InMobi.h"
#import "IMInterstitial.h"
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import "DejalActivityView.h"

#define DETAIL_VC_FRAME_PORTRAIT    CGRectMake(32, 36, 708, 960)
#define DETAIL_VC_FRAME_LANDSCAPE   CGRectMake( 4, 40, 694, 700)

@class MCNavigationController;


@interface MCBaseViewController_iPad : GAITrackedViewController <UIAlertViewDelegate, MCBaseViewControllerProtocol, IMInterstitialDelegate, GADBannerViewDelegate, GADInterstitialDelegate>
{
    IMInterstitial      		*adsInMobi;
    GADBannerView       	*bannerView;
    GADInterstitial     	*adMob;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, readonly) MCSplitViewController *splitViewController;
@property (nonatomic, assign) MCNavigationController *navigationViewController;
@property (nonatomic, assign) BOOL needsMoveBackButtonToTheContainer;
@property (nonatomic, assign) BOOL needsMovePrintButtonToTheContainer;

- (BOOL)needsBackground;
- (void)setLeftToolBarButtonHidden:(BOOL)hidden;
- (void)setRightToolBarButtonHidden:(BOOL)hidden;

- (void)addBackButton;
- (void)removeBackButton;

- (void)addPrintButton;
- (void)removePrintButton;

- (void)setupForPortrait;
- (void)setupForLandscape;

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message okTitle:(NSString *)ok cancelTitle:(NSString *)cancel delegate:(id<UIAlertViewDelegate>)delegate;
- (void)showBuyNowAlert;
- (void)showInternetAbsenceAlertView;

- (void)showAdIfNeeded;

- (void)showLoading;
- (void)hideLoading;


- (UIImage *)imageForLeftToolBarButton;
- (CGRect)imageRectForLefToolBarButton;
- (UIImage *)imageForRightToolBarButton;
- (CGRect)imageRectForRightToolBarButton;
- (IBAction)actionForLeftButtonOnTheToolBar;
- (IBAction)actionForRightButtonOnTheToolBar;
- (IBAction)backAction:(id)sender;

- (void)onClickBtnPrint:(UIButton *)sender;

@end
