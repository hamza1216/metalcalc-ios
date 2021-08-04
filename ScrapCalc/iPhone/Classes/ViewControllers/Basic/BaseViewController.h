//
//  BaseViewController.h
//  ScrapCalc
//
//  Created by word on 14.03.13.
//
//

#import "AppDelegate.h"
#import "GAITrackedViewController.h"
#import "InMobi.h"
#import "IMInterstitial.h"
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADInterstitial.h>

@interface BaseViewController : GAITrackedViewController <IMInterstitialDelegate, UIAlertViewDelegate, GADInterstitialDelegate> {
    UIImageView *bgView_;
    IMInterstitial *adsInmobi;
    GADInterstitial *adMob;
}

- (void)initBackButton;
- (void)initPrintButton;
- (void)initBackButtonWithTitle:(NSString *)title;
- (void)setNavigationTitle:(NSString *)title;

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message okTitle:(NSString *)ok cancelTitle:(NSString *)cancel delegate:(id<UIAlertViewDelegate>)delegate;
- (void)showBuyNowAlert;
- (void)showInternetAbsenceAlertView;

- (void)showAdIfNeeded;

- (void)showLoading;
- (void)hideLoading;

- (void)onClickBtnPrint:(UIButton *)sender;

@end
